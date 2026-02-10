locals {
  excluded_accounts_securityhub = [
    "111111111111",
  ]
}

resource "aws_securityhub_account" "security_hub_ap_northeast_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "ap-northeast-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_ap_northeast_2" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "ap-northeast-2"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_ap_northeast_3" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "ap-northeast-3"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_ap_south_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "ap-south-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_ap_southeast_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "ap-southeast-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_ap_southeast_2" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "ap-southeast-2"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_ca_central_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "ca-central-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_eu_central_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "eu-central-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_eu_north_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "eu-north-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_eu_west_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "eu-west-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_eu_west_2" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "eu-west-2"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_eu_west_3" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "eu-west-3"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_sa_east_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "sa-east-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_us_east_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "us-east-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_us_east_2" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "us-east-2"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_us_west_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "us-west-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_account" "security_hub_us_west_2" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "us-west-2"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

