locals {
  excluded_accounts_securityhub = [
    "123456789012",
  ]
}

resource "aws_securityhub_account" "security_hub_eu_central_1" {
  count = contains(local.excluded_accounts_securityhub, local.current_account_id) ? 0 : 1

  region   = "eu-central-1"
  enable_default_standards  = false
  auto_enable_controls      = false
  control_finding_generator = "SECURITY_CONTROL"
}

