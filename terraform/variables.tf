variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create"
  default     = "serveless-website-stephanezg"
}

variable "assets_path" {
  type        = string
  description = "The path to the directory containing the website assests"
  default     = "assets"
}

variable "scripts_path" {
  type        = string
  description = "The path to the directory containing the website scripts"
  default     = "scripts"
}

variable "css_path" {
  type        = string
  description = "The path to the directory containing the website CSS"
  default     = "css"
}

variable "domain_name" {
  type        = string
  description = "The domain name for the website"
  default     = "web.serverless.zabens.com"
}