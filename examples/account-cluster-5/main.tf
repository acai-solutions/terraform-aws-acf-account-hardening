# ACAI Cloud Foundation (ACF) - Example 5: Global Multi-Region
# Use Case: Global organization with presence in all major AWS regions

terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE CALL
# ---------------------------------------------------------------------------------------------------------------------
module "account_hardening" {
  source = "../../"

  provisio_settings = {
    package_name      = "account-hardening-global"
    terraform_version = ">= 1.3.10"
    target_regions = {
      primary_region = "eu-central-1"
      secondary_regions = [
        # Europe
        "eu-west-1", "eu-west-2", "eu-west-3", "eu-north-1",
        # Americas
        "us-east-1", "us-east-2", "us-west-1", "us-west-2", "ca-central-1", "sa-east-1",
        # Asia Pacific
        "ap-northeast-1", "ap-northeast-2", "ap-northeast-3",
        "ap-southeast-1", "ap-southeast-2", "ap-south-1"
      ]
    }
    import_resources = false
  }

  account_hardening_settings = {
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
    aws_support_access_role = {
      trust_principal_string = "arn:aws:iam::111111111111:root"
    }
    ebs_encryption = {}
    guardduty = {
      aggregation_account_id       = "111111111111"
      enable_s3_logs               = true
      enable_kubernetes            = true
      enable_ebs_volume_protection = true
    }
    s3_account_level_public_access_block = {}
    security_hub_cspm = {
      aggregation_account_id    = "111111111111"
      enable_default_standards  = false
      auto_enable_controls      = false
      control_finding_generator = "SECURITY_CONTROL"
    }
    service_linked_roles = {
      service_names = [
        "guardduty.amazonaws.com",
        "securityhub.amazonaws.com",
        "config.amazonaws.com"
      ]
    }
  }

  resource_tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    UseCase     = "global-deployment"
    Scope       = "worldwide"
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
