variable "zone_name" {
  description = "Cloudflare zone name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "api_endpoint" {
  description = "API endpoint hostname"
  type        = string
  default     = "api-lb.example.com"
}

variable "app_endpoint" {
  description = "App endpoint hostname"
  type        = string
  default     = "app-lb.example.com"
}