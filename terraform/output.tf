output "gateway_url" {
  value = module.api_gateway.gateway_url
}

output "distribution_link" {
  value = aws_cloudfront_distribution.s3_website.domain_name
}

output "pool_web_client_id" {
  value = aws_cognito_user_pool_client.web.id
}

output "pool_id" {
  value = aws_cognito_user_pool.pool.id
}