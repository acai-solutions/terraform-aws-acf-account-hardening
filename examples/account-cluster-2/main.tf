# ACAI Cloud Foundation (ACF) - Example
# This example calls the account-hardening module and writes output files to "rendered-tf" folder

terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE CALL
# ---------------------------------------------------------------------------------------------------------------------
module "account_hardening" {
  source = "../../"

  provisio_settings = {
    package_name      = "account-hardening"
    terraform_version = ">= 1.3.10"
    target_regions = {
      primary_region    = "eu-central-1"
      secondary_regions = ["eu-west-1", "us-east-1", "ap-southeast-1"]
    }
    import_resources = false
  }

  account_hardening_settings = {
    aws_account_password_policy = {
      minimum_password_length      = 16
      max_password_age             = 90
      password_reuse_prevention    = 5
      require_lowercase_characters = true
      require_numbers              = true
      require_uppercase_characters = true
      require_symbols              = true
    }
    ebs_encryption = {
      excluded_accounts = [
        "890123456789"
      ]
    }
    guardduty = {
      aggregation_account_id       = "123456789012"
      enable_s3_logs               = true
      enable_kubernetes            = false
      enable_ebs_volume_protection = false
    }
    security_hub_cspm = {
      aggregation_account_id    = "123456789012"
      enable_default_standards  = false
      auto_enable_controls      = false
      control_finding_generator = "SECURITY_CONTROL"
    }
  }

  resource_tags = {
    Environment = "example"
    ManagedBy   = "terraform"
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
