# Account Hardening Examples

This folder contains 10 example configurations demonstrating various use cases for the `terraform-aws-acf-account-hardening` module.

## Example Overview

| Example | Use Case | Features Enabled | Regions |
|---------|----------|------------------|---------|
| [account-cluster-1](./account-cluster-1/) | Standard Enterprise | All features | EU + US |
| [account-cluster-2](./account-cluster-2/) | Multi-Region Enterprise | All features | EU + US + APAC |
| [account-cluster-3](./account-cluster-3/) | Minimal - Password Policy Only | Password Policy | Single region |
| [account-cluster-4](./account-cluster-4/) | EU-Only GDPR Compliant | All features | EU only |
| [account-cluster-5](./account-cluster-5/) | Global Multi-Region | All features | All major regions |
| [account-cluster-6](./account-cluster-6/) | Sandbox/Dev Accounts | Minimal security | Single region |
| [account-cluster-7](./account-cluster-7/) | Production High-Security | All features + strict settings | EU + US |
| [account-cluster-8](./account-cluster-8/) | PCI-DSS Compliant | All features + PCI settings | EU + US |
| [account-cluster-9](./account-cluster-9/) | With Exclusions | All features + account exclusions | EU + US |
| [account-cluster-10](./account-cluster-10/) | Import Existing Resources | All features + import scripts | EU + US |
| [account-cluster-11](./account-cluster-11/) | Secondary Regions Override | Different regions per feature | Mixed |

---

## Example Details

### account-cluster-1: Standard Enterprise
**Use Case:** Default enterprise configuration with balanced security settings.
- Password policy with CIS AWS benchmarks
- EBS encryption in all regions
- GuardDuty with S3 and Kubernetes monitoring
- S3 public access block
- Security Hub CSPM

### account-cluster-2: Multi-Region Enterprise
**Use Case:** Enterprise with presence in EU, US, and APAC regions.
- Extended to Asia-Pacific regions
- GuardDuty with S3 monitoring only (cost optimization)
- No S3 public access block (for legacy S3 websites)

### account-cluster-3: Minimal - Password Policy Only
**Use Case:** Accounts that only need IAM password policy enforcement.
- Only password policy enabled
- Single region deployment
- Useful for legacy accounts transitioning to full hardening

### account-cluster-4: EU-Only GDPR Compliant
**Use Case:** European accounts with GDPR compliance requirements.
- Only EU regions (eu-central-1, eu-west-1, eu-north-1)
- All security features enabled
- Strict password policy (14-day max age)

### account-cluster-5: Global Multi-Region
**Use Case:** Global organization with presence in all major AWS regions.
- All commercial AWS regions
- Full security coverage
- AWS Support Access Role for global support

### account-cluster-6: Sandbox/Dev Accounts
**Use Case:** Development and sandbox accounts with relaxed security.
- Minimal features enabled
- Single region
- Extended password age (180 days)
- No GuardDuty (cost saving for dev)

### account-cluster-7: Production High-Security
**Use Case:** Production accounts requiring maximum security.
- All features enabled with strictest settings
- Short password age (60 days)
- 10 password reuse prevention
- All GuardDuty protections enabled
- Security Hub with default standards

### account-cluster-8: PCI-DSS Compliant
**Use Case:** Accounts processing payment card data.
- PCI-DSS compliant password policy (12 chars, 90 days)
- All encryption features
- Full GuardDuty protection
- Security Hub default standards enabled
- Service linked roles for compliance services

### account-cluster-9: With Exclusions
**Use Case:** Organization with legacy accounts requiring exclusions.
- Multiple account exclusions per feature
- Different exclusion lists per security control
- Useful for gradual rollout

### account-cluster-10: Import Existing Resources
**Use Case:** Accounts with existing security resources to import.
- `import_resources = true` generates import scripts
- Import scripts in `import.part` file
- Useful for brownfield deployments

### account-cluster-11: Secondary Regions Override
**Use Case:** Different features require different regional coverage.
- Demonstrates `secondary_regions_override` for per-feature region control
- EBS encryption: EU only (GDPR compliance - no US data storage)
- GuardDuty: Extended to APAC for comprehensive threat monitoring
- Security Hub: Primary region only (cost optimization)
- Useful for compliance, cost optimization, or phased rollouts

---

## Usage

1. Navigate to the desired example folder
2. Run `terraform init`
3. Run `terraform plan` to preview
4. Run `terraform apply` to generate rendered Terraform files
5. The rendered files will be in the `rendered-tf/` subfolder

```bash
cd account-cluster-1
terraform init
terraform apply --auto-approve
ls rendered-tf/
```

## Output Files

Each example generates the following files in `rendered-tf/`:
- `main.tf` - Provider and locals configuration
- `aws_account_password_policy.tf` - IAM password policy (if enabled)
- `ebs_encryption.tf` - EBS encryption settings (if enabled)
- `guardduty.tf` - GuardDuty detector configuration (if enabled)
- `s3_account_level_pab.tf` - S3 public access block (if enabled)
- `security_hub_cspm.tf` - Security Hub configuration (if enabled)
- `service_linked_role.tf` - Service linked roles (if enabled)
- `import.part` - Import commands (if `import_resources = true`)

---

## LLM-Based Validation

Each example includes an `expected.yaml` file that defines the expected behavior. The validation script uses an LLM to semantically validate that the rendered Terraform matches the use case.

### Setup

```bash
pip install -r requirements.txt
```

### Environment Variables

For OpenAI:
```bash
export OPENAI_API_KEY="your-api-key"
```

For Azure OpenAI (optional):
```bash
export AZURE_OPENAI_ENDPOINT="https://your-endpoint.openai.azure.com/"
export AZURE_OPENAI_API_KEY="your-api-key"
export AZURE_OPENAI_DEPLOYMENT="gpt-4o"
```

### Running Validation

```bash
# Validate all examples
python validate_examples.py --provider openai

# Validate specific example
python validate_examples.py --provider openai --example account-cluster-1

# Use Azure OpenAI instead
python validate_examples.py --provider azure
```

### GitHub Actions

The `.github/workflows/validate-examples.yml` workflow automatically:
1. Generates rendered Terraform for all examples
2. Runs LLM semantic validation
3. Runs standard `terraform validate`
4. Posts results as PR comments

Required secrets:
- `OPENAI_API_KEY`
