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
    provisio_package_name = optional(string, "account-hardening")
    terraform_version     = optional(string, ">= 1.3.10")
    provider_aws_version  = optional(string, ">= 6.00")
    provisio_regions = object({
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
        minimum_password_length        = optional(number, 16)
        max_password_age               = optional(number, 90) # Recommended: 60 to 90 days
        password_reuse_prevention      = optional(number, 5)  # Recommended: prevent last 5 to 10 passwords
        require_lowercase_characters   = optional(bool, true)
        require_numbers                = optional(bool, true)
        require_uppercase_characters   = optional(bool, true)
        require_symbols                = optional(bool, true)
        allow_users_to_change_password = optional(bool, true)
      }), null
    )
    aws_support_access_role = optional(
      object({
        trust_principal_string = string
      }), null
    )
    ebs_encryption = optional(
      object({
        secondary_regions_override = optional(list(string), null)
      }), null
    )
    guardduty = optional(
      object({
        secondary_regions_override = optional(list(string), null)
      }), null
    )
    s3_account_level_public_access_block = optional(
      object({
        secondary_regions_override = optional(list(string), null)
      }), null
    )
    security_hub_cspm = optional(
      object({
        secondary_regions_override = optional(list(string), null)
        enable_default_standards   = optional(bool, false)
        auto_enable_controls       = optional(bool, false)
        control_finding_generator  = optional(string, "SECURITY_CONTROL")
      }), null
    )
  })
  default = {
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
    aws_support_access_role              = {}
    ebs_encryption                       = {}
    guardduty                            = {}
    s3_account_level_public_access_block = {}
    security_hub_cspm = {
      enable_default_standards  = false
      auto_enable_controls      = false
      control_finding_generator = "SECURITY_CONTROL"
    }
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
