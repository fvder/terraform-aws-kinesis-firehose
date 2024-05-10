data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role" "firehose" {
  count = var.create_role ? 1 : 0
  name  = coalesce(var.role_name, "${var.name}-firehose-role")
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  description           = var.role_description
  path                  = coalesce(var.role_path, "/")
  force_detach_policies = var.role_force_detach_policies
  permissions_boundary  = var.role_permissions_boundary
  tags                  = merge(var.tags, var.role_tags)
}

resource "aws_iam_policy" "firehose_s3_policy" {
  count = var.create_role ? 1 : 0
  name  = coalesce(var.policy_name, "${var.name}-firehose-s3-policy")
  path  = coalesce(var.policy_path, "/")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
          ]
          Resource = [
            "${var.s3_bucket_arn}",
            "${var.s3_bucket_arn}/*"
          ]
        }
      ],
      var.enable_s3_encryption && var.s3_kms_key_arn != null ? [
        {
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:Encrypt",
            "kms:GenerateDataKey"
          ]
          Resource = var.s3_kms_key_arn
        }
      ] : []
    )
  })
}

resource "aws_iam_role_policy_attachment" "firehose_s3_policy_attachment" {
  count      = var.create_role ? 1 : 0
  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.firehose_s3_policy[0].arn
}

resource "aws_iam_policy" "firehose_cloudwatch_policy" {
  count = var.create_role ? 1 : 0
  name  = coalesce(var.policy_name, "${var.name}-firehose-cloudwatch-policy")
  path  = coalesce(var.policy_path, "/")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.cw_log_group_name}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_cloudwatch_policy_attachment" {
  count      = var.create_role ? 1 : 0
  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.firehose_cloudwatch_policy[0].arn
}

resource "aws_iam_policy" "firehose_vpc_policy" {
  count = var.create_role ? 1 : 0
  name  = coalesce(var.policy_name, "${var.name}-firehose-vpc-policy")
  path  = coalesce(var.policy_path, "/")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_vpc_policy_attachment" {
  count      = var.create_role ? 1 : 0
  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.firehose_vpc_policy[0].arn
}