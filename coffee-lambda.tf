resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Put semi-secrets into parameter store with the following names
data "aws_ssm_parameter" "webhook_path" {
  # asdfadfasdfadsf/asdfasdfasdf/asdfasdfasdf
  name = "COFFEE_BOT_WEBHOOK_PATH"
}
data "aws_ssm_parameter" "coffee_brewing_button_dsn" {
  # GO3<.....>
  name = "COFFEE_BOT_BUTTON_DSN"
}
data "archive_file" "coffee_brewing_lambda_zip" {
    type        = "zip"
    source_dir  = "coffee-lambda"
    output_path = ".coffee-lambda.zip"
}
resource "aws_lambda_function" "coffee_brewing" {
  filename = ".coffee-lambda.zip"
  source_code_hash = "${data.archive_file.coffee_brewing_lambda_zip.output_base64sha256}"
  function_name = "coffee_brewing"
  role = "${aws_iam_role.iam_for_lambda.arn}"
  description = "Lambda to notify slack when coffee starts brewing"
  handler = "index.handler"
  runtime = "nodejs8.10"
  timeout = 15
  environment {
    variables = {
      webhook_path = data.aws_ssm_parameter.webhook_path.value
    }
  }
}

resource "aws_iot_thing" "coffee_brewing_button" {
  name = "iotbutton_${data.aws_ssm_parameter.coffee_brewing_button_dsn.value}"

  attributes = {
    dsn = data.aws_ssm_parameter.coffee_brewing_button_dsn.value
    type  = "iotbutton"
  }
}

resource "aws_iot_topic_rule" "coffee_brewing_button_pushed" {
  name = "coffee_brewing_button_pushed"
  description = "Triggers when the coffee_brewing button has been pushed"
  sql = "SELECT * FROM 'iotbutton/${data.aws_ssm_parameter.coffee_brewing_button_dsn.value}'"
  sql_version = "2016-03-23"
  enabled = true
  lambda {
    function_arn = aws_lambda_function.coffee_brewing.arn
  }
}
