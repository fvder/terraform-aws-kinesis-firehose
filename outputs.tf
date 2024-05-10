# Kinesis Delivery Stream
output "kinesis_firehose_arn" {
  description = "The ARN of the Kinesis Firehose Stream."
  value       = var.create ? aws_kinesis_firehose_delivery_stream.this[0].arn : null
}

output "kinesis_firehose_name" {
  description = "The name of the Kinesis Firehose Stream."
  value       = var.create ? aws_kinesis_firehose_delivery_stream.this[0].name : null
}

output "kinesis_firehose_destination_id" {
  description = "The Destination id of the Kinesis Firehose Stream"
  value       = var.create ? aws_kinesis_firehose_delivery_stream.this[0].destination_id : null
}

output "kinesis_firehose_version_id" {
  description = "The Version id of the Kinesis Firehose Stream"
  value       = var.create ? aws_kinesis_firehose_delivery_stream.this[0].version_id : null
}

# IAM
output "kinesis_firehose_role_arn" {
  description = "The ARN of the IAM role created for Kinesis Firehose Stream"
  value       = try(aws_iam_role.firehose[0].arn, "")
}

# CloudWatch Log Group
output "kinesis_firehose_cloudwatch_log_group_arn" {
  description = "The ARN of the created Cloudwatch Log Group."
  value       = try(aws_cloudwatch_log_group.log[0].arn, "")
}

output "kinesis_firehose_cloudwatch_log_group_name" {
  description = "The name of the created Cloudwatch Log Group."
  value       = try(aws_cloudwatch_log_group.log[0].name, "")
}

output "kinesis_firehose_cloudwatch_log_delivery_stream_arn" {
  description = "The ARN of the created Cloudwatch Log Group Stream to delivery."
  value       = try(aws_cloudwatch_log_stream.destination[0].arn, "")
}

output "kinesis_firehose_cloudwatch_log_delivery_stream_name" {
  description = "The name of the created Cloudwatch Log Group Stream to delivery."
  value       = try(aws_cloudwatch_log_stream.destination[0].name, "")
}

output "kinesis_firehose_cloudwatch_log_backup_stream_arn" {
  description = "The ARN of the created Cloudwatch Log Group Stream to backup."
  value       = try(aws_cloudwatch_log_stream.backup[0].arn, "")
}

output "kinesis_firehose_cloudwatch_log_backup_stream_name" {
  description = "The name of the created Cloudwatch Log Group Stream to backup."
  value       = try(aws_cloudwatch_log_stream.backup[0].name, "")
}

