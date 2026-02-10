# terraform-aws-acf-account-hardening Terraform module

<!-- LOGO -->
<a href="https://acai.gmbh">    
  <img src="https://github.com/acai-solutions/acai.public/raw/main/logo/logo_github_readme.png" alt="acai logo" title="ACAI" align="right" height="75" />
</a>

<!-- SHIELDS -->
[![Maintained by acai.gmbh][acai-shield]][acai-url]
[![documentation][acai-docs-shield]][acai-docs-url]  
![module-version-shield]
![terraform-version-shield]  
![trivy-shield]
![checkov-shield]

<!-- BEGIN_ACAI_DOCS -->
<!-- DESCRIPTION -->
ACAI ACF specification-repo for AWS account hardening.

> **_IMPORTANT:_**  This module requires [ACAI Provisio][acai-provisio-url].

<!-- FEATURES -->
## Features

* Account Password Policy
* S3 Block Public Access
* EBS Default Encryption

<!-- USAGE -->
## USAGE

### Settings

```hcl
locals {
  provisio_settings = {
    primary_region = "eu-central-1"
    regions        = [
      "us-east-2",
      "eu-north-1"
    ]
  }
  aws_account_password_policy = {
    minimum_password_length        = 32
    max_password_age               = 90
    password_reuse_prevention      = 7
    require_lowercase_characters   = true
    require_numbers                = true
    require_uppercase_characters   = true
    require_symbols                = true
    allow_users_to_change_password = true
  }
}
```

### Rendering

```hcl
module "account_hardening_default" {
  source = "git::https://github.com/acai-solutions/terraform-aws-acf-account-hardening.git?ref=main"

  provisio_settings = {
    provisio_regions = local.provisio_settings
  }
  account_hardening_settings = {
    aws_account_password_policy          = local.aws_account_password_policy
    s3_account_level_public_access_block = true
    ebs_encryption                       = true
  }
}

module "account_hardening_image_factory" {
  source = "git::https://github.com/acai-solutions/terraform-aws-acf-account-hardening.git?ref=main"

  provisio_settings = {
    provisio_package_name = "account-hardening-without-ebs"
    provisio_regions      = local.provisio_settings
  }
  account_hardening_settings = {
    aws_account_password_policy          = local.aws_account_password_policy
    s3_account_level_public_access_block = true
    ebs_encryption                       = false # in the image factory account EBS encryption must be of for AMI sharing
  }
}
```

### Assigment to accounts

You need to prcisely assign differnt baselining to different AWS account of your organization?

Leveraging the [ACAI ACF Account Cache][acai-account-cache-url] and the [account selection query language][acai-account-cache-query-url] convention, this is very easy.

```hcl
locals {
  account_baseline = [

# ----------------------------------------------------------------
# account-hardening 
# this will be applied to all accounts except the Image Factory Account
    {
      deployment_name = "account-hardening"
      account_scope   = <<EOF
{
  "exclude" : {
    "accountId" : [
      "123456789012" # Image Factory Account
    ]
  }
}
      EOF
      provisio_packages = [
        "account-hardening"
      ]
    }, 

# ----------------------------------------------------------------
# account-hardening-without-ebs    
# this will be applied only to the Image Factory Account
    {
      deployment_name = "account-hardening-without-ebs"
      account_scope   = <<EOF
{
  "exclude" : "*",
  "forceInclude" : {
    "accountId" : [
      "123456789012" # Image Factory Account
    ]
  }
}
EOF
      provisio_packages = [
        "account-hardening-without-ebs"
      ]
    }
  ]
}
```

### Provisioning

```hcl
# ---------------------------------------------------------------------------------------------------------------------
# ¦ ACAI PROVOSIO CORE
# ---------------------------------------------------------------------------------------------------------------------
module "acai_provisio_core" {
  source = "git::https://github.com/acai-customers/terraform-aws-acai-provisio.git?ref=main"

  provisio_baselining_specification = {
    terraform_version     = "= 1.5.7"
    provider_aws_version  = "= 5.50"
    provisio_regions      = local.provisio_settings
    package_specification = [
      module.account_hardening_default,
      module.account_hardening_image_factory
    ]
    package_deployment = local.account_baseline
  }
  providers = {
    aws = aws.Act_Baselining
  }
}
```
<!-- END_ACAI_DOCS -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_uuid.module_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_hardening_settings"></a> [account\_hardening\_settings](#input\_account\_hardening\_settings) | Account hardening settings | <pre>object({<br/>    aws_account_password_policy = optional(<br/>      object({<br/>        # compliant with CIS AWS <br/>        excluded_accounts              = optional(list(string), []) # list of account-ids that will be exempted from Password Policy<br/>        minimum_password_length        = optional(number, 16)<br/>        max_password_age               = optional(number, 90)<br/>        password_reuse_prevention      = optional(number, 24)<br/>        require_lowercase_characters   = optional(bool, true)<br/>        require_numbers                = optional(bool, true)<br/>        require_uppercase_characters   = optional(bool, true)<br/>        require_symbols                = optional(bool, true)<br/>        allow_users_to_change_password = optional(bool, true)<br/>      }), null<br/>    )<br/>    aws_support_access_role = optional(<br/>      object({<br/>        excluded_accounts      = optional(list(string), []) # list of account-ids that will be exempted from AWS Support Access Role<br/>        trust_principal_string = string<br/>      }), null<br/>    )<br/>    ebs_encryption = optional(<br/>      object({<br/>        excluded_accounts          = optional(list(string), []) # list of account-ids that will be exempted from EBS Encryption<br/>        secondary_regions_override = optional(list(string), null)<br/>      }), null<br/>    )<br/>    guardduty = optional(<br/>      object({<br/>        excluded_accounts            = optional(list(string), []) # list of account-ids that will be exempted from GuardDuty<br/>        aggregation_account_id       = string<br/>        secondary_regions_override   = optional(list(string), null)<br/>        enable_s3_logs               = optional(bool, true)<br/>        enable_kubernetes            = optional(bool, true)<br/>        enable_ebs_volume_protection = optional(bool, true)<br/>        enable_rds_login_events      = optional(bool, true)<br/>        enable_lambda_network_logs   = optional(bool, true)<br/>        enable_runtime_monitoring    = optional(bool, false) # Only one of enable_kubernetes or enable_runtime_monitoring can be true<br/>      }), null<br/>    )<br/>    s3_account_level_public_access_block = optional(<br/>      object({<br/>        excluded_accounts = optional(list(string), []) # list of account-ids that will be exempted from S3 Public Access Block<br/>      }), null<br/>    )<br/>    security_hub_cspm = optional(<br/>      object({<br/>        excluded_accounts          = optional(list(string), []) # list of account-ids that will be exempted from Security Hub CSPM<br/>        aggregation_account_id     = string<br/>        secondary_regions_override = optional(list(string), null)<br/>        enable_default_standards   = optional(bool, false)<br/>        auto_enable_controls       = optional(bool, true)<br/>        control_finding_generator  = optional(string, "SECURITY_CONTROL")<br/>      }), null<br/>    )<br/>    service_linked_roles = optional(<br/>      object({<br/>        excluded_accounts = optional(list(string), []) # list of account-ids that will be exempted from Service Linked Roles<br/>        service_names     = list(string)<br/>      }), null<br/>    )<br/>  })</pre> | n/a | yes |
| <a name="input_provisio_settings"></a> [provisio\_settings](#input\_provisio\_settings) | ACAI PROVISIO settings | <pre>object({<br/>    package_name         = optional(string, "account-hardening")<br/>    override_module_name = optional(string, null)<br/>    terraform_version    = optional(string, ">= 1.3.10")<br/>    provider_aws_version = optional(string, ">= 6.00")<br/>    target_regions = object({<br/>      primary_region    = string<br/>      secondary_regions = list(string)<br/>    })<br/>    import_resources = optional(bool, false)<br/>  })</pre> | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of tags to assign to the resources in this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_package_files"></a> [package\_files](#output\_package\_files) | The list of files included in the PROVISIO package |
| <a name="output_package_id"></a> [package\_id](#output\_package\_id) | The unique ID of the PROVISIO package |
| <a name="output_package_name"></a> [package\_name](#output\_package\_name) | The name of the PROVISIO package |
| <a name="output_tf_module_name"></a> [tf\_module\_name](#output\_tf\_module\_name) | The Terraform module name |
| <a name="output_tf_provider_regions"></a> [tf\_provider\_regions](#output\_tf\_provider\_regions) | The list of Terraform provider regions |
<!-- END_TF_DOCS -->

<!-- AUTHORS -->
## Authors

This module is maintained by [ACAI][acai-url]

<!-- LICENSE -->
## License

See [LICENSE][license-url] for full details.

<!-- COPYRIGHT -->
<br />
<br />
<p align="center">Copyright &copy; 2024, 2025 ACAI GmbH</p>

<!-- MARKDOWN LINKS & IMAGES -->
[acai-shield]: https://img.shields.io/badge/maintained_by-acai.gmbh-CB224B?style=flat
[acai-docs-shield]: https://img.shields.io/badge/documentation-docs.acai.gmbh-CB224B?style=flat
[acai-url]: https://acai.gmbh
[acai-docs-url]: https://docs.acai.gmbh/solution-acf/10_overview/
[module-version-shield]: https://img.shields.io/badge/module_version-1.2.0-CB224B?style=flat
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D1.3.10-blue.svg?style=flat&color=blueviolet
[provider-aws-version-shield]: https://img.shields.io/badge/aws-%3E%3D5.50-blue.svg?style=flat&color=blueviolet
[acai-provisio-url]: https://acai.gmbh/solutions/provisio
[license-url]: ./LICENSE.md
[acai-account-cache-url]: https://github.com/acai-solutions/terraform-aws-acf-account-cache
[acai-account-cache-query-url]: https://docs.acai.gmbh/json-engine/account-query/
