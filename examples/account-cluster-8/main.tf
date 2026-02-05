# ACAI Cloud Foundation (ACF) - Example 8: PCI-DSS Compliant
# Use Case: Accounts processing payment card data

terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE CALL
# ---------------------------------------------------------------------------------------------------------------------
module "account_hardening" {
  source = "../../"

  provisio_settings = {
    package_name      = "account-hardening-pci"
    terraform_version = ">= 1.3.10"
    target_regions = {
      primary_region    = "eu-central-1"
      secondary_regions = ["eu-west-1", "us-east-1"]
    }
    import_resources = false
  }

  account_hardening_settings = {
    # PCI-DSS compliant password policy
    # Reference: PCI DSS Requirement 8.2
    aws_account_password_policy = {
      minimum_password_length        = 12  # PCI DSS minimum (was 7, now 12 recommended)
      max_password_age               = 90  # PCI DSS Requirement 8.2.4
      password_reuse_prevention      = 4   # PCI DSS Requirement 8.2.5
      require_lowercase_characters   = true
      require_numbers                = true
      require_uppercase_characters   = true
      require_symbols                = true # Complexity requirement
      allow_users_to_change_password = true
    }
    aws_support_access_role = {
      trust_principal_string = "arn:aws:iam::111111111111:root"
    }
    # PCI DSS Requirement 3.4 - Encryption at rest
    ebs_encryption = {}
    # PCI DSS Requirement 10 - Logging and monitoring
    guardduty = {
      aggregation_account_id       = "111111111111"
      enable_s3_logs               = true  # PCI DSS Requirement 10.2
      enable_kubernetes            = true
      enable_ebs_volume_protection = true
    }
    # PCI DSS Requirement 1.3 - Prohibit public access
    s3_account_level_public_access_block = {}
    # PCI DSS Requirement 11 - Security monitoring
    security_hub_cspm = {
      aggregation_account_id    = "111111111111"
      enable_default_standards  = true  # Enable PCI DSS standard
      auto_enable_controls      = true
      control_finding_generator = "SECURITY_CONTROL"
    }
    service_linked_roles = {
      service_names = [
        "guardduty.amazonaws.com",
        "securityhub.amazonaws.com",
        "config.amazonaws.com",
        "cloudtrail.amazonaws.com"
      ]
    }
  }

  resource_tags = {
    Environment      = "production"
    ManagedBy        = "terraform"
    UseCase          = "pci-dss"
    ComplianceType   = "PCI-DSS"
    ComplianceLevel  = "Level-1"
    CardholderData   = "in-scope"
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
