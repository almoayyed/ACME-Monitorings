
variable "functionname5" {
    default = "ACME-AssignAlarms-ALB"
}
variable "sns_topic_name5" {
    default = "ACME-AssignAlarms-ALB-SNS"
}


# Create deployment file in zip formate
data "archive_file" "zip5" {
  type        = "zip"
  source_file = "${path.module}/Python/ACME-AssignAlarms-ALB.py"
  output_path = "${path.module}/Python/ACME-AssignAlarms-ALB.zip"
}

#Lambda Function resource
resource "aws_lambda_function" "lamb5" {
    filename         = "${path.module}/Python/${var.functionname5}.zip"
    function_name    = "${var.functionname5}"
    timeout          = 90
    runtime          = "python3.6"
    role             = "${aws_iam_role.cw_lambda5.arn}"
    handler          = "${var.functionname5}.lambda_handler"
    source_code_hash = "${data.archive_file.zip5.output_base64sha256}"
    environment {
        variables = {
            Sns_Topic_Arn  = "${aws_sns_topic.sns5.arn}"
        }
    }
}

## SNS TOPIC
resource "aws_sns_topic" "sns5" {
  name = "${var.sns_topic_name5}"
}


# ## CLOUWATCH EVENT Trigger

# resource "aws_cloudwatch_event_rule" "trigger5" {
#   name        = "AssignAlarms-ALB-CW"
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
#     ],
#     "eventName": [
#       "CreateListener"
#     ],
#     "requestParameters": {
#       "protocol": [
#         "HTTP",
#         "HTTPS"
#       ]
#     }
#   }
# }
# PATTERN
# }
# resource "aws_cloudwatch_event_target" "cwtgt5" {
#   target_id = "AssignAlarms-ALB"
#   rule      = "${aws_cloudwatch_event_rule.trigger5.name}"
#   arn       = "${aws_lambda_function.lamb5.arn}"
# }

# resource "aws_lambda_permission" "allow_cloudwatch_event5" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = "${aws_lambda_function.lamb5.arn}"
#   principal     = "events.amazonaws.com"
#   source_arn    = "${aws_cloudwatch_event_rule.trigger5.arn}"
# }


## IAM role

resource "aws_iam_role" "cw_lambda5" {
  name = "ACME-AssignAlarms-ALB"

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



data "aws_iam_policy" "basiclamb-5" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


data "aws_iam_policy" "sns-5" {
  arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
data "aws_iam_policy" "bucket-5" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

data "aws_iam_policy" "CW5" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "basiclamb-5" {
  role       = "${aws_iam_role.cw_lambda5.name}"
  policy_arn = "${data.aws_iam_policy.basiclamb-5.arn}"
}


resource "aws_iam_role_policy_attachment" "sns-5" {
  role       = "${aws_iam_role.cw_lambda5.name}"
  policy_arn = "${data.aws_iam_policy.sns-5.arn}"
}

resource "aws_iam_role_policy_attachment" "bucket-5" {
  role       = "${aws_iam_role.cw_lambda5.name}"
  policy_arn = "${data.aws_iam_policy.bucket-5.arn}"
}


resource "aws_iam_role_policy_attachment" "CW5" {
  role       = "${aws_iam_role.cw_lambda5.name}"
  policy_arn = "${data.aws_iam_policy.CW5.arn}"
}