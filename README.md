# Azure IaC Challenge

## Resources Deployed
- Azure VNet with public & private subnets
- App Service with default scaling
- Azure SQL DB
- Azure Storage with CORS
- Optional CPU Alert on App Service

## Deployment
```bash
terraform init
terraform plan
terraform apply -auto-approve

