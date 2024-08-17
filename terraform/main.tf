locals {
  lambda_stage_name          = "v1"
  gateway_integration_type   = "AWS_PROXY"
  gateway_authorization_type = "COGNITO_USER_POOLS"
  cognito_user_pool_name     = "ServerlessWebsitePoolUser"
  lambda_permission_principal = [{
    principal    = "apigateway.amazonaws.com"
    source_arn   = "${module.api_gateway.gateway_execution_arn}/*/*/*"
    actions      = "lambda:InvokeFunction"
    statement_id = "AllowExecutionFromAPIGateway"
  }]
  s3_origin_id   = "${var.bucket_name}-origin"
  dynamo_db_name = "ServerlessWebsiteDatabase"

  pages_path   = "../simple_website/"
  css_path     = "../simple_website/${var.css_path}"
  scripts_path = "../simple_website/${var.scripts_path}"
  assets_path  = "../simple_website/${var.assets_path}"

  function_base_env = {
    TABLE_NAME = local.dynamo_db_name
  }

}

# Lambda functions
module "get_item_by_email_lambda" {
  source                   = "./modules/lambda"
  function_name            = "get-product-byemail"
  function_filename        = "./lambda-functions/handlers/get-by-email-payload.zip"
  function_logs_retentions = 1
  function_policy_actions = [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "logs:Tag*",
    "dynamodb:GetItem",
    "dynamodb:PutItem",
    "dynamodb:Query",
    "dynamodb:Scan",
    "dynamodb:UpdateItem",
    "dynamodb:DeleteItem"
  ]

  function_runtime              = "nodejs20.x"
  function_handler              = "get-by-email.getByIdHandler"
  function_permission_principal = local.lambda_permission_principal
  gateway_execution_arn         = module.api_gateway.gateway_execution_arn

  environment_var = local.function_base_env
}

/*module "get_all_lambda" {
  source                   = "./modules/lambda"
  function_name            = "getall-product"
  function_filename        = "./lambda-functions/handlers/get-all-items-payload.zip"
  function_logs_retentions = 1
  function_policy_actions = [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "logs:Tag*",
    "dynamodb:GetItem",
    "dynamodb:PutItem",
    "dynamodb:Query",
    "dynamodb:Scan",
    "dynamodb:UpdateItem",
    "dynamodb:DeleteItem"
  ]

  function_runtime              = "nodejs20.x"
  function_handler              = "get-all-items.getAllItemsHandler"
  function_permission_principal = local.lambda_permission_principal
  gateway_execution_arn         = module.api_gateway.gateway_execution_arn

  environment_var = local.function_base_env
}*/

module "put_item_lambda" {
  source                   = "./modules/lambda"
  function_name            = "put-product"
  function_filename        = "./lambda-functions/handlers/put-items-payload.zip"
  function_logs_retentions = 1
  function_policy_actions = [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "logs:Tag*",
    "dynamodb:GetItem",
    "dynamodb:PutItem",
    "dynamodb:Query",
    "dynamodb:Scan",
    "dynamodb:UpdateItem",
    "dynamodb:DeleteItem"
  ]

  function_runtime              = "nodejs20.x"
  function_handler              = "put-items.putItemHandler"
  function_permission_principal = local.lambda_permission_principal
  gateway_execution_arn         = module.api_gateway.gateway_execution_arn

  environment_var = local.function_base_env
}

# Api Gateway
module "api_gateway" {
  source       = "./modules/api-gateway"
  gateway_name = "serverless-website-api"
  target_count = 3

  gateway_description = "Api Gateway of the serverless website communicating with lambda function"
  products_resource = [{
    method             = "POST",
    authorization_type = local.gateway_authorization_type,
    path               = "products-by-email"
    },
    {
      method             = "POST",
      authorization_type = local.gateway_authorization_type,
      path               = "products"
    }
  ]
  target_resource = [{
    integration_uri  = module.get_item_by_email_lambda.function_invoke_arn,
    method           = "POST",
    integration_type = local.gateway_integration_type
    },
    {
      integration_uri  = module.put_item_lambda.function_invoke_arn,
      method           = "POST",
      integration_type = local.gateway_integration_type
    }
  ]

  cognito_pool_arns = [aws_cognito_user_pool.pool.arn]

  target_stage = local.lambda_stage_name
}

# S3 Bucket
module "s3_website" {
  source          = "./modules/s3"
  bucket_name     = var.bucket_name
  website_enabled = true

  force_destroy      = true
  versioning_enabled = true
  visibility         = "public-read"
  account_id         = data.aws_caller_identity.current.account_id

  cloudfront_distribution_id = aws_cloudfront_distribution.s3_website.id
  cloudfront_oai_identifier  = aws_cloudfront_origin_access_identity.oai.iam_arn
}

# DNS Record and ACM Validation
module "dns_acm_validation" {
  source = "./modules/dns-acm"

  domain_name = var.domain_name
  alias       = true
  alias_data = [{
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.s3_website.domain_name
    zone_id                = aws_cloudfront_distribution.s3_website.hosted_zone_id
  }]
}

# Cloudfront distribution
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "To be used to access S3 bucket"
}

resource "aws_cloudfront_distribution" "s3_website" {
  origin {
    domain_name = module.s3_website.bucket_regional_dns_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  aliases = [var.domain_name]

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = module.dns_acm_validation.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}

# S3 website files import

resource "aws_s3_object" "pages_files" {
  for_each = { for file in fileset(local.pages_path, "*.html") : file => file }

  bucket = module.s3_website.bucket_id
  key    = each.value
  source = "${local.pages_path}/${each.value}"

  etag         = filemd5("${local.pages_path}/${each.value}")
  content_type = "text/html"
}

resource "aws_s3_object" "scripts_folder" {
  bucket = module.s3_website.bucket_id
  key    = "${var.scripts_path}/"

  content_type = "application/x-directory"
}

resource "aws_s3_object" "scripts_files" {
  for_each = { for file in fileset(local.scripts_path, "**") : file => file }

  bucket = module.s3_website.bucket_id
  key    = "${var.scripts_path}/${each.value}"
  source = "${local.scripts_path}/${each.value}"

  etag         = filemd5("${local.scripts_path}/${each.value}")
  content_type = "text/javascript"
}

resource "aws_s3_object" "css_folder" {
  bucket = module.s3_website.bucket_id
  key    = "${var.css_path}/"

  content_type = "application/x-directory"
}

resource "aws_s3_object" "css_files" {
  for_each = { for file in fileset(local.css_path, "**") : file => file }

  bucket = module.s3_website.bucket_id
  key    = "${var.css_path}/${each.value}"
  source = "${local.css_path}/${each.value}"

  etag         = filemd5("${local.css_path}/${each.value}")
  content_type = "text/css"
}

resource "aws_s3_object" "assets_folder" {
  bucket = module.s3_website.bucket_id
  key    = "${var.assets_path}/"

  content_type = "application/x-directory"
}

resource "aws_s3_object" "assets_files" {
  for_each = { for file in fileset(local.assets_path, "**") : file => file }

  bucket = module.s3_website.bucket_id
  key    = "${var.assets_path}/${each.value}"
  source = "${local.assets_path}/${each.value}"

  etag         = filemd5("${local.assets_path}/${each.value}")
  content_type = split(".", each.value)[length(split(".", each.value)) - 1] == "svg" ? "image/svg+xml" : "image/${split(".", each.value)[length(split(".", each.value)) - 1]}"
}

# Cognito user pool
resource "aws_cognito_user_pool" "pool" {
  name                     = local.cognito_user_pool_name
  auto_verified_attributes = ["email"]

  username_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "web" {
  name                                 = "web-integration-client"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  callback_urls                        = ["https://web.serverless.zabens.com"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
}

# Route53 Record


# DynamoDB table
resource "aws_dynamodb_table" "this" {
  name           = local.dynamo_db_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "email"
  range_key      = "product-id"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "product-id"
    type = "S"
  }
}