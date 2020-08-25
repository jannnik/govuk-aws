/**
* ## Project: app-accessibility-reports
*
* Accessibility Reports
*
* Generates reports for the Accessibility Team, using the govuk-accessibility-reports repo
*/
variable "aws_environment" {
  type        = "string"
  description = "AWS environment"
}

variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "stackname" {
  type        = "string"
  description = "Stackname"
}

# Resources
# --------------------------------------------------------------

terraform {
  backend          "s3"             {}
  required_version = "= 0.11.14"
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "1.40.0"
}

data "aws_ami" "ubuntu_bionic" {
  most_recent = true

  # canonical
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "template_file" "ec2_assume_policy_template" {
  template = "${file("${path.module}/../../policies/ec2_assume_policy.tpl")}"
}

resource "aws_iam_role" "govuk-accessibility-reports-data-reader_role" {
  name               = "govuk-accessibility-reports-data-reader"
  assume_role_policy = "${data.template_file.ec2_assume_policy_template.rendered}"
}

resource "aws_iam_instance_profile" "accessibility-reports_instance-profile" {
  name = "accessibility-reports_instance-profile"
  role = "${aws_iam_role.govuk-accessibility-reports-data-reader_role.name}"
}

data "template_file" "accessibility-reports_userdata" {
  template = "${file("${path.module}/userdata.tpl")}"

  vars {
    data_infrastructure_bucket_name = "${data.terraform_remote_state.app_knowledge_graph.data-infrastructure-bucket_name}"
    mirror_bucket_name              = "govuk-${var.aws_environment}-mirror-replica"
  }
}

resource "aws_launch_template" "accessibility-reports_launch-template" {
  name          = "accessibility-reports_launch-template"
  image_id      = "${data.aws_ami.ubuntu_bionic.id}"
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    "${data.terraform_remote_state.infra_security_groups.sg_accessibility-reports_id}",
  ]

  iam_instance_profile {
    name = "${aws_iam_instance_profile.accessibility-reports_instance-profile.name}"
  }

  instance_initiated_shutdown_behavior = "terminate"

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 64
    }
  }

  user_data = "${base64encode(data.template_file.accessibility-reports_userdata.rendered)}"
}

resource "aws_autoscaling_group" "accessibility-reports-asg" {
  name             = "accessibility-reports-asg"
  min_size         = 0
  max_size         = 1
  desired_capacity = 0

  launch_template {
    id      = "${aws_launch_template.accessibility-reports_launch-template.id}"
    version = "$Latest"
  }

  vpc_zone_identifier = ["${data.terraform_remote_state.infra_networking.public_subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "accessibility-reports"
    propagate_at_launch = true
  }
}
