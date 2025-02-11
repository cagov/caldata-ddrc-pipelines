output "marts_bucket" {
  description = "Bucket for storing marts data"
  value = {
    name = aws_s3_bucket.marts.id
    arn  = aws_s3_bucket.marts.arn
  }
}

output "snowflake_storage_integration_role" {
  description = "IAM role for Snowflake to assume when using the external stage buckets"
  value = {
    name = aws_iam_role.snowflake_storage_integration.name
    arn  = aws_iam_role.snowflake_storage_integration.arn
  }
}
