# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector

locals {
  excluded_accounts_guardduty = [
    "123456789012",
  ]
}

resource "aws_guardduty_detector" "gd_detector_ap_northeast_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  region = "ap-northeast-1"
  enable = true
}

resource "aws_guardduty_detector_feature" "s3_protection_ap_northeast_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_ap_northeast_1[0].id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}


resource "aws_guardduty_detector_feature" "eks_audit_logs_ap_northeast_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_ap_northeast_1[0].id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "eks_runtime_ap_northeast_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_ap_northeast_1[0].id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}


resource "aws_guardduty_detector_feature" "ebs_protection_ap_northeast_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_ap_northeast_1[0].id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}


resource "aws_guardduty_detector" "gd_detector_ap_southeast_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  region = "ap-southeast-1"
  enable = true
}

resource "aws_guardduty_detector_feature" "s3_protection_ap_southeast_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_ap_southeast_1[0].id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}


resource "aws_guardduty_detector_feature" "eks_audit_logs_ap_southeast_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_ap_southeast_1[0].id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "eks_runtime_ap_southeast_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_ap_southeast_1[0].id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}


resource "aws_guardduty_detector_feature" "ebs_protection_ap_southeast_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_ap_southeast_1[0].id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}


resource "aws_guardduty_detector" "gd_detector_eu_central_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  region = "eu-central-1"
  enable = true
}

resource "aws_guardduty_detector_feature" "s3_protection_eu_central_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_eu_central_1[0].id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}


resource "aws_guardduty_detector_feature" "eks_audit_logs_eu_central_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_eu_central_1[0].id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "eks_runtime_eu_central_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_eu_central_1[0].id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}


resource "aws_guardduty_detector_feature" "ebs_protection_eu_central_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_eu_central_1[0].id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}


resource "aws_guardduty_detector" "gd_detector_eu_west_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  region = "eu-west-1"
  enable = true
}

resource "aws_guardduty_detector_feature" "s3_protection_eu_west_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_eu_west_1[0].id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}


resource "aws_guardduty_detector_feature" "eks_audit_logs_eu_west_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_eu_west_1[0].id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "eks_runtime_eu_west_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_eu_west_1[0].id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}


resource "aws_guardduty_detector_feature" "ebs_protection_eu_west_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_eu_west_1[0].id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}


resource "aws_guardduty_detector" "gd_detector_us_east_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  region = "us-east-1"
  enable = true
}

resource "aws_guardduty_detector_feature" "s3_protection_us_east_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_us_east_1[0].id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}


resource "aws_guardduty_detector_feature" "eks_audit_logs_us_east_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_us_east_1[0].id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "eks_runtime_us_east_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_us_east_1[0].id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}


resource "aws_guardduty_detector_feature" "ebs_protection_us_east_1" {
  count = contains(local.excluded_accounts_guardduty, local.current_account_id) ? 0 : 1

  detector_id = aws_guardduty_detector.gd_detector_us_east_1[0].id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}


