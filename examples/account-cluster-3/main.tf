# ACAI Cloud Foundation (ACF) - Example 3: Minimal - Password Policy Only
# Use Case: Accounts that only need IAM password policy enforcement

terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE CALL
# ---------------------------------------------------------------------------------------------------------------------
module "account_hardening" {
  source = "../../"

  provisio_settings = {
    package_name      = "account-hardening-minimal"
    terraform_version = ">= 1.3.10"
    target_regions = {
      primary_region    = "eu-central-1"
      secondary_regions = []
    }
    import_resources = false
  }

  account_hardening_settings = {
    aws_account_password_policy = {
      minimum_password_length        = 14
      max_password_age               = 90
      password_reuse_prevention      = 5
      require_lowercase_characters   = true
      require_numbers                = true
      require_uppercase_characters   = true
      require_symbols                = true
      allow_users_to_change_password = true
    }
    # No other features enabled - minimal configuration
  }

  resource_tags = {
    Environment = "minimal"
    ManagedBy   = "terraform"
    UseCase     = "password-policy-only"
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
