# ACAI Cloud Foundation (ACF) - Example 10: Import Existing Resources
# Use Case: Accounts with existing security resources to import (brownfield deployment)

terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE CALL
# ---------------------------------------------------------------------------------------------------------------------
module "account_hardening" {
  source = "../../"

  provisio_settings = {
    package_name      = "account-hardening-import"
    terraform_version = ">= 1.3.10"
    target_regions = {
      primary_region    = "eu-central-1"
      secondary_regions = ["eu-west-1", "us-east-1"]
    }
    # Enable import script generation for brownfield deployment
    import_resources = true
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
  }

  resource_tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    UseCase     = "brownfield-import"
    Migration   = "in-progress"
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

output "import_instructions" {
  value = <<-EOT
    
    ================================================================================
    IMPORT INSTRUCTIONS FOR BROWNFIELD DEPLOYMENT
    ================================================================================
    
    1. Navigate to the rendered-tf folder:
       cd rendered-tf
    
    2. Initialize Terraform:
       terraform init
    
    3. Review the import.part file for import commands:
       cat import.part
    
    4. Execute the import commands (requires AWS credentials):
       # The import.part file contains commands like:
       # terraform import aws_iam_account_password_policy.account_password_policy iam-account-password-policy
       # terraform import aws_ebs_encryption_by_default.default_ebs_encryption_eu_central_1 default
       # etc.
    
    5. After importing, run plan to verify:
       terraform plan
    
    6. Apply any necessary changes:
       terraform apply
    
    ================================================================================
  EOT
}
