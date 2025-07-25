# Getting Started with Mini Org Capability

## Prerequisites

Before you begin, ensure you have:

1. **AWS Account**: With billing alerts configured
2. **Terraform Cloud Account**: Free tier workspace
3. **Cloudflare Account**: Free tier with domain management
4. **GitHub Account**: For repository and CI/CD
5. **Okta Developer Account**: Free tier for workforce SSO

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/your-org/mini-org-capability.git
cd mini-org-capability
```

### 2. Configure Terraform Cloud

1. Create workspace in Terraform Cloud
2. Set environment variables:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `CLOUDFLARE_API_TOKEN`

### 3. Set Up GitHub Secrets

Add the following secrets to your GitHub repository:

```bash
TF_API_TOKEN=your-terraform-cloud-token
CLOUDFLARE_API_TOKEN=your-cloudflare-token
```

### 4. Configure Variables

Update `infrastructure/environments/dev/terraform.tfvars`:

```hcl
domain_name = "your-domain.com"
project_name = "mini-org-capability"
```

## Deployment

### Development Environment

```bash
cd infrastructure/environments/dev
terraform init
terraform plan
terraform apply
```

### Production Environment

1. Create pull request with changes
2. Review terraform plan in PR comments
3. Merge to main branch for automatic deployment

## Verification

### Check AWS Resources

```bash
# List VPCs
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=mini-org-capability"

# List S3 buckets
aws s3 ls | grep mini-org-capability

# Check security groups
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=mini-org-capability"
```

### Check Cloudflare Configuration

1. Log into Cloudflare dashboard
2. Verify DNS records for your domain
3. Check WAF rules are active
4. Confirm SSL/TLS settings

## Next Steps

### Phase 2: Core Platform

1. **Deploy EKS Cluster**:
   ```bash
   cd infrastructure/modules/compute
   terraform init
   terraform apply
   ```

2. **Install ArgoCD**:
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

3. **Deploy Backstage**:
   ```bash
   helm repo add backstage https://backstage.github.io/charts
   helm install backstage backstage/backstage
   ```

### Monitoring Setup

1. **Configure Datadog**:
   - Install Datadog agent on EKS
   - Set up dashboards for infrastructure metrics
   - Configure alerts for critical services

2. **Set up Log Aggregation**:
   - Configure CloudWatch log groups
   - Set up log forwarding to Datadog
   - Create log-based alerts

### Cost Optimization

1. **Enable Cost Explorer**:
   - Set up daily cost reports
   - Configure budget alerts
   - Tag resources for cost tracking

2. **Implement Lifecycle Policies**:
   - S3 data archiving rules
   - EBS snapshot cleanup
   - Unused resource identification

## Troubleshooting

### Common Issues

1. **Terraform State Lock**:
   ```bash
   terraform force-unlock LOCK_ID
   ```

2. **AWS Permissions**:
   - Verify IAM policies are correct
   - Check CloudTrail for denied actions

3. **Cloudflare API Limits**:
   - Monitor API usage in dashboard
   - Implement retry logic in CI/CD

### Support Channels

- **Issues**: GitHub Issues in this repository
- **Documentation**: `/docs` directory
- **Runbooks**: `/docs/runbooks` for operational procedures

## Security Checklist

- [ ] MFA enabled on all accounts
- [ ] AWS root account secured
- [ ] Terraform state encrypted
- [ ] Secrets stored in secure locations
- [ ] Regular security scans enabled
- [ ] Incident response plan documented

## Maintenance Schedule

- **Daily**: Monitor alerts and costs
- **Weekly**: Review security logs and access
- **Monthly**: Update dependencies and patches
- **Quarterly**: Architecture review and optimization