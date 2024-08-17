locals {
  lambda_role_name   = "${var.function_name}LambdaServerlessWebsiteRole"
  lambda_policy_name = "${var.function_name}LambdaServerlessWebsitePolicy"
}

# IAM Role for the Lambda function
resource "aws_iam_role" "this" {
  name               = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name = local.lambda_policy_name
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = var.function_policy_actions
          Resource = "*"
        },
      ]
    })
  }
}

# Logs group of the lambda function
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 1
}

# Lambda function itself
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.this.arn
  runtime       = var.function_runtime
  handler       = var.function_handler

  environment {
    variables = {
      "TABLE_NAME" = var.environment_var["TABLE_NAME"]
    }
  }

  logging_config {
    log_format       = "JSON"
    system_log_level = "DEBUG"
    log_group        = aws_cloudwatch_log_group.this.name
  }

  memory_size = 128
  timeout     = 900

  filename         = var.function_filename
  source_code_hash = filebase64sha256(var.function_filename)

}

resource "aws_lambda_permission" "allow" {
  for_each = { for index, obj in var.function_permission_principal : index => obj }

  statement_id  = each.value.statement_id
  action        = each.value.actions
  function_name = var.function_name
  principal     = each.value.principal

  source_arn = each.value.source_arn
}