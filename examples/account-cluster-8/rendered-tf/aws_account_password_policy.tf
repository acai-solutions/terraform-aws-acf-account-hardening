# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy
locals {
  excluded_accounts_account_password_policy = [
  ]
}

resource "aws_iam_account_password_policy" "account_password_policy" {
  count = contains(local.excluded_accounts_account_password_policy, local.current_account_id) ? 0 : 1

  minimum_password_length        = 12
  max_password_age               = 90
  password_reuse_prevention      = 4
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}
