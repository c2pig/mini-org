terraform {
  required_version = ">= 1.0"
  
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 4.0"
    }
  }
  
  # Use Terraform Cloud for state management
  cloud {
    organization = "mini-org-capability"
    
    workspaces {
      tags = ["iam", "okta"]
    }
  }
}

# Okta provider configuration
provider "okta" {
  org_name  = var.okta_org_name
  base_url  = var.okta_base_url
  api_token = var.okta_api_token
}

# Local values for dynamic configuration
locals {
  user_configs = {
    for file in fileset("${path.module}/../../configs/users", "*.yaml") :
    trimsuffix(file, ".yaml") => yamldecode(file("${path.module}/../../configs/users/${file}"))
  }
  
  app_configs = {
    for file in fileset("${path.module}/../../configs/applications", "*.yaml") :
    trimsuffix(file, ".yaml") => yamldecode(file("${path.module}/../../configs/applications/${file}"))
  }
}

# Create Okta groups based on role definitions
resource "okta_group" "iam_groups" {
  for_each = toset([
    "platform-admins",
    "infrastructure-team",
    "security-team",
    "developers",
    "frontend-team",
    "deployment-team",
    "operations",
    "sre-team",
    "on-call-engineers",
    "analysts",
    "read-only-users",
    "business-intelligence",
    "emergency-admins",
    "break-glass-users"
  ])
  
  name        = each.value
  description = "IAM group for ${each.value}"
  type        = "OKTA_GROUP"
}

# Create Okta users from configuration files
resource "okta_user" "iam_users" {
  for_each = local.user_configs
  
  first_name         = each.value.spec.profile.firstName
  last_name          = each.value.spec.profile.lastName
  login              = each.value.spec.profile.email
  email              = each.value.spec.profile.email
  department         = try(each.value.spec.profile.department, null)
  title              = try(each.value.spec.profile.title, null)
  employee_number    = try(each.value.spec.profile.employeeId, null)
  manager            = try(each.value.spec.profile.manager, null)
  
  status             = "ACTIVE"
  
  # Custom attributes
  custom_profile_attributes = jsonencode({
    startDate = try(each.value.spec.profile.startDate, null)
    skills    = try(join(",", each.value.spec.profile.skills), null)
    roles     = join(",", each.value.spec.roles)
  })
  
  lifecycle {
    ignore_changes = [
      password
    ]
  }
}

# Assign users to groups
resource "okta_group_memberships" "user_group_assignments" {
  for_each = {
    for user_key, user_config in local.user_configs :
    user_key => user_config.spec.groups
  }
  
  group_id = okta_group.iam_groups[each.value[0]].id
  users    = [okta_user.iam_users[each.key].id]
  
  count = length(each.value)
}

# Create SAML applications
resource "okta_app_saml" "sso_apps" {
  for_each = {
    for app_key, app_config in local.app_configs :
    app_key => app_config
    if app_config.spec.type == "saml"
  }
  
  label                     = each.value.metadata.displayName
  description               = each.value.metadata.description
  status                    = "ACTIVE"
  
  # SAML settings
  sso_url                   = each.value.spec.config.ssoUrl
  recipient                 = each.value.spec.config.ssoUrl
  destination               = each.value.spec.config.ssoUrl
  audience                  = each.value.spec.config.audienceRestriction
  subject_name_id_template  = "\${user.userName}"
  subject_name_id_format    = each.value.spec.config.nameIdFormat
  response_signed           = true
  assertion_signed          = true
  signature_algorithm       = each.value.spec.config.signatureAlgorithm
  
  # Attribute statements
  attribute_statements {
    type      = "EXPRESSION"
    name      = "email"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    values    = ["user.email"]
  }
  
  attribute_statements {
    type      = "EXPRESSION"
    name      = "firstName"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    values    = ["user.firstName"]
  }
  
  attribute_statements {
    type      = "EXPRESSION"
    name      = "lastName"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    values    = ["user.lastName"]
  }
}

# Create OIDC applications
resource "okta_app_oauth" "oidc_apps" {
  for_each = {
    for app_key, app_config in local.app_configs :
    app_key => app_config
    if app_config.spec.type == "oidc"
  }
  
  label                     = each.value.metadata.displayName
  type                      = "web"
  grant_types               = ["authorization_code"]
  response_types            = ["code"]
  
  # OIDC settings
  client_id                 = each.value.spec.config.clientId
  redirect_uris             = [each.value.spec.config.redirectUri]
  
  # Token settings
  token_endpoint_auth_method = "client_secret_basic"
  
  lifecycle {
    ignore_changes = [
      client_secret
    ]
  }
}

# Assign applications to groups based on role mapping
resource "okta_app_group_assignments" "app_group_assignments" {
  for_each = {
    for combo in flatten([
      for app_key, app_config in local.app_configs : [
        for role, mapping in app_config.spec.roleMapping : {
          app_key   = app_key
          app_type  = app_config.spec.type
          role      = role
          group     = "${role}-users"
        }
      ]
    ]) : "${combo.app_key}-${combo.role}" => combo
  }
  
  app_id   = each.value.app_type == "saml" ? okta_app_saml.sso_apps[each.value.app_key].id : okta_app_oauth.oidc_apps[each.value.app_key].id
  group_id = okta_group.iam_groups[each.value.group].id
}