locals {
  firehose_role_arn           = var.create_role ? aws_iam_role.firehose[0].arn : var.firehose_role
  source_role                 = var.create_role ? aws_iam_role.firehose[0].arn : var.firehose_role
  kinesis_source_stream_role  = var.create_role ? aws_iam_role.firehose[0].arn : var.firehose_role
  cw_log_group_name           = "/aws/kinesisfirehose/${var.name}"
  cw_log_delivery_stream_name = "DestinationDelivery"
  cw_log_backup_stream_name   = "BackupDelivery"
  is_kinesis_source           = var.input_source == "kinesis"
  destinations = {
    s3 : "extended_s3",
    extended_s3 : "extended_s3"
  }
  destination            = local.destinations[var.destination]
  s3_destination         = local.destination == "extended_s3"
  enable_vpc             = length(var.vpc_subnet_ids) > 0
  vpc_security_group_ids = local.enable_vpc ? [aws_security_group.firehose[0].id] : []

  create_destination_logs = var.enable_lambda_transform || var.enable_dynamic_partitioning
  create_backup_logs      = false

  enable_processing = var.enable_lambda_transform

  processors = local.enable_processing ? [
    {
      type = "Lambda"
      parameters = [
        {
          name  = "LambdaArn"
          value = var.transform_lambda_arn
        }
      ]
    }
  ] : []
}
