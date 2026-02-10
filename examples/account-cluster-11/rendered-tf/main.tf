# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.00"
      configuration_aliases = [
        aws
      ]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  tags = {
    "Environment"     = "example",
    "ManagedBy"       = "terraform",
    "Note"            = "Different region coverage per feature",
    "UseCase"         = "secondary-regions-override",
    "module_name"     = "terraform-aws-acf-account-hardening",
    "module_provider" = "ACAI GmbH",
    "module_source"   = "github.com/acai-solutions/terraform-aws-acf-hardening",
    "module_version"  = "1.0.0"

  }
  current_account_id = data.aws_caller_identity.current.account_id
}

