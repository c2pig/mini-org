terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  # Configure Terraform Cloud backend
  cloud {
    organization = "mini-org-capability"
    
    workspaces {
      tags = ["platform"]
    }
  }
}

# Default AWS provider configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "mini-org-capability"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "platform-team"
    }
  }
}

# Cloudflare provider configuration
provider "cloudflare" {
  # API token should be set via CLOUDFLARE_API_TOKEN environment variable
}

# Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "mini-org-capability"
}