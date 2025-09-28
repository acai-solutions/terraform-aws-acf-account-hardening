# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMPILE PROVISIO PACKAGES
# ---------------------------------------------------------------------------------------------------------------------
locals {
  non_primary_regions = tolist(setsubtract(var.provisio_settings.provisio_regions.regions, [var.provisio_settings.provisio_regions.primary_region]))
  provisio_package_files = merge(
    {
      "requirements.tf" = templatefile("${path.module}/templates/requirements.tf.tftpl", {
        terraform_version    = ">= 1.3.10",
        provider_aws_version = ">= 5.50",
        non_primary_regions  = local.non_primary_regions
      })
      "aws_account_password_policy.tf" = templatefile("${path.module}/templates/aws_account_password_policy.tf.tftpl", {
        primary_region                 = var.provisio_settings.provisio_regions.primary_region
        minimum_password_length        = var.account_hardening_settings.aws_account_password_policy.minimum_password_length
        max_password_age               = var.account_hardening_settings.aws_account_password_policy.max_password_age
        password_reuse_prevention      = var.account_hardening_settings.aws_account_password_policy.password_reuse_prevention
        require_lowercase_characters   = var.account_hardening_settings.aws_account_password_policy.require_lowercase_characters
        require_numbers                = var.account_hardening_settings.aws_account_password_policy.require_numbers
        require_uppercase_characters   = var.account_hardening_settings.aws_account_password_policy.require_uppercase_characters
        require_symbols                = var.account_hardening_settings.aws_account_password_policy.require_symbols
        allow_users_to_change_password = var.account_hardening_settings.aws_account_password_policy.allow_users_to_change_password
      })
    },
    var.account_hardening_settings.s3_account_level_public_access_block == false ? {} : {
      "s3_account_level_pab.tf" = templatefile("${path.module}/templates/s3_account_level_pab.tf.tftpl", {
        primary_region = var.provisio_settings.provisio_regions.primary_region
      })
    },
    var.account_hardening_settings.ebs_encryption == false ? {} : {
      "ebs_encryption.tf" = templatefile("${path.module}/templates/ebs_encryption.tf.tftpl", {
        primary_region      = var.provisio_settings.provisio_regions.primary_region
        non_primary_regions = local.non_primary_regions
      })
    }
  )
}

