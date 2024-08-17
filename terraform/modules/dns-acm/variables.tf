variable "domain_name" {
  type        = string
  description = "The domain name which needs to be secured with an ACM certificate"
  default     = null

  validation {
    condition     = length(var.domain_name) > 0
    error_message = "The domain_name value must be a non-empty string."
  }
}

variable "validation_method" {
  type        = string
  description = "The validation method used for the ACM certificate"
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], var.validation_method)
    error_message = "The validation_method value must be either 'DNS' or 'EMAIL'."
  }
}

variable "alias" {
  type        = bool
  description = "Whether the record to create should be an alias or not"
  default     = false
}

variable "records" {
  type        = list(string)
  description = "A list of records to create for the domain name"
  default     = []
}

variable "alias_data" {
  type = list(object({
    name                   = string
    zone_id                = string
    evaluate_target_health = bool
  }))
  description = "A list of alias records to create for the domain name"
  default     = []
}