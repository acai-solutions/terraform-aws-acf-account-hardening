# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


variable "provisio_settings" {
  description = "ACAI PROVISIO settings"
  type = object({
    package_name         = optional(string, "account-hardening")
    override_module_name = optional(string, null)
    terraform_version    = optional(string, ">= 1.3.10")
    provider_aws_version = optional(string, ">= 6.00")
    target_regions = object({
      primary_region    = string
      secondary_regions = list(string)
    })
    import_resources = optional(bool, false)
  })
}

variable "account_hardening_settings" {
  description = "Account hardening settings"
  type = object({
    aws_account_password_policy = optional(
      object({
        # compliant with CIS AWS 
        excluded_accounts              = optional(list(string), []) # list of account-ids that will be exempted from Password Policy
        minimum_password_length        = optional(number, 16)
        max_password_age               = optional(number, 90) 
        password_reuse_prevention      = optional(number, 24) 
        require_lowercase_characters   = optional(bool, true)
        require_numbers                = optional(bool, true)
        require_uppercase_characters   = optional(bool, true)
        require_symbols                = optional(bool, true)
        allow_users_to_change_password = optional(bool, true)
      }), null
    )
    aws_support_access_role = optional(
      object({
        excluded_accounts      = optional(list(string), []) # list of account-ids that will be exempted from AWS Support Access Role
        trust_principal_string = string
      }), null
    )
    ebs_encryption = optional(
      object({
        excluded_accounts          = optional(list(string), []) # list of account-ids that will be exempted from EBS Encryption
        secondary_regions_override = optional(list(string), null)
      }), null
    )
    guardduty = optional(
      object({
        excluded_accounts            = optional(list(string), []) # list of account-ids that will be exempted from GuardDuty
        aggregation_account_id       = string
        secondary_regions_override   = optional(list(string), null)
        enable_s3_logs               = optional(bool, true)
        enable_kubernetes            = optional(bool, true)
        enable_ebs_volume_protection = optional(bool, true)
        enable_rds_login_events      = optional(bool, true)
        enable_lambda_network_logs   = optional(bool, true)
        enable_runtime_monitoring    = optional(bool, false) # Only one of enable_kubernetes or enable_runtime_monitoring can be true
      }), null
    )
    s3_account_level_public_access_block = optional(
      object({
        excluded_accounts = optional(list(string), []) # list of account-ids that will be exempted from S3 Public Access Block
      }), null
    )
    security_hub_cspm = optional(
      object({
        excluded_accounts          = optional(list(string), []) # list of account-ids that will be exempted from Security Hub CSPM
        aggregation_account_id     = string
        secondary_regions_override = optional(list(string), null)
        enable_default_standards   = optional(bool, false)
        auto_enable_controls       = optional(bool, true)
        control_finding_generator  = optional(string, "SECURITY_CONTROL")
      }), null
    )
    service_linked_roles = optional(
      object({
        excluded_accounts = optional(list(string), []) # list of account-ids that will be exempted from Service Linked Roles
        service_names     = list(string)
      }), null
    )
  })

  validation {
    condition = var.account_hardening_settings.guardduty == null ? true : !(
      var.account_hardening_settings.guardduty.enable_kubernetes == true &&
      var.account_hardening_settings.guardduty.enable_runtime_monitoring == true
    )
    error_message = "GuardDuty: Only one of 'enable_kubernetes' (EKS_RUNTIME_MONITORING) or 'enable_runtime_monitoring' (RUNTIME_MONITORING) can be enabled at a time. Both cannot be true simultaneously."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMMON
# ---------------------------------------------------------------------------------------------------------------------
variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}
