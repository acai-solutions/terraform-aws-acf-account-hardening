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
  resource_tags = templatefile("${path.module}/templates/_tags.tf.tftpl", {
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

  tf_module_name = replace(var.provisio_settings.override_module_name == null ? var.provisio_settings.package_name : var.provisio_settings.override_module_name, "-", "_")

  regions = {
    ebs_encryption = var.account_hardening_settings.ebs_encryption != null ? sort(distinct(concat(
      [var.provisio_settings.target_regions.primary_region],
      coalesce(var.account_hardening_settings.ebs_encryption.secondary_regions_override, local.secondary_regions)
    ))) : []
    guardduty = var.account_hardening_settings.guardduty != null ? sort(distinct(concat(
      [var.provisio_settings.target_regions.primary_region],
      coalesce(var.account_hardening_settings.guardduty.secondary_regions_override, local.secondary_regions)
    ))) : []
    security_hub_cspm = var.account_hardening_settings.security_hub_cspm != null ? sort(distinct(concat(
      [var.provisio_settings.target_regions.primary_region],
      coalesce(var.account_hardening_settings.security_hub_cspm.secondary_regions_override, local.secondary_regions)
    ))) : []
  }


  package_files = merge(
    var.provisio_settings.import_resources ? ({
      "import.part" = templatefile("${path.module}/templates/_import.part.tftpl", {
        tf_module_name                               = local.tf_module_name
        aws_account_password_policy_enabled          = var.account_hardening_settings.aws_account_password_policy != null ? true : false
        ebs_encryption_enabled                       = var.account_hardening_settings.ebs_encryption != null ? true : false
        ebs_encryption_regions                       = local.regions.ebs_encryption
        guardduty_enabled                            = var.account_hardening_settings.guardduty != null ? true : false
        guardduty_regions                            = local.regions.guardduty
        s3_account_level_public_access_block_enabled = var.account_hardening_settings.guardduty != null ? var.account_hardening_settings.guardduty.enable_s3_logs : null
        security_hub_cspm_enabled                    = var.account_hardening_settings.security_hub_cspm != null ? true : false
        security_hub_cspm_regions                    = local.regions.security_hub_cspm
      })
      }) : ({
      "import.part" = ""
    }),
    {
      "main.tf" = templatefile("${path.module}/templates/main.tf.tftpl", {
        terraform_version    = var.provisio_settings.terraform_version,
        provider_aws_version = var.provisio_settings.provider_aws_version,
        resource_tags        = local.resource_tags
      })
    },
    var.account_hardening_settings.aws_account_password_policy == null ? {} : {
      "aws_account_password_policy.tf" = templatefile("${path.module}/templates/aws_account_password_policy.tf.tftpl", {
        excluded_accounts              = var.account_hardening_settings.aws_account_password_policy.excluded_accounts
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
      "aws_support_access_role.tf" = templatefile("${path.module}/templates/aws_support_access_role.tf.tftpl", {
        excluded_accounts      = var.account_hardening_settings.aws_support_access_role.excluded_accounts
        trust_principal_string = var.account_hardening_settings.aws_support_access_role.trust_principal_string
      })
    },
    var.account_hardening_settings.ebs_encryption == null ? {} : {
      "ebs_encryption.tf" = templatefile("${path.module}/templates/ebs_encryption.tf.tftpl", {
        excluded_accounts = var.account_hardening_settings.ebs_encryption.excluded_accounts
        all_regions       = local.regions.ebs_encryption
      })
    },
    var.account_hardening_settings.guardduty == null ? {} : {
      "guardduty.tf" = templatefile("${path.module}/templates/guardduty.tf.tftpl", {
        excluded_accounts            = var.account_hardening_settings.guardduty.excluded_accounts
        aggregation_account_id       = var.account_hardening_settings.guardduty.aggregation_account_id
        all_regions                  = local.regions.guardduty
        enable_s3_logs               = var.account_hardening_settings.guardduty.enable_s3_logs
        enable_kubernetes            = var.account_hardening_settings.guardduty.enable_kubernetes
        enable_ebs_volume_protection = var.account_hardening_settings.guardduty.enable_ebs_volume_protection
      })
    },
    var.account_hardening_settings.s3_account_level_public_access_block == null ? {} : {
      "s3_account_level_pab.tf" = templatefile("${path.module}/templates/s3_account_level_pab.tf.tftpl", {
        excluded_accounts = var.account_hardening_settings.s3_account_level_public_access_block.excluded_accounts
      })
    },
    var.account_hardening_settings.security_hub_cspm == null ? {} : {
      "security_hub_cspm.tf" = templatefile("${path.module}/templates/security_hub_cspm.tf.tftpl", {
        excluded_accounts         = var.account_hardening_settings.security_hub_cspm.excluded_accounts
        aggregation_account_id    = var.account_hardening_settings.security_hub_cspm.aggregation_account_id
        all_regions               = local.regions.security_hub_cspm
        enable_default_standards  = var.account_hardening_settings.security_hub_cspm.enable_default_standards
        auto_enable_controls      = var.account_hardening_settings.security_hub_cspm.auto_enable_controls
        control_finding_generator = var.account_hardening_settings.security_hub_cspm.control_finding_generator
      })
    },
    var.account_hardening_settings.service_linked_roles == null ? {} : {
      "service_linked_role.tf" = templatefile("${path.module}/templates/service_linked_role.tf.tftpl", {
        excluded_accounts = var.account_hardening_settings.service_linked_roles.excluded_accounts
        service_names     = var.account_hardening_settings.service_linked_roles.service_names
      })
    },
  )
}

