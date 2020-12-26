
variable "functionname8" {
    default = "ACME-AssignAlarms-CLB"
}
variable "sns_topic_name8" {
    default = "ACME-AssignAlarms-CLB-SNS"
}


# Create deployment file in zip formate
data "archive_file" "zip8" {
  type        = "zip"
  source_file = "${path.module}/Python/ACME-AssignAlarms-CLB.py"
  output_path = "${path.module}/Python/ACME-AssignAlarms-CLB.zip"
}

#Lambda Function resource
resource "aws_lambda_function" "lamb8" {
    filename         = "${path.module}/Python/${var.functionname8}.zip"
    function_name    = "${var.functionname8}"
    timeout          = 90
    runtime          = "python3.6"
    role             = "${aws_iam_role.cw_lambda8.arn}"
    handler          = "${var.functionname8}.lambda_handler"
    source_code_hash = "${data.archive_file.zip8.output_base64sha256}"
    environment {
        variables = {
            Sns_Topic_Arn  = "${aws_sns_topic.sns8.arn}"
        }
    }
}

## SNS TOPIC
resource "aws_sns_topic" "sns8" {
  name = "${var.sns_topic_name8}"
}


## CLOUWATCH EVENT Trigger

# resource "aws_cloudwatch_event_rule" "trigger8" {
#   name        = "ACME-AssignAlarms-CLB-CW"
#   description = "This is event rule trigger every time an instances changes to pending state"

#   event_pattern = <<PATTERN
# {
#   "detail-type": [
#     "AWS API Call via CloudTrail"
#   ],
#   "source": [
#     "aws.elasticloadbalancing"
#   ],
#   "detail": {
#     "eventSource": [
#       "elasticloadbalancing.amazonaws.com"
#     ]
#   }
# }
# PATTERN
# }
# resource "aws_cloudwatch_event_target" "cwtgt8" {
#   target_id = "ACME-AssignAlarms-CLB"
#   rule      = "${aws_cloudwatch_event_rule.trigger8.name}"
#   arn       = "${aws_lambda_function.lamb8.arn}"
# }

# resource "aws_lambda_permission" "allow_cloudwatch_event8" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = "${aws_lambda_function.lamb8.arn}"
#   principal     = "events.amazonaws.com"
#   source_arn    = "${aws_cloudwatch_event_rule.trigger8.arn}"
# }


## IAM role

resource "aws_iam_role" "cw_lambda8" {
  name = "ACME-AssignAlarms-CLB"

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



data "aws_iam_policy" "basiclamb-8" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


data "aws_iam_policy" "sns-8" {
  arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
data "aws_iam_policy" "bucket-8" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

data "aws_iam_policy" "CW8" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "basiclamb-8" {
  role       = "${aws_iam_role.cw_lambda8.name}"
  policy_arn = "${data.aws_iam_policy.basiclamb-8.arn}"
}


resource "aws_iam_role_policy_attachment" "sns-8" {
  role       = "${aws_iam_role.cw_lambda8.name}"
  policy_arn = "${data.aws_iam_policy.sns-8.arn}"
}

resource "aws_iam_role_policy_attachment" "bucket-8" {
  role       = "${aws_iam_role.cw_lambda8.name}"
  policy_arn = "${data.aws_iam_policy.bucket-8.arn}"
}


resource "aws_iam_role_policy_attachment" "CW8" {
  role       = "${aws_iam_role.cw_lambda8.name}"
  policy_arn = "${data.aws_iam_policy.CW8.arn}"
}