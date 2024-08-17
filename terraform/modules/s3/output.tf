output "bucket_arn" {
  value = aws_s3_bucket.website.arn
}

output "bucket_regional_dns_name" {
  value = aws_s3_bucket.website.bucket_regional_domain_name
}

output "bucket_id" {
  value = aws_s3_bucket.website.id
}

output "bucket_dns_name" {
  value = aws_s3_bucket.website.bucket_domain_name
}

output "bucket_zone_id" {
  value = aws_s3_bucket.website.hosted_zone_id
}