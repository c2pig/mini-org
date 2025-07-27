variable "okta_org_name" {
  description = "Okta organization name"
  type        = string
  default     = "mini-org-dev"
}

variable "okta_base_url" {
  description = "Okta base URL"
  type        = string
  default     = "okta.com"
}

variable "okta_api_token" {
  description = "Okta API token for authentication"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  default     = ""
}

variable "emergency_contacts" {
  description = "List of emergency contact emails"
  type        = list(string)
  default     = []
}

variable "ip_whitelist" {
  description = "List of IP ranges allowed for access"
  type        = list(string)
  default     = [
    "10.0.0.0/8",
    "192.168.1.0/24"
  ]
}

variable "session_timeout" {
  description = "Default session timeout for applications"
  type        = string
  default     = "8h"
}

variable "mfa_required" {
  description = "Whether MFA is required for all users"
  type        = bool
  default     = true
}

variable "auto_provision_users" {
  description = "Whether to automatically provision users from configuration"
  type        = bool
  default     = true
}

variable "compliance_reporting" {
  description = "Enable compliance reporting features"
  type        = bool
  default     = true
}

variable "audit_log_retention" {
  description = "Audit log retention period in days"
  type        = number
  default     = 365
  validation {
    condition     = var.audit_log_retention >= 90
    error_message = "Audit log retention must be at least 90 days."
  }
}