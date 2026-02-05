# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default

locals {
  excluded_accounts_ebs_encryption = [
  ]
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_ap_northeast_1" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "ap-northeast-1"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_ap_northeast_2" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "ap-northeast-2"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_ap_northeast_3" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "ap-northeast-3"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_ap_south_1" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "ap-south-1"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_ap_southeast_1" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "ap-southeast-1"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_ap_southeast_2" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "ap-southeast-2"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_ca_central_1" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "ca-central-1"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_eu_central_1" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "eu-central-1"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_eu_north_1" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "eu-north-1"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_eu_west_1" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "eu-west-1"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_eu_west_2" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "eu-west-2"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_eu_west_3" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "eu-west-3"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_sa_east_1" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "sa-east-1"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_us_east_1" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "us-east-1"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_us_east_2" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "us-east-2"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_us_west_1" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "us-west-1"
  enabled  = true
}

resource "aws_ebs_encryption_by_default" "default_ebs_encryption_us_west_2" {
  count    = contains(local.excluded_accounts_ebs_encryption, local.current_account_id) ? 0 : 1

  region   = "us-west-2"
  enabled  = true
}

