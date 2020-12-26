
variable "sns_topic_name" {
    default = "ACME-AssignAlarm-EC2"
}
variable "functionname" {
    default = "ACME-AssignAlarm-EC2"
}


# Create deployment file in zip formate
data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/Python/ACME-AssignAlarm-EC2.py"
  output_path = "${path.module}/Python/ACME-AssignAlarm-EC2.zip"
}

#Lambda Function resource
resource "aws_lambda_function" "lamb" {
    filename         = "${path.module}/Python/${var.functionname}.zip"
    function_name    = "${var.functionname}"
    timeout          = 90
    runtime          = "python3.6"
    role             = "${aws_iam_role.cw_lambda.arn}"
    handler          = "${var.functionname}.lambda_handler"
    source_code_hash = "${data.archive_file.zip.output_base64sha256}"

    environment {
        variables = {
            Sns_Topic_Arn  = "${aws_sns_topic.sns.arn}"
        }
    }
}

## SNS TOPIC
resource "aws_sns_topic" "sns" {
  name = "${var.sns_topic_name}"

}



## IAM role

resource "aws_iam_role" "cw_lambda" {
  name = "ACME-AssignAlarm-EC2"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


data "aws_iam_policy" "example1" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

data "aws_iam_policy" "example2" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
data "aws_iam_policy" "example3" {
  arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
data "aws_iam_policy" "example4" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}




resource "aws_iam_role_policy_attachment" "example1" {
  role       = "${aws_iam_role.cw_lambda.name}"
  policy_arn = "${data.aws_iam_policy.example1.arn}"
}

resource "aws_iam_role_policy_attachment" "example2" {
  role       = "${aws_iam_role.cw_lambda.name}"
  policy_arn = "${data.aws_iam_policy.example2.arn}"
}
resource "aws_iam_role_policy_attachment" "example3" {
  role       = "${aws_iam_role.cw_lambda.name}"
  policy_arn = "${data.aws_iam_policy.example3.arn}"
}
resource "aws_iam_role_policy_attachment" "example4" {
  role       = "${aws_iam_role.cw_lambda.name}"
  policy_arn = "${data.aws_iam_policy.example4.arn}"
}