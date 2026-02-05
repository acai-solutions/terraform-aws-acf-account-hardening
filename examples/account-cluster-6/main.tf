# ACAI Cloud Foundation (ACF) - Example 6: Sandbox/Dev Accounts
# Use Case: Development and sandbox accounts with relaxed security

terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE CALL
# ---------------------------------------------------------------------------------------------------------------------
module "account_hardening" {
  source = "../../"

  provisio_settings = {
    package_name      = "account-hardening-sandbox"
    terraform_version = ">= 1.3.10"
    target_regions = {
      primary_region    = "eu-central-1"
      secondary_regions = []  # Single region for cost savings
    }
    import_resources = false
  }

  account_hardening_settings = {
    # Relaxed password policy for dev accounts
    aws_account_password_policy = {
      minimum_password_length        = 12  # Minimum acceptable
      max_password_age               = 180 # Extended for dev convenience
      password_reuse_prevention      = 3   # Relaxed
      require_lowercase_characters   = true
      require_numbers                = true
      require_uppercase_characters   = true
      require_symbols                = false # Relaxed for dev
      allow_users_to_change_password = true
    }
    # Only EBS encryption - basic security
    ebs_encryption = {}
    # No GuardDuty - cost saving for sandbox
    # No Security Hub - cost saving for sandbox
    # S3 public access block disabled to allow dev experiments
  }

  resource_tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
    UseCase     = "development"
    CostCenter  = "dev-ops"
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
