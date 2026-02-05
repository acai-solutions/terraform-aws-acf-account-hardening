# https://registry.terraform.io/providers/hashicorp/aws/6.28.0/docs/resources/s3_account_public_access_block
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html

locals {
  excluded_accounts_s3_public_access_block = [
    "890123456789",
    "789012345678",
  ]
}

resource "aws_s3_account_public_access_block" "s3_account_level_pab" {
  count = contains(local.excluded_accounts_s3_public_access_block, local.current_account_id) ? 0 : 1

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
