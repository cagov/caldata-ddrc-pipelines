##############
#    Marts   #
##############

resource "aws_s3_bucket" "marts" {
  bucket = "${var.prefix}-${var.region}-marts"
}

# Versioning
resource "aws_s3_bucket_versioning" "marts" {
  bucket = aws_s3_bucket.marts.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "marts" {
  bucket = aws_s3_bucket.marts.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# External stage policy
# https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration#creating-an-iam-policy
data "aws_iam_policy_document" "marts_external_stage_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [aws_s3_bucket.marts.arn]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["*"]
    }

  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    resources = ["${aws_s3_bucket.marts.arn}/*"]
  }
}

resource "aws_iam_policy" "marts_external_stage_policy" {
  name        = "${var.prefix}-${var.region}-marts-external-stage-policy"
  description = "Policy allowing read/write for marts bucket"
  policy      = data.aws_iam_policy_document.marts_external_stage_policy.json
}

data "aws_iam_policy_document" "marts_public_read" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.marts.arn,
      "${aws_s3_bucket.marts.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "marts_public_read" {
  bucket = aws_s3_bucket.marts.id
  policy = data.aws_iam_policy_document.marts_public_read.json
}
