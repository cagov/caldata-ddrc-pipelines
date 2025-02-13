######################################
#            Terraform               #
######################################

# Storage integration
resource "snowflake_storage_integration" "storage_integration" {
  provider                  = snowflake.accountadmin
  name                      = var.environment
  type                      = "EXTERNAL_STAGE"
  storage_provider          = "S3"
  storage_aws_role_arn      = aws_iam_role.snowflake_storage_integration.arn
  storage_allowed_locations = [aws_s3_bucket.marts.id]
}

resource "snowflake_grant_privileges_to_account_role" "storage_integration_to_sysadmin" {
  provider          = snowflake.accountadmin
  privileges        = ["USAGE"]
  account_role_name = "SYSADMIN"
  on_account_object {
    object_type = "INTEGRATION"
    object_name = snowflake_storage_integration.storage_integration.name
  }
}

# Marts stage
resource "snowflake_stage" "marts" {
  provider            = snowflake.sysadmin
  name                = "MARTS"
  url                 = aws_s3_bucket.marts.id
  database            = "ANALYTICS_${var.environment}"
  schema              = "PUBLIC"
  storage_integration = snowflake_storage_integration.storage_integration.name
  depends_on          = [snowflake_grant_privileges_to_account_role.storage_integration_to_sysadmin]
}


resource "snowflake_grant_privileges_to_account_role" "marts" {
  provider          = snowflake.sysadmin
  account_role_name = "TRANSFORMER_DDRC_${var.environment}"
  privileges        = ["USAGE"]
  on_schema_object {
    object_type = "STAGE"
    object_name = "${snowflake_stage.marts.database}.${snowflake_stage.marts.schema}.${snowflake_stage.marts.name}"
  }
}

