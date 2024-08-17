output "gateway_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}

output "gateway_execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}