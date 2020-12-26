
variable "functionname6" {
    default = "ACME-AssignAlarms-RDS"
}
variable "sns_topic_name6" {
    default = "ACME-AssignAlarms-RDS-SNS"
}


# Create deployment file in zip formate
data "archive_file" "zip6" {
  type        = "zip"
  source_file = "${path.module}/Python/ACME-AssignAlarms-RDS.py"
  output_path = "${path.module}/Python/ACME-AssignAlarms-RDS.zip"
}

#Lambda Function resource
resource "aws_lambda_function" "lamb6" {
    filename         = "${path.module}/Python/${var.functionname6}.zip"
    function_name    = "${var.functionname6}"
    timeout          = 90
    runtime          = "python3.6"
    role             = "${aws_iam_role.cw_lambda6.arn}"
    handler          = "${var.functionname6}.lambda_handler"
    source_code_hash = "${data.archive_file.zip6.output_base64sha256}"
    environment {
        variables = {
            Sns_Topic_Arn  = "${aws_sns_topic.sns5.arn}"
        }
    }
}

## SNS TOPIC
resource "aws_sns_topic" "sns6" {
  name = "${var.sns_topic_name6}"
  display_name = "RDS Alarm - HighCpu, StorageFreeSpace"
}


## CLOUWATCH EVENT Trigger

# resource "aws_cloudwatch_event_rule" "trigger6" {
#   name        = "AssignAlarms-RDS-CW"
#   description = "This is event rule trigger every time an instances changes to pending state"

#   event_pattern = <<PATTERN
# {
#   "detail-type": [
#     "AWS API Call via CloudTrail"
#   ],
#   "source": [
#     "aws.rds"
#   ],
#   "detail": {
#     "eventSource": [
#       "rds.amazonaws.com"
#     ],
#     "eventName": [
#       "CreateDBInstance"
#     ]
#   }
# }
# PATTERN
# }
# resource "aws_cloudwatch_event_target" "cwtgt6" {
#   target_id = "AssignAlarms-RDS"
#   rule      = "${aws_cloudwatch_event_rule.trigger6.name}"
#   arn       = "${aws_lambda_function.lamb6.arn}"
# }

# resource "aws_lambda_permission" "allow_cloudwatch_event6" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = "${aws_lambda_function.lamb6.arn}"
#   principal     = "events.amazonaws.com"
#   source_arn    = "${aws_cloudwatch_event_rule.trigger6.arn}"
# }


## IAM role

resource "aws_iam_role" "cw_lambda6" {
  name = "ACME-AssignAlarms-RDS"

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



data "aws_iam_policy" "basiclamb-6" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


data "aws_iam_policy" "sns-6" {
  arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
data "aws_iam_policy" "bucket-6" {
  arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

data "aws_iam_policy" "CW6" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "basiclamb-6" {
  role       = "${aws_iam_role.cw_lambda6.name}"
  policy_arn = "${data.aws_iam_policy.basiclamb-6.arn}"
}


resource "aws_iam_role_policy_attachment" "sns-6" {
  role       = "${aws_iam_role.cw_lambda6.name}"
  policy_arn = "${data.aws_iam_policy.sns-6.arn}"
}

resource "aws_iam_role_policy_attachment" "bucket-6" {
  role       = "${aws_iam_role.cw_lambda6.name}"
  policy_arn = "${data.aws_iam_policy.bucket-6.arn}"
}


resource "aws_iam_role_policy_attachment" "CW6" {
  role       = "${aws_iam_role.cw_lambda6.name}"
  policy_arn = "${data.aws_iam_policy.CW6.arn}"
}