
resource "aws_api_gateway_rest_api" "this" {
  name        = var.gateway_name
  description = var.gateway_description
}

resource "aws_api_gateway_rest_api_policy" "policy" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Principal": "*",
          "Action": "execute-api:Invoke",
          "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_api_gateway_resource" "products" {
  for_each = { for index, obj in var.products_resource : index => obj }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path
}

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.this.id
  provider_arns = var.cognito_pool_arns
}

resource "aws_api_gateway_method" "products" {
  for_each = { for index, obj in var.products_resource : index => obj }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.products[each.key].id
  http_method = each.value.method

  authorization = each.value.authorization_type
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_method_response" "default_response_200" {
  for_each = { for index, obj in var.products_resource : index => obj }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.products[each.key].resource_id
  http_method = aws_api_gateway_method.products[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  response_models = { "application/json" = "Empty" }
  depends_on = [
    aws_api_gateway_method.products
  ]
}

resource "aws_api_gateway_integration" "this" {
  for_each = { for index, obj in var.target_resource : index => obj }

  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_method.products[each.key].resource_id
  http_method          = aws_api_gateway_method.products[each.key].http_method
  timeout_milliseconds = 29000

  integration_http_method = each.value.method
  type                    = each.value.integration_type
  uri                     = each.value.integration_uri
}

resource "aws_api_gateway_method" "options_method" {
  for_each = { for index, obj in var.products_resource : index => obj }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.products[each.key].id

  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_MOCK" {
  for_each = { for index, obj in var.products_resource : index => obj }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.products[each.key].id
  http_method = aws_api_gateway_method.options_method[each.key].http_method
  type        = "MOCK"

  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = <<EOF
    {
      "statusCode": 200
    }
    EOF
  }
}

resource "aws_api_gateway_method_response" "options_response_200" {
  for_each = { for index, obj in var.products_resource : index => obj }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.products[each.key].id
  http_method = aws_api_gateway_method.options_method[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  response_models = { "application/json" = "Empty" }
}

resource "aws_api_gateway_integration_response" "response_200" {
  for_each = { for index, obj in var.products_resource : index => obj }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.products[each.key].id
  http_method = aws_api_gateway_method.options_method[each.key].http_method
  status_code = aws_api_gateway_method_response.options_response_200[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,Cache-Control'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.deploy.stage_name
  method_path = "*/*"

  settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.products,
      aws_api_gateway_method.options_method,
      aws_api_gateway_integration.this,
      aws_api_gateway_integration.options_MOCK,
      aws_api_gateway_resource.products,
      aws_api_gateway_method_response.options_response_200,
      aws_api_gateway_method_response.default_response_200
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "deploy" {
  depends_on = [
    aws_api_gateway_integration.this
  ]

  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.target_stage
}
