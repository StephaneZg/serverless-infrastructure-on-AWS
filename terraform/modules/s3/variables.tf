variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create"
  default     = null

  validation {
    condition     = length(var.bucket_name) > 0
    error_message = "The bucket_name variable is required."
  }
}

variable "force_destroy" {
  type        = bool
  description = "Whether or not to force destroy the bucket"
  default     = true
}

variable "visibility" {
  type        = string
  description = "The visibility of the bucket"
  default     = "private"
}

variable "object_ownership" {
  type        = string
  description = "The ownership controls of the bucket"
  default     = "BucketOwnerPreferred"
}

variable "versioning_enabled" {
  type        = bool
  description = "Whether or not to enable versioning on the bucket"
  default     = false
}

variable "account_id" {
  type        = string
  description = "The AWS account ID"
  default     = "123456789012"

  sensitive = true
}

variable "cloudfront_distribution_id" {
  type        = string
  description = "The ID of the CloudFront distribution"
  default     = null

  validation {
    condition     = length(var.cloudfront_distribution_id) > 0
    error_message = "The cloudfront distribution id variable is required."
  }
}

variable "block_public_acls" {
  type        = bool
  description = "Whether or not to block public ACLs"
  default     = false
}

variable "block_public_policy" {
  type        = bool
  description = "Whether or not to block public policy"
  default     = false
}

variable "ignore_public_acls" {
  type        = bool
  description = "Whether or not to ignore public ACLs"
  default     = false
}

variable "restrict_public_buckets" {
  type        = bool
  description = "Whether or not to restrict public buckets"
  default     = false
}

variable "website_enabled" {
  type        = bool
  description = "Whether or not to enable website hosting"
  default     = false
}

variable "cloudfront_oai_identifier" {
  type        = string
  description = "The identifier for the CloudFront Origin Access Identity"
  default     = null
}