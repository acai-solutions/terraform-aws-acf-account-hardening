locals {
  excluded_accounts_securityhub = [
    "111111111111",
    "999999999999",
  ]
}

resource "aws_securityhub_account" "security_hub_eu_central_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "eu-central-1"
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

resource "aws_securityhub_account" "security_hub_us_east_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region                    = "us-east-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

