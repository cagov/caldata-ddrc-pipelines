############################
#         Variables        #
############################

variable "environment" {
  description = "Environment suffix"
  type        = string
}

variable "account_name" {
  description = "Snowflake account name"
  type        = string
}

variable "organization_name" {
  description = "Snowflake account organization"
  type        = string
}

############################
#         Providers        #
############################

terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "1.0.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.56.0"
    }
  }
  required_version = ">= 1.0"

  backend "s3" {
  }
}
locals {
  owner       = "doe"
  environment = "dev"
  project     = "ddrc"
  region      = "us-west-2"

  # These are circular dependencies on the outputs. Unfortunate, but
  # necessary, as we don't know them until we've created the storage
  # integration, which itself depends on the assume role policy.
  storage_aws_external_id  = "HEB41095_SFCRole=2_9UsEjw4IeEbA2cjcrJmBfX4AtGg="
  storage_aws_iam_user_arn = "arn:aws:iam::742950179262:user/erq60000-s"

}


# This provider is intentionally low-permission. In Snowflake, object creators are
# the default owners of the object. To control the owner, we create different provider
# blocks with different roles, and require that all snowflake resources explicitly
# flag the role they want for the creator.
provider "snowflake" {
  account_name             = var.account_name
  organization_name        = var.organization_name
  role                     = "PUBLIC"
  preview_features_enabled = ["snowflake_storage_integration_resource", "snowflake_stage_resource"]
}

# Snowflake provider for account administration (to be used only when necessary).
provider "snowflake" {
  alias                    = "accountadmin"
  role                     = "ACCOUNTADMIN"
  account_name             = var.account_name
  organization_name        = var.organization_name
  preview_features_enabled = ["snowflake_storage_integration_resource", "snowflake_stage_resource"]
}

# Snowflake provider for creating databases, warehouses, etc.
provider "snowflake" {
  alias                    = "sysadmin"
  role                     = "SYSADMIN"
  account_name             = var.account_name
  organization_name        = var.organization_name
  preview_features_enabled = ["snowflake_storage_integration_resource", "snowflake_stage_resource"]
}

# Snowflake provider for managing grants to roles.
provider "snowflake" {
  alias                    = "securityadmin"
  role                     = "SECURITYADMIN"
  account_name             = var.account_name
  organization_name        = var.organization_name
  preview_features_enabled = ["snowflake_storage_integration_resource", "snowflake_stage_resource"]
}

# Snowflake provider for managing user accounts and roles.
provider "snowflake" {
  alias                    = "useradmin"
  role                     = "USERADMIN"
  account_name             = var.account_name
  organization_name        = var.organization_name
  preview_features_enabled = ["snowflake_storage_integration_resource", "snowflake_stage_resource"]
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Owner       = local.owner
      Project     = local.project
      Environment = local.environment
    }
  }
}

############################
#       Environment        #
############################

module "elt" {
  source = "github.com/cagov/data-infrastructure.git//terraform/snowflake/modules/elt?ref=bb2c2e9"
  providers = {
    snowflake.accountadmin  = snowflake.accountadmin,
    snowflake.securityadmin = snowflake.securityadmin,
    snowflake.sysadmin      = snowflake.sysadmin,
    snowflake.useradmin     = snowflake.useradmin,
  }

  environment = var.environment
}


##############
#  S3 Marts  #
##############

module "marts" {
  source = "../../modules/s3-marts"
  providers = {
    aws                     = aws
    snowflake.accountadmin  = snowflake.accountadmin,
    snowflake.securityadmin = snowflake.securityadmin,
    snowflake.sysadmin      = snowflake.sysadmin,
    snowflake.useradmin     = snowflake.useradmin,
  }

  environment                                = upper("${local.project}_${local.environment}")
  prefix                                     = "${local.owner}-${local.project}-${local.environment}"
  region                                     = local.region
  snowflake_storage_integration_iam_user_arn = local.storage_aws_iam_user_arn
  # snowflake_storage_integration_external_id  = local.storage_aws_external_id
}



