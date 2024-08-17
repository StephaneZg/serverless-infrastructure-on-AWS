variable "function_name" {
  description = "variable containing the name of the function"
  type        = string
  default     = null

  validation {
    condition     = length(var.function_name) > 0
    error_message = "The function name shouldn't be null"
  }
}

variable "function_filename" {
  description = "The path of filename of the lambda function code"
  type        = string
  default     = null

  validation {
    condition     = length(var.function_filename) > 0
    error_message = "The function filename shouldn't be null"
  }
}

variable "function_policy_actions" {
  description = "Actions the lambda function should be able to perform"
  type        = list(string)
  default = [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "logs:Tag*"
  ]

  validation {
    condition = length(var.function_policy_actions) > 4
    error_message = "The list of actions should contains the default actions for logging"
  }
}

variable "function_logs_retentions" {
  description = "Days in which lambda function logs should be preserved"
  default     = 1
  type        = number

  validation {
    condition     = var.function_logs_retentions > 0
    error_message = "Logs retentions days can be lower than zero"
  }
}

variable "function_runtime" {
  description = "The runtime of the lambda function"
  type        = string
  default     = null

  validation {
    condition     = length(var.function_runtime) > 0
    error_message = "The Lambda function runtime can't be empty"
  }
}

variable "gateway_execution_arn" {
  type        = string
  description = "Execution arn of the api gateway"
  default     = null

  validation {
    condition     = length(var.gateway_execution_arn) > 0
    error_message = "Execution arn of the api gateway can't be empty"
  }
}

variable "function_permission_principal" {
  description = "Principal of the lambda function permission"
  type = list(object({
    principal    = string
    source_arn   = string
    actions      = string
    statement_id = string
  }))
  default = []

  validation {
    condition     = length(var.function_permission_principal) > 0
    error_message = "The list of principals can't be empty"
  }
}

variable "function_handler" {
  description = "The handler of the lambda function"
  type        = string
  default     = null

  validation {
    condition     = length(var.function_handler) > 0
    error_message = "The Lambda function handler can't be empty"
  }
}

variable "environment_var" {
  description = "Environment variables of the lambda function"
  type        = map(string)
  default     = {}
  sensitive   = true

  validation {
    condition     = length(var.environment_var) > 0
    error_message = "The environment variables can't be empty"
  }
}