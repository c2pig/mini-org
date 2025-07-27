# IAM Package

Identity and Access Management (IAM) package for the mini-org platform.

## Overview

This package provides comprehensive IAM functionality using Okta as the primary Identity Provider (IDP) with GitOps-driven user provisioning and SSO integration.

## Package Structure

```
packages/iam/
├── configs/
│   ├── users/               # User configuration files (YAML)
│   ├── groups/              # Group and role definitions
│   ├── applications/        # SSO application configurations
│   └── policies/           # Access policies
├── terraform/
│   ├── okta/               # Okta provider configurations
│   ├── aws-iam/            # AWS IAM integration
│   └── modules/            # Reusable IAM modules
├── scripts/
│   ├── provision-user.py   # User provisioning automation
│   ├── validate-config.py  # Configuration validation
│   └── sync-groups.py      # Group synchronization
└── docs/
    ├── onboarding.md       # User onboarding guide
    ├── rbac-model.md       # Role-based access control
    └── sso-setup.md        # SSO configuration guide
```

## Features

- **Okta Integration**: Primary IDP for workforce identity management
- **SSO Applications**: Cloudflare, Databricks, Segment.io, Oracle Cloud
- **GitOps Workflow**: User provisioning through configuration files
- **Role-Based Access Control**: Admin, Developer, Operator, Read-only, Privileged roles
- **Automated Provisioning**: CircleCI pipeline for user lifecycle management
- **Infrastructure as Code**: Terraform modules for reproducible deployments
- **Compliance**: Audit logging and compliance reporting

## Quick Start

### Prerequisites

- Okta tenant with API access
- Terraform Cloud workspace
- CircleCI project setup
- AWS credentials (for IAM integration)

### Configuration

1. **Environment Variables**:
   ```bash
   export OKTA_API_TOKEN="your-okta-api-token"
   export OKTA_ORG_NAME="your-org-name"
   export TF_CLOUD_TOKEN="your-terraform-cloud-token"
   ```

2. **User Configuration**:
   Create user YAML files in `configs/users/`:
   ```yaml
   apiVersion: iam.mini-org.com/v1
   kind: User
   metadata:
     name: user.name
   spec:
     profile:
       firstName: User
       lastName: Name
       email: user.name@company.com
     roles: [developer]
     groups: [developers, frontend-team]
   ```

3. **Deploy**:
   ```bash
   cd terraform/okta
   terraform init
   terraform plan -var-file="environments/dev.tfvars"
   terraform apply
   ```

## CI/CD Pipeline

The package includes automated workflows for:

- **Validation**: YAML schema validation and policy checks
- **Security Scanning**: Static analysis of scripts and configurations
- **Terraform Planning**: Infrastructure change previews
- **User Provisioning**: Automated user lifecycle management
- **Compliance Reporting**: Regular access reviews and audit reports

## Security

- **Multi-Factor Authentication**: Required for all users
- **IP Restrictions**: Network-based access controls
- **Session Management**: Configurable timeout policies
- **Emergency Access**: Break-glass procedures with approval workflows
- **Audit Logging**: Comprehensive activity tracking

## Support

For detailed implementation guidance, see the [IAM Implementation Plan](../../docs/iam-implementation-plan.md).

For issues and questions:
1. Check the troubleshooting guide in `docs/`
2. Review audit logs for access issues
3. Contact the IAM team via Slack `#iam-support`