# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html

locals {
  excluded_accounts_service_linked_role = [
  ]
}

resource "aws_iam_service_linked_role" "guardduty_amazonaws_com" {
  count = contains(local.excluded_accounts_service_linked_role, local.current_account_id) ? 0 : 1

  aws_service_name = "guardduty.amazonaws.com"

  tags = local.tags
}

resource "aws_iam_service_linked_role" "securityhub_amazonaws_com" {
  count = contains(local.excluded_accounts_service_linked_role, local.current_account_id) ? 0 : 1

  aws_service_name = "securityhub.amazonaws.com"

  tags = local.tags
}

resource "aws_iam_service_linked_role" "config_amazonaws_com" {
  count = contains(local.excluded_accounts_service_linked_role, local.current_account_id) ? 0 : 1

  aws_service_name = "config.amazonaws.com"

  tags = local.tags
}

