##################################
#        IAM Service Users       #
##################################

resource "aws_iam_role_policy_attachment" "snowflake_storage_integration_marts" {
  role       = aws_iam_role.snowflake_storage_integration.name
  policy_arn = aws_iam_policy.marts_external_stage_policy.arn
}

# IAM role for Snowflake to assume when reading from the external stage buckets
resource "aws_iam_role" "snowflake_storage_integration" {
  name = "${var.prefix}-snowflake-storage-integration"

  # https://docs.snowflake.com/user-guide/data-load-snowpipe-auto-s3#step-5-grant-the-iam-user-permissions-to-access-bucket-objects
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : var.snowflake_storage_integration_iam_user_arn
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "sts:ExternalId" : var.snowflake_storage_integration_external_id
          }
        }
      }
    ]
    }
  )
}
