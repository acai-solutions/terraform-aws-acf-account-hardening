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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.10 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_provisio_settings"></a> [provisio\_settings](#input\_provisio\_settings) | ACAI PROVISIO settings | <pre>object({<br/>    provisio_package_name = optional(string, "account-hardening")<br/>    provisio_regions = object({<br/>      primary_region = string<br/>      regions        = list(string)<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_account_hardening_settings"></a> [account\_hardening\_settings](#input\_account\_hardening\_settings) | Account hardening settings | <pre>object({<br/>    aws_account_password_policy = optional(<br/>      object({<br/>        # compliant with CIS AWS <br/>        minimum_password_length        = optional(number, 16)<br/>        max_password_age               = optional(number, 90) # Recommended: 60 to 90 days<br/>        password_reuse_prevention      = optional(number, 5)  # Recommended: prevent last 5 to 10 passwords<br/>        require_lowercase_characters   = optional(bool, true)<br/>        require_numbers                = optional(bool, true)<br/>        require_uppercase_characters   = optional(bool, true)<br/>        require_symbols                = optional(bool, true)<br/>        allow_users_to_change_password = optional(bool, true)<br/>      }),<br/>      {<br/>        minimum_password_length        = 16<br/>        max_password_age               = 90<br/>        password_reuse_prevention      = 24<br/>        require_lowercase_characters   = true<br/>        require_numbers                = true<br/>        require_uppercase_characters   = true<br/>        require_symbols                = true<br/>        allow_users_to_change_password = true<br/>      }<br/>    )<br/>    s3_account_level_public_access_block = optional(bool, true)<br/>    ebs_encryption                       = optional(bool, true)<br/>  })</pre> | <pre>{<br/>  "aws_account_password_policy": {<br/>    "allow_users_to_change_password": true,<br/>    "max_password_age": 90,<br/>    "minimum_password_length": 16,<br/>    "password_reuse_prevention": 24,<br/>    "require_lowercase_characters": true,<br/>    "require_numbers": true,<br/>    "require_symbols": true,<br/>    "require_uppercase_characters": true<br/>  },<br/>  "ebs_encryption": true,<br/>  "s3_account_level_public_access_block": true<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_provisio_package_files"></a> [provisio\_package\_files](#output\_provisio\_package\_files) | n/a |
| <a name="output_provisio_package_name"></a> [provisio\_package\_name](#output\_provisio\_package\_name) | n/a |
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
<p align="center">Copyright &copy; 2024 ACAI GmbH</p>

<!-- MARKDOWN LINKS & IMAGES -->
[acai-shield]: https://img.shields.io/badge/maintained_by-acai.gmbh-CB224B?style=flat
[acai-url]: https://acai.gmbh
[module-version-shield]: https://img.shields.io/badge/module_version-1.1.0-CB224B?style=flat
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D1.3.10-blue.svg?style=flat&color=blueviolet
[provider-aws-version-shield]: https://img.shields.io/badge/aws-%3E%3D5.50-blue.svg?style=flat&color=blueviolet
[acai-provisio-url]: https://acai.gmbh/solutions/provisio
[license-url]: ./LICENSE.md
[acai-account-cache-url]: https://github.com/acai-solutions/terraform-aws-acf-account-cache
[acai-account-cache-query-url]: https://github.com/acai-solutions/terraform-aws-acf-account-cache/blob/main/wiki.md
