output "function_arn" {
  value = aws_lambda_function.this.arn
}

output "function_invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}
