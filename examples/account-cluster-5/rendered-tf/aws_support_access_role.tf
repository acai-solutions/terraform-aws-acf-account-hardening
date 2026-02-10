locals {
  excluded_accounts_support_access_role = [
  ]
}

resource "aws_iam_role" "aws_support_access_role" {
  count = contains(local.excluded_accounts_support_access_role, local.current_account_id) ? 0 : 1

  name = "AWS_Support_Access_Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::111111111111:root"
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "aws_support_access_policy" {
  count = contains(local.excluded_accounts_support_access_role, local.current_account_id) ? 0 : 1

  role       = aws_iam_role.aws_support_access_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}
