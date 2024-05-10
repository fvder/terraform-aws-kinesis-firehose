# Control if Kinesis Firehose should be created
variable "create" {
  description = "Controls if kinesis firehose should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

# Name to identify the Kinesis Firehose stream
variable "name" {
  description = "A name to identify the stream. This is unique to the AWS account and region the Stream is created in"
  type        = string
}

# Input source configuration
variable "input_source" {
  description = "This is the kinesis firehose source"
  type        = string
  default     = "direct-put"
  validation {
    error_message = "Please use a valid source!"
    condition     = contains(["direct-put", "kinesis", "waf"], var.input_source)
  }
}

variable "kinesis_source_stream_arn" {
  description = "Kinesis Stream ARN for the source."
  type        = string
  default     = ""
}

variable "kinesis_source_use_existing_role" {
  description = "Flag to indicate whether to use an existing role for Kinesis source."
  type        = bool
  default     = false
}

variable "firehose_role" {
  description = "IAM role ARN attached to the Kinesis Firehose Stream."
  type        = string
  default     = null
}

variable "enable_sse" {
  description = "Enable server-side encryption."
  type        = bool
  default     = false
}

variable "sse_kms_key_arn" {
  description = "KMS Key ARN for server-side encryption."
  type        = string
  default     = null
}

variable "sse_kms_key_type" {
  description = "Type of KMS key used for server-side encryption."
  type        = string
  default     = "AWS_OWNED_CMK"
}

# Destination to where the data is delivered (only supporting s3 and extended_s3)
variable "destination" {
  description = "This is the destination to where the data is delivered"
  type        = string
  validation {
    error_message = "Please use a valid destination!"
    condition     = contains(["s3", "extended_s3"], var.destination)
  }
}

# Control whether to create IAM role for Kinesis Firehose Stream
variable "create_role" {
  description = "Controls whether IAM role for Kinesis Firehose Stream should be created"
  type        = bool
  default     = true
}

# Tags for resources
variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

# Buffer incoming data to the specified size before delivering it to the destination
variable "buffering_size" {
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to the destination."
  type        = number
  default     = 5
  validation {
    error_message = "Valid values: minimum: 1 MiB, maximum: 128 MiB."
    condition     = var.buffering_size >= 1 && var.buffering_size <= 128
  }
}

# Buffer incoming data for the specified period before delivering it to the destination
variable "buffering_interval" {
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination."
  type        = number
  default     = 300
  validation {
    error_message = "Valid Values: Minimum: 0 seconds, maximum: 900 seconds."
    condition     = var.buffering_interval >= 0 && var.buffering_interval <= 900
  }
}

# Enable data transformation with Lambda
variable "enable_lambda_transform" {
  description = "Set it to true to enable data transformation with lambda."
  type        = bool
  default     = false
}

# Lambda ARN for data transformation
variable "transform_lambda_arn" {
  description = "Lambda ARN to Transform source records."
  type        = string
  default     = null
}

# S3 bucket ARN for Kinesis Firehose destination
variable "s3_bucket_arn" {
  description = "The ARN of the destination S3 bucket."
  type        = string
}

# Prefix for the destination S3 bucket
variable "s3_prefix" {
  description = "The S3 prefix for the destination."
  type        = string
  default     = ""
}

# Error output prefix for S3 bucket
variable "s3_error_output_prefix" {
  description = "Prefix for failed S3 delivery."
  type        = string
  default     = null
}

# Enable server-side encryption for S3
variable "enable_s3_encryption" {
  description = "Enable server-side encryption for S3."
  type        = bool
  default     = false
}

# KMS Key ARN for S3 server-side encryption
variable "s3_kms_key_arn" {
  description = "KMS Key ARN for S3 server-side encryption."
  type        = string
  default     = null
}

# Compression format for S3 delivery
variable "s3_compression_format" {
  description = "Compression format for S3 delivery."
  type        = string
  default     = "GZIP"
}

# Enable dynamic partitioning for S3 delivery
variable "enable_dynamic_partitioning" {
  description = "Enable dynamic partitioning for S3 delivery."
  type        = bool
  default     = false
}

# Retry duration for dynamic partitioning
variable "dynamic_partitioning_retry_duration" {
  description = "Retry duration for dynamic partitioning."
  type        = number
  default     = 300
}

# VPC subnet IDs for Firehose stream
variable "vpc_subnet_ids" {
  description = "List of VPC subnet IDs."
  type        = list(string)
  default     = []
}

variable "enable_vpc" {
  description = "Enable VPC configuration for Kinesis Firehose."
  type        = bool
  default     = false
}

variable "vpc_security_group_destination_vpc_id" {
  description = "VPC ID for destination security group."
  type        = string
  default     = ""
}

# VPC security group tags for Firehose stream
variable "vpc_security_group_tags" {
  description = "Tags for VPC security group."
  type        = map(string)
  default     = {}
}

# Name of the IAM role to use for Kinesis Firehose Stream
variable "role_name" {
  description = "Name of IAM role to use for Kinesis Firehose Stream."
  type        = string
  default     = null
}

# Policy name for the IAM policy to use for Kinesis Firehose Stream
variable "policy_name" {
  description = "Name of the IAM policy to be used for Kinesis Firehose Stream."
  type        = string
  default     = null
}

# Description of the IAM role to use for Kinesis Firehose Stream
variable "role_description" {
  description = "Description of IAM role to use for Kinesis Firehose Stream."
  type        = string
  default     = null
}

# Path of the IAM role to use for Kinesis Firehose Stream
variable "role_path" {
  description = "Path of IAM role to use for Kinesis Firehose Stream."
  type        = string
  default     = null
}

# Force detach policies of the IAM role before destroying it
variable "role_force_detach_policies" {
  description = "Specifies to force detaching any policies the IAM role has before destroying it."
  type        = bool
  default     = true
}

# Permissions boundary for the IAM role used by Kinesis Firehose Stream
variable "role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the IAM role used by Kinesis Firehose Stream."
  type        = string
  default     = null
}

# Tags for the IAM role
variable "role_tags" {
  description = "A map of tags to assign to IAM role."
  type        = map(string)
  default     = {}
}

# Path of the policies to be added to IAM role for Kinesis Firehose Stream
variable "policy_path" {
  description = "Path of policies to that should be added to IAM role for Kinesis Firehose Stream."
  type        = string
  default     = null
}

# Number of days to retain Cloudwatch logs
variable "cw_log_retention_in_days" {
  description = "Number of days to retain Cloudwatch logs."
  type        = number
  default     = 7
}

# Tags for CloudWatch Log resources
variable "cw_tags" {
  description = "Tags for CloudWatch Log resources."
  type        = map(string)
  default     = {}
}
