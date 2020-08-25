variable "aws_tools_account_id" {
  type        = "string"
  description = "AWS account ID for the Tools account"
}

data "template_file" "accessibility_reports_assume_policy_template" {
  template = "${file("${path.module}/../../policies/accessibility_reports_assume_policy.tpl")}"

  vars {
    aws_tools_account_id = "${var.aws_tools_account_id}"
  }
}

resource "aws_iam_role" "govuk_accessibility_reports_data_reader_role" {
  name               = "govuk-accessibility-reports-data-reader"
  assume_role_policy = "${data.template_file.accessibility_reports_assume_policy_template.rendered}"
}

resource "aws_iam_role_policy_attachment" "data_infrastructure_reader_writer_role_attachment" {
  role       = "${aws_iam_role.govuk_accessibility_reports_data_reader_role.name}"
  policy_arn = "${data.terraform_remote_state.app-knowledge-graph.read_write_data_infrastructure_bucket_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "mirror_replica_reader_role_attachment" {
  role       = "${aws_iam_role.govuk_accessibility_reports_data_reader_role.name}"
  policy_arn = "${data.terraform_remote_state.infra-mirror-bucket.govuk_mirror_replica_read_policy_arn}"
}
