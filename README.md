# Mini Org Capability - Bootstrap Platform

A managed services first approach to enterprise platform capabilities using free tiers and open-source solutions.

## Overview

This repository implements the bootstrap phase of the platform architecture plan, focusing on:

- **Identity & Access Management**: Okta for workforce, Auth0/Cognito for customers
- **Cloud Infrastructure**: AWS with Terraform Cloud
- **Edge Services**: Cloudflare CDN, WAF, and API Gateway
- **GitOps**: Infrastructure as Code with automated deployments

## Architecture Principles

1. **Managed Services First**: Minimize infrastructure management
2. **Free Tier Optimization**: Leverage generous free tiers from major providers
3. **GitOps**: All changes through version control and automation
4. **Infrastructure as Code**: Reproducible, versioned infrastructure
5. **Self-Service**: Enable teams to provision resources independently

## Repository Structure

```
├── infrastructure/           # Terraform code
│   ├── environments/        # Environment-specific configs
│   │   ├── dev/
│   │   ├── staging/
│   │   └── production/
│   └── modules/            # Reusable Terraform modules
│       ├── networking/
│       ├── compute/
│       ├── data/
│       └── security/
├── kubernetes/             # Kubernetes manifests
│   ├── base/
│   ├── overlays/
│   └── applications/
├── .github/               # GitHub Actions workflows
│   └── workflows/
└── docs/                  # Documentation
    ├── architecture/
    ├── runbooks/
    └── decisions/
```

## Getting Started

### Prerequisites

- AWS Account with appropriate billing alerts
- Terraform Cloud workspace
- Cloudflare account
- Okta developer account
- GitHub organization

### Phase 1: Foundation Setup

1. **Identity & Access**
   - Configure Okta for workforce SSO
   - Set up Auth0/Cognito for customer authentication
   - Establish SSO for critical services

2. **Cloud Infrastructure**
   - Deploy AWS account structure
   - Configure Terraform Cloud workspace
   - Set up basic networking and security groups

3. **Edge Services**
   - Configure Cloudflare DNS and CDN
   - Set up WAF rules
   - Deploy API Gateway

## Cost Optimization

- **Development**: $0-50/month (mostly free tiers)
- **Small Production**: $100-200/month (< 100 users)
- **Medium Production**: $500-1,000/month (1,000 users)

## Security

- MFA required for workforce access
- Zero Trust architecture
- Encryption in transit and at rest
- Regular security reviews and updates

## Contributing

1. Create feature branch
2. Make changes following IaC principles
3. Test in development environment
4. Submit PR with documentation updates
5. Deploy via GitOps pipeline

## Support

For issues and questions, please refer to the runbooks in `docs/runbooks/` or create an issue in this repository.