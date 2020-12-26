
variable "functionname7" {
    default = "ACME-AssignAlarms-NLB"
}
variable "sns_topic_name7" {
    default = "ACME-AssignAlarms-NLB-SNS"
}


# Create deployment file in zip formate
data "archive_file" "zip7" {
  type        = "zip"
  source_file = "${path.module}/Python/ACME-AssignAlarms-NLB.py"
  output_path = "${path.module}/Python/ACME-AssignAlarms-NLB.zip"
}

#Lambda Function resource
resource "aws_lambda_function" "lamb7" {
    filename         = "${path.module}/Python/${var.functionname7}.zip"
    function_name    = "${var.functionname7}"
    timeout          = 90
    runtime          = "python3.6"
    role             = "${aws_iam_role.cw_lambda7.arn}"
    handler          = "${var.functionname7}.lambda_handler"
    source_code_hash = "${data.archive_file.zip7.output_base64sha256}"
    environment {
        variables = {
            Sns_Topic_Arn  = "${aws_sns_topic.sns7.arn}"
        }
    }
}

## SNS TOPIC
resource "aws_sns_topic" "sns7" {
  name = "${var.sns_topic_name7}"
}


# ## CLOUWATCH EVENT Trigger

# resource "aws_cloudwatch_event_rule" "trigger7" {
#   name        = "ACME-AssignAlarms-NLB-CW"
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
#         "TCP"
#       ]
#     }
#   }
# }
# PATTERN
# }
# resource "aws_cloudwatch_event_target" "cwtgt7" {
#   target_id = "ACME-AssignAlarms-NLB"
#   rule      = "${aws_cloudwatch_event_rule.trigger7.name}"
#   arn       = "${aws_lambda_function.lamb7.arn}"
# }

# resource "aws_lambda_permission" "allow_cloudwatch_event7" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = "${aws_lambda_function.lamb7.arn}"
#   principal     = "events.amazonaws.com"
#   source_arn    = "${aws_cloudwatch_event_rule.trigger7.arn}"
# }


## IAM role

resource "aws_iam_role" "cw_lambda7" {
  name = "ACME-AssignAlarms-NLB"

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



data "aws_iam_policy" "basiclamb-7" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


data "aws_iam_policy" "sns-7" {
  arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
data "aws_iam_policy" "bucket-7" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

data "aws_iam_policy" "CW7" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "basiclamb-7" {
  role       = "${aws_iam_role.cw_lambda7.name}"
  policy_arn = "${data.aws_iam_policy.basiclamb-7.arn}"
}


resource "aws_iam_role_policy_attachment" "sns-7" {
  role       = "${aws_iam_role.cw_lambda7.name}"
  policy_arn = "${data.aws_iam_policy.sns-7.arn}"
}

resource "aws_iam_role_policy_attachment" "bucket-7" {
  role       = "${aws_iam_role.cw_lambda7.name}"
  policy_arn = "${data.aws_iam_policy.bucket-7.arn}"
}


resource "aws_iam_role_policy_attachment" "CW7" {
  role       = "${aws_iam_role.cw_lambda7.name}"
  policy_arn = "${data.aws_iam_policy.CW7.arn}"
}