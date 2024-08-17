locals {

  records = var.alias ? [] : var.records
}

resource "aws_acm_certificate" "cert" {
  domain_name            = var.domain_name

  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# Find a better way to do this
#############################################################
resource "aws_route53_record" "website_alias" {
  count = var.alias ? 1 : 0

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = trimsuffix(var.domain_name, ".${data.aws_route53_zone.selected.name}")
  type    = "A"

  dynamic "alias" {
    for_each = var.alias_data

    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }
}

resource "aws_route53_record" "website_record" {
  count = var.alias ? 0 : 1

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = trimsuffix(var.domain_name, ".${data.aws_route53_zone.selected.name}")
  type    = "A"
  records = local.records
}
#############################################################

# Route53 resources to perform DNS auto validation
resource "aws_route53_record" "this" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  timeouts {
    create = "5m"
  }
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}