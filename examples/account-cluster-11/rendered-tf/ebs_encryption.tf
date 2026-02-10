# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default

locals {
  excluded_accounts_ebs_encryption = [
  ]
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_eu_central_1" {
  count = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region  = "eu-central-1"
  enabled = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_eu_north_1" {
  count = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region  = "eu-north-1"
  enabled = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_eu_west_1" {
  count = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region  = "eu-west-1"
  enabled = true
}

