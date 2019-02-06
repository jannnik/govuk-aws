## Module: aws::es_domain

Create an ElasticSearch domain


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| default_tags | Additional resource tags | map | `<map>` | no |
| ebs_encrypt | Whether to encrypt the EBS volume at rest | string | - | yes |
| ebs_size | The amount of EBS storage to attach | string | `32` | no |
| elasticsearch_version | Which version of ElasticSearch to use (eg 5.6) | string | `5.6` | no |
| instance_count | The number of ElasticSearch nodes | string | `3` | no |
| instance_type | The instance type of the individual ElasticSearch nodes, only instances which allow EBS volumes are supported | string | `m4.2xlarge.elasticsearch` | no |
| name | The common name for all the resources created by this module | string | - | yes |
| security_group_ids | Security group IDs to apply to this cluster | list | - | yes |
| snapshot_start_hour | The hour in which the daily snapshot is taken | string | `1` | no |
| subnet_ids | Subnet IDs to assign to the aws_elasticsearch_domain | list | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| es_domain_id | Unique identifier for the domain |
| es_endpoint | Endpoint to submit index, search, and upload requests |
| es_role_id | Unique identifier for the service-linked role |
