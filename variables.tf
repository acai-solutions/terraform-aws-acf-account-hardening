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
    provisio_regions = object({
      primary_region = string
      regions        = list(string)
    })
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
      }),
      {
        minimum_password_length        = 16
        max_password_age               = 90
        password_reuse_prevention      = 24
        require_lowercase_characters   = true
        require_numbers                = true
        require_uppercase_characters   = true
        require_symbols                = true
        allow_users_to_change_password = true
      }
    )
    s3_account_level_public_access_block = optional(bool, true)
    ebs_encryption                       = optional(bool, true)
  })
  default = {
    aws_account_password_policy = {
      minimum_password_length        = 16
      max_password_age               = 90
      password_reuse_prevention      = 24
      require_lowercase_characters   = true
      require_numbers                = true
      require_uppercase_characters   = true
      require_symbols                = true
      allow_users_to_change_password = true
    }
    s3_account_level_public_access_block = true
    ebs_encryption                       = true
  }
}
