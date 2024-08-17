output "acm_validation_status" {
  value = aws_acm_certificate.cert.status
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.cert.arn
}