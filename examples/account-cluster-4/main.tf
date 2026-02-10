# ACAI Cloud Foundation (ACF) - Example 4: EU-Only GDPR Compliant
# Use Case: European accounts with GDPR compliance requirements

terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE CALL
# ---------------------------------------------------------------------------------------------------------------------
module "account_hardening" {
  source = "../../"

  provisio_settings = {
    package_name      = "account-hardening-eu-gdpr"
    terraform_version = ">= 1.3.10"
    target_regions = {
      primary_region    = "eu-central-1"
      secondary_regions = ["eu-west-1", "eu-north-1", "us-east-1"]
    }
    import_resources = false
  }

  account_hardening_settings = {
    aws_account_password_policy = {
      minimum_password_length        = 16
      max_password_age               = 60 # Stricter for GDPR
      password_reuse_prevention      = 10 # Stricter for GDPR
      require_lowercase_characters   = true
      require_numbers                = true
      require_uppercase_characters   = true
      require_symbols                = true
      allow_users_to_change_password = true
    }
    ebs_encryption = {
      # All EU regions - no exclusions for GDPR compliance
    }
    guardduty = {
      aggregation_account_id       = "111111111111"
      enable_s3_logs               = true
      enable_kubernetes            = true
      enable_ebs_volume_protection = true
    }
    s3_account_level_public_access_block = {
      # No exclusions - all S3 buckets must be private for GDPR
    }
    security_hub_cspm = {
      aggregation_account_id    = "111111111111"
      enable_default_standards  = true # Enable for compliance
      auto_enable_controls      = true
      control_finding_generator = "SECURITY_CONTROL"
    }
  }

  resource_tags = {
    Environment    = "production"
    ManagedBy      = "terraform"
    UseCase        = "gdpr-compliant"
    DataResidency  = "EU"
    ComplianceType = "GDPR"
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
