# ACAI Cloud Foundation (ACF) - Example 7: Production High-Security
# Use Case: Production accounts requiring maximum security

terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE CALL
# ---------------------------------------------------------------------------------------------------------------------
module "account_hardening" {
  source = "../../"

  provisio_settings = {
    package_name         = "account-hardening-prod-highsec"
    override_module_name = "prod_security"
    terraform_version    = ">= 1.5.0" # Require newer Terraform
    provider_aws_version = ">= 6.00"
    target_regions = {
      primary_region    = "eu-central-1"
      secondary_regions = ["eu-west-1", "us-east-1", "us-west-2"]
    }
    import_resources = false
  }

  account_hardening_settings = {
    # Strictest password policy
    aws_account_password_policy = {
      minimum_password_length        = 20 # Maximum security
      max_password_age               = 60 # Strict rotation
      password_reuse_prevention      = 10 # Maximum history
      require_lowercase_characters   = true
      require_numbers                = true
      require_uppercase_characters   = true
      require_symbols                = true
      allow_users_to_change_password = true
    }
    aws_support_access_role = {
      trust_principal_string = "arn:aws:iam::111111111111:root"
    }
    ebs_encryption = {
      # No exclusions - all volumes must be encrypted
    }
    guardduty = {
      aggregation_account_id       = "111111111111"
      enable_s3_logs               = true
      enable_kubernetes            = true
      enable_ebs_volume_protection = true
    }
    s3_account_level_public_access_block = {
      # No exclusions - all buckets must be private
    }
    security_hub_cspm = {
      aggregation_account_id    = "111111111111"
      enable_default_standards  = true # Enable all standards
      auto_enable_controls      = true # Auto-enable new controls
      control_finding_generator = "SECURITY_CONTROL"
    }
    service_linked_roles = {
      service_names = [
        "guardduty.amazonaws.com",
        "securityhub.amazonaws.com",
        "config.amazonaws.com",
        "macie.amazonaws.com",
        "inspector2.amazonaws.com"
      ]
    }
  }

  resource_tags = {
    Environment   = "production"
    ManagedBy     = "terraform"
    UseCase       = "high-security"
    SecurityLevel = "critical"
    DataClass     = "confidential"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ WRITE OUTPUT FILES TO rendered-tf FOLDER
# ---------------------------------------------------------------------------------------------------------------------
resource "local_file" "rendered_tf" {
  for_each = module.account_hardening.package_files

  filename = "${path.module}/rendered-tf/${each.key}"
  content  = each.value
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "package_id" {
  value = module.account_hardening.package_id
}

output "package_name" {
  value = module.account_hardening.package_name
}

output "rendered_files" {
  value = keys(module.account_hardening.package_files)
}
