data "aws_subnet" "subnet" {
  count = var.enable_vpc ? 1 : 0
  id    = var.vpc_subnet_ids[0]
}

resource "aws_kinesis_firehose_delivery_stream" "this" {
  count       = var.create ? 1 : 0
  name        = var.name
  destination = local.destination

  dynamic "kinesis_source_configuration" {
    for_each = local.is_kinesis_source ? [1] : []
    content {
      kinesis_stream_arn = var.kinesis_source_stream_arn
      role_arn           = var.kinesis_source_use_existing_role ? local.source_role : local.kinesis_source_stream_role
    }
  }

  dynamic "server_side_encryption" {
    for_each = var.enable_sse ? [1] : []
    content {
      enabled  = var.enable_sse
      key_arn  = var.sse_kms_key_arn
      key_type = var.sse_kms_key_type
    }
  }

  dynamic "extended_s3_configuration" {
    for_each = local.s3_destination ? [1] : []
    content {
      role_arn            = local.firehose_role_arn
      bucket_arn          = var.s3_bucket_arn
      prefix              = var.s3_prefix
      error_output_prefix = var.s3_error_output_prefix
      buffer_size         = var.buffering_size
      buffer_interval     = var.buffering_interval

      s3_backup_mode     = "Disabled"
      kms_key_arn        = var.enable_s3_encryption ? var.s3_kms_key_arn : null
      compression_format = var.s3_compression_format

      dynamic "dynamic_partitioning_configuration" {
        for_each = var.enable_dynamic_partitioning ? [1] : []
        content {
          enabled        = var.enable_dynamic_partitioning
          retry_duration = var.dynamic_partitioning_retry_duration
        }
      }

      dynamic "processing_configuration" {
        for_each = local.enable_processing ? [1] : []
        content {
          enabled = local.enable_processing
          dynamic "processors" {
            for_each = local.processors
            content {
              type = processors.value["type"]
              dynamic "parameters" {
                for_each = processors.value["parameters"]
                content {
                  parameter_name  = parameters.value["name"]
                  parameter_value = parameters.value["value"]
                }
              }
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

##################
# CloudWatch
##################
resource "aws_cloudwatch_log_group" "log" {
  count             = local.create_destination_logs || local.create_backup_logs ? 1 : 0
  name              = local.cw_log_group_name
  retention_in_days = var.cw_log_retention_in_days
  tags              = merge(var.tags, var.cw_tags)
}

resource "aws_cloudwatch_log_stream" "backup" {
  count          = local.create_backup_logs ? 1 : 0
  name           = local.cw_log_backup_stream_name
  log_group_name = aws_cloudwatch_log_group.log[0].name
}

resource "aws_cloudwatch_log_stream" "destination" {
  count          = local.create_destination_logs ? 1 : 0
  name           = local.cw_log_delivery_stream_name
  log_group_name = aws_cloudwatch_log_group.log[0].name
}

##################
# Security Group
##################
resource "aws_security_group" "firehose" {
  count       = var.enable_vpc ? 1 : 0
  name        = "${var.name}-sg"
  description = "Security group for Kinesis Firehose"
  vpc_id      = var.enable_vpc ? data.aws_subnet.subnet[0].vpc_id : var.vpc_security_group_destination_vpc_id

  dynamic "ingress" {
    for_each = [1]
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      self        = true
      description = "Allow Inbound HTTPS Traffic"
    }
  }

  tags = merge(var.tags, var.vpc_security_group_tags)
}

resource "aws_security_group_rule" "firehose_egress_rule" {
  for_each                 = var.enable_vpc ? { for key, value in [aws_security_group.firehose[0].id] : key => value } : {}
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.firehose[0].id
  source_security_group_id = each.value
  description              = "Allow Outbound HTTPS Traffic for destination"
}
