# ACAI Cloud Foundation (ACF) - Example 9: With Exclusions
# Use Case: Organization with legacy accounts requiring exclusions

terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS - Define exclusion lists
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Legacy accounts that cannot have password policy enforced
  legacy_password_policy_exclusions = [
    "111111111111", # Legacy Identity Account
    "222222222222", # External Partner Account
  ]

  # Accounts with existing EBS encryption key management
  ebs_encryption_exclusions = [
    "333333333333", # HSM-managed encryption account
  ]

  # Accounts that need public S3 buckets (static websites)
  s3_public_access_exclusions = [
    "444444444444", # Marketing Static Website
    "555555555555", # Public Documentation
    "666666666666", # Open Data Portal
  ]

  # Sandbox accounts excluded from GuardDuty (cost saving)
  guardduty_exclusions = [
    "777777777777", # Dev Sandbox 1
    "888888888888", # Dev Sandbox 2
  ]

  # Accounts excluded from Security Hub (managed separately)
  security_hub_exclusions = [
    "999999999999", # Security Operations Center
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE CALL
# ---------------------------------------------------------------------------------------------------------------------
module "account_hardening" {
  source = "../../"

  provisio_settings = {
    package_name      = "account-hardening-with-exclusions"
    terraform_version = ">= 1.3.10"
    target_regions = {
      primary_region    = "eu-central-1"
      secondary_regions = ["eu-west-1", "us-east-1"]
    }
    import_resources = false
  }

  account_hardening_settings = {
    aws_account_password_policy = {
      excluded_accounts              = local.legacy_password_policy_exclusions
      minimum_password_length        = 16
      max_password_age               = 90
      password_reuse_prevention      = 5
      require_lowercase_characters   = true
      require_numbers                = true
      require_uppercase_characters   = true
      require_symbols                = true
      allow_users_to_change_password = true
    }
    ebs_encryption = {
      excluded_accounts = local.ebs_encryption_exclusions
    }
    guardduty = {
      excluded_accounts            = local.guardduty_exclusions
      aggregation_account_id       = "111111111111"
      enable_s3_logs               = true
      enable_kubernetes            = true
      enable_ebs_volume_protection = true
    }
    s3_account_level_public_access_block = {
      excluded_accounts = local.s3_public_access_exclusions
    }
    security_hub_cspm = {
      excluded_accounts         = local.security_hub_exclusions
      aggregation_account_id    = "111111111111"
      enable_default_standards  = false
      auto_enable_controls      = false
      control_finding_generator = "SECURITY_CONTROL"
    }
  }

  resource_tags = {
    Environment = "mixed"
    ManagedBy   = "terraform"
    UseCase     = "gradual-rollout"
    Note        = "Contains exclusions for legacy accounts"
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

output "exclusion_summary" {
  value = {
    password_policy_exclusions  = length(local.legacy_password_policy_exclusions)
    ebs_encryption_exclusions   = length(local.ebs_encryption_exclusions)
    s3_public_access_exclusions = length(local.s3_public_access_exclusions)
    guardduty_exclusions        = length(local.guardduty_exclusions)
    security_hub_exclusions     = length(local.security_hub_exclusions)
  }
}
