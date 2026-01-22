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
# ¦ PACKAGE IDENTIFIER
# ---------------------------------------------------------------------------------------------------------------------
resource "random_uuid" "module_id" {}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMPILE PROVISIO PACKAGES
# ---------------------------------------------------------------------------------------------------------------------
locals {
  resource_tags = templatefile("${path.module}/templates/tags.tf.tftpl", {
    map_of_tags = merge(
      var.resource_tags,
      {
        "module_provider" = "ACAI GmbH",
        "module_name"     = "terraform-aws-acf-account-hardening",
        "module_source"   = "github.com/acai-solutions/terraform-aws-acf-hardening",
        "module_version"  = /*inject_version_start*/ "1.0.0" /*inject_version_end*/
      }
    )
  })

  secondary_regions = var.provisio_settings.target_regions.secondary_regions
  all_regions = sort(distinct(concat(
    [var.provisio_settings.target_regions.primary_region],
    var.provisio_settings.target_regions.secondary_regions
  )))

  primary_region_formatted    = lower(replace(var.provisio_settings.target_regions.primary_region, "-", "_"))
  secondary_regions_formatted = [for region in var.provisio_settings.target_regions.secondary_regions : lower(replace(region, "-", "_"))]
  all_regions_formatted = sort(distinct(concat(
    [lower(replace(var.provisio_settings.target_regions.primary_region, "-", "_"))],
    [for region in var.provisio_settings.target_regions.secondary_regions : lower(replace(region, "-", "_"))]
  )))

  tf_module_name = replace(var.provisio_settings.override_module_name == null ? var.provisio_settings.package_name : var.provisio_settings.override_module_name, "-", "_")

  package_files = merge(
    {
      "main.tf" = templatefile("${path.module}/templates/main.tf.tftpl", {
        terraform_version     = var.provisio_settings.terraform_version,
        provider_aws_version  = var.provisio_settings.provider_aws_version,
        all_regions_formatted = local.all_regions_formatted
        resource_tags         = local.resource_tags

      })
    },
    var.account_hardening_settings.account_password_policy == null ? {} : {
      "aws_account_password_policy.tf" = templatefile("${path.module}/templates/aws_account_password_policy.tf.tftpl", {
        primary_region_formatted       = local.primary_region_formatted
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
    var.account_hardening_settings.aws_support_access_role == null ? {} : {
      "aws_support_access_role.tf.tf" = templatefile("${path.module}/templates/aws_support_access_role.tf.tf.tftpl", {
        primary_region_formatted      = local.primary_region_formatted
        trust_principal_string        = var.account_hardening_settings.aws_support_access_role.trust_principal_string
        resource_tags  = local.resource_tags
      })
    },
    var.account_hardening_settings.ebs_encryption == null ? {} : {
      "ebs_encryption.tf" = templatefile("${path.module}/templates/ebs_encryption.tf.tftpl", {
        primary_region_formatted = local.primary_region_formatted
        secondary_regions        = try(var.account_hardening_settings.ebs_encryption.secondary_regions_override, local.secondary_regions)
      })
    },
    var.account_hardening_settings.guardduty == null ? {} : {
      "guardduty.tf" = templatefile("${path.module}/templates/guardduty.tf.tftpl", {
        primary_region_formatted = local.primary_region_formatted
        secondary_regions        = try(var.account_hardening_settings.ebs_encryption.secondary_regions_override, local.secondary_regions)
      })
    },
    var.account_hardening_settings.s3_account_level_public_access_block == null ? {} : {
      "s3_account_level_pab.tf" = templatefile("${path.module}/templates/s3_account_level_pab.tf.tftpl", {
        primary_region_formatted = local.primary_region_formatted
        secondary_regions        = try(var.account_hardening_settings.s3_account_level_public_access_block.secondary_regions_override, local.secondary_regions)
      })
    },
    var.account_hardening_settings.security_hub_cspm == null ? {} : {
      "security_hub_cspm.tf" = templatefile("${path.module}/templates/security_hub_cspm.tf.tftpl", {
        primary_region            = var.provisio_settings.provisio_regions.primary_region
        secondary_regions         = try(var.account_hardening_settings.security_hub_cspm.secondary_regions_override, local.secondary_regions)
        enable_default_standards  = var.account_hardening_settings.security_hub_cspm.enable_default_standards
        auto_enable_controls      = var.account_hardening_settings.security_hub_cspm.auto_enable_controls
        control_finding_generator = var.account_hardening_settings.security_hub_cspm.control_finding_generator
      })
    },
  )
}

