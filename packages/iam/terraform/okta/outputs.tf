output "okta_org_url" {
  description = "Okta organization URL"
  value       = "https://${var.okta_org_name}.${var.okta_base_url}"
}

output "created_users" {
  description = "Map of created Okta users"
  value = {
    for key, user in okta_user.iam_users :
    key => {
      id    = user.id
      email = user.email
      name  = "${user.first_name} ${user.last_name}"
    }
  }
}

output "created_groups" {
  description = "Map of created Okta groups"
  value = {
    for key, group in okta_group.iam_groups :
    key => {
      id   = group.id
      name = group.name
    }
  }
}

output "saml_applications" {
  description = "Map of created SAML applications"
  value = {
    for key, app in okta_app_saml.sso_apps :
    key => {
      id               = app.id
      name             = app.label
      sso_url          = app.sso_url
      metadata_url     = app.metadata_url
      certificate      = app.certificate
    }
  }
  sensitive = true
}

output "oidc_applications" {
  description = "Map of created OIDC applications"
  value = {
    for key, app in okta_app_oauth.oidc_apps :
    key => {
      id          = app.id
      name        = app.label
      client_id   = app.client_id
    }
  }
}

output "application_urls" {
  description = "SSO URLs for applications"
  value = {
    for key, app_config in local.app_configs :
    key => {
      sso_url     = app_config.spec.config.ssoUrl
      description = app_config.metadata.description
    }
  }
}

output "compliance_summary" {
  description = "Summary of compliance configuration"
  value = {
    total_users           = length(okta_user.iam_users)
    total_groups          = length(okta_group.iam_groups)
    total_applications    = length(local.app_configs)
    mfa_required         = var.mfa_required
    audit_retention_days = var.audit_log_retention
    environment          = var.environment
  }
}