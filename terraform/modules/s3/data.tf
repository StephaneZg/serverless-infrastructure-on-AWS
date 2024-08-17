data "aws_iam_policy_document" "bucket" {
  version = "2012-10-17"

  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    principals {
      identifiers = [local.bucket_permision_identifier]
      type = local.bucket_permission_type
    }

    resources = [
      "${aws_s3_bucket.website.arn}/*"
    ]
  }
}