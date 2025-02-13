##################################
#        Terraform Setup         #
##################################

terraform {
  # Note: when a package is added or updated, we have to update the lockfile in a
  # platform-independent way, cf. https://github.com/hashicorp/terraform/issues/28041
  # To update the lockfile run:
  #
  # terraform providers lock -platform=linux_amd64 -platform=darwin_amd64
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.56.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 1.0"
      configuration_aliases = [
        snowflake.accountadmin,
        snowflake.securityadmin,
        snowflake.sysadmin,
        snowflake.useradmin,
      ]
    }
  }
  required_version = ">= 1.0"
}
