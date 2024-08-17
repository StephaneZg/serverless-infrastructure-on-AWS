variable "target_count" {
  type        = number
  description = "The number of lambda / other resource functions that will be targeted by the gateway"
  default     = null

  validation {
    condition     = var.target_count > 0
    error_message = "The target count must be greater than 0."
  }
}

variable "target_resource" {
  type = list(object({
    integration_uri  = string
    integration_type = string
    method           = string
  }))
  description = "The URI of the target resource"
  default     = null

  validation {
    condition     = length(var.target_resource) > 0 || length(var.products_resource) == var.target_count
    error_message = "The target resource  is required."
  }
}

variable "products_resource" {
  type = list(object({
    method             = string
    authorization_type = string
    path               = string
  }))
  description = "The proxy configuration of the target resource"

  validation {
    condition     = length(var.products_resource) > 0 || length(var.products_resource) == var.target_count
    error_message = "The gateway proxy is required."
  }
}

variable "target_stage" {
  type        = string
  description = "The stage of the lambda function"
  default     = "Testing"
  validation {
    condition     = length(var.target_stage) > 0 || can(regex("^[a-zA-Z0-9_]+$", var.target_stage))
    error_message = "The lambda stage can't be null and must contain only alphanumeric characters and underscores."
  }
}

variable "gateway_name" {
  type        = string
  description = "The name of the gateway"
  default     = null

  validation {
    condition     = length(var.gateway_name) > 0 || can(regex("^[a-zA-Z0-9_]+$", var.gateway_name))
    error_message = "The gateway name can't be null and  must contain only alphanumeric characters and underscores."
  }
}

variable "gateway_description" {
  type        = string
  description = "The description of the gateway"
  default     = null
}

variable "cognito_pool_arns" {
  type        = set(string)
  description = "Cognito User pool arns"
  default     = []

  validation {
    condition     = length(var.cognito_pool_arns) > 0
    error_message = "The cognito pool arn is required."
  }
}

variable "throttling_burst_limit" {
  type    = number
  default = 5000
}

variable "throttling_rate_limit" {
  type    = number
  default = 10000
}