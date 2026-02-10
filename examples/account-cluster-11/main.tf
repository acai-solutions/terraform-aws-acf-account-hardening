# ACAI Cloud Foundation (ACF) - Example 11: Secondary Regions Override
# Use Case: Different features require different regional coverage

terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE CALL
# ---------------------------------------------------------------------------------------------------------------------
# This example demonstrates the secondary_regions_override feature.
# 
# Scenario: 
# - Global target regions: eu-central-1 (primary), eu-west-1, us-east-1
# - EBS encryption: Only in EU (compliance requirement - no US data storage)
# - GuardDuty: Extended to APAC for threat monitoring
# - Security Hub: Only primary region (cost optimization)
#
# This is useful when:
# - Different compliance requirements per feature
# - Cost optimization (some features only in specific regions)
# - Phased rollout (start with core regions, expand later)

module "account_hardening" {
  source = "../../"

  provisio_settings = {
    package_name      = "account-hardening-region-override"
    terraform_version = ">= 1.3.10"
    target_regions = {
      primary_region    = "eu-central-1"
      secondary_regions = ["eu-west-1", "us-east-1"] # Default for most features
    }
    import_resources = false
  }

  account_hardening_settings = {
    # Password policy - global, no region override needed
    aws_account_password_policy = {
      minimum_password_length        = 16
      max_password_age               = 90
      password_reuse_prevention      = 5
      require_lowercase_characters   = true
      require_numbers                = true
      require_uppercase_characters   = true
      require_symbols                = true
      allow_users_to_change_password = true
    }

    # EBS Encryption - EU only (GDPR compliance, no US data storage)
    ebs_encryption = {
      secondary_regions_override = ["eu-west-1", "eu-north-1"] # Override: EU only, no us-east-1
    }

    # GuardDuty - Extended to APAC for comprehensive threat monitoring
    guardduty = {
      aggregation_account_id       = "123456789012"
      secondary_regions_override   = ["eu-west-1", "us-east-1", "ap-southeast-1", "ap-northeast-1"] # Extended to APAC
      enable_s3_logs               = true
      enable_kubernetes            = true
      enable_ebs_volume_protection = true
    }

    # S3 Public Access Block - uses default regions (eu-west-1, us-east-1)
    s3_account_level_public_access_block = {}

    # Security Hub - primary region only (cost optimization)
    security_hub_cspm = {
      aggregation_account_id     = "123456789012"
      secondary_regions_override = [] # Empty = primary region only
      enable_default_standards   = false
      auto_enable_controls       = false
      control_finding_generator  = "SECURITY_CONTROL"
    }
  }

  resource_tags = {
    Environment = "example"
    ManagedBy   = "terraform"
    UseCase     = "secondary-regions-override"
    Note        = "Different region coverage per feature"
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

output "region_configuration" {
  description = "Shows the different region configurations per feature"
  value = {
    default_regions        = ["eu-central-1", "eu-west-1", "us-east-1"]
    ebs_encryption_regions = ["eu-central-1", "eu-west-1", "eu-north-1"]
    guardduty_regions      = ["eu-central-1", "eu-west-1", "us-east-1", "ap-southeast-1", "ap-northeast-1"]
    security_hub_regions   = ["eu-central-1"] # primary only
  }
}
