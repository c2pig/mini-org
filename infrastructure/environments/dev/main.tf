terraform {
  required_version = ">= 1.0"
  
  cloud {
    organization = "mini-org-capability"
    workspaces {
      name = "mini-org-capability-dev"
    }
  }
}

# Local variables
locals {
  environment = "dev"
  common_tags = {
    Environment = local.environment
    Project     = "mini-org-capability"
    ManagedBy   = "terraform"
  }
}

# Networking module
module "networking" {
  source = "../../modules/networking"
  
  environment   = local.environment
  project_name  = var.project_name
  vpc_cidr      = "10.0.0.0/16"
  
  tags = local.common_tags
}

# Security module
module "security" {
  source = "../../modules/security"
  
  environment  = local.environment
  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
  
  tags = local.common_tags
}

# Cloudflare Edge Services
module "cloudflare" {
  source = "../../modules/cloudflare"
  
  domain_name  = var.domain_name
  environment  = local.environment
  
  # Dev environment uses subdomain
  zone_name = "${local.environment}.${var.domain_name}"
}

# Data storage setup
module "data" {
  source = "../../modules/data"
  
  environment  = local.environment
  project_name = var.project_name
  
  tags = local.common_tags
}

# Variables specific to dev environment
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "mini-org-capability"
}

variable "domain_name" {
  description = "Primary domain name"
  type        = string
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  value       = module.cloudflare.zone_id
}