{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${aws_tools_account_id}:role/govuk-accessibility-reports-integration-data-reader"
      },
      "Effect": "Allow"
    }
  ]
}
