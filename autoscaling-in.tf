#
# Lambda function to scale down(in) container instances. Checks every 5 minutes for instances
# without any pending or running containers. If they exist, it begins shutting them down 50% at a time.
# See https://github.com/gadgetry-io/scale-in-ecs for details
#

// create role for autoscaling in lambda function
resource "aws_iam_role" "ecs_autoscale_in" {
  name = "${terraform.workspace}-ecs-autoscale-in"

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

// set permissions for role
resource "aws_iam_role_policy" "ecs_autoscale_in" {
  name = "ecs_autoscale_in"
  role = "${aws_iam_role.ecs_autoscale_in.id}"

  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"",
         "Effect":"Allow",
         "Action":[
            "logs:*",
            "cloudwatch:GetMetricData",
            "ec2:TerminateInstances",
            "ecs:ListContainerInstances",
            "ecs:DescribeContainerInstances"
         ],
         "Resource":"*"
      }
   ]
}
EOF
}

// Create lambda function
resource "aws_lambda_function" "ecs_autoscale_in" {
  function_name    = "${terraform.workspace}-scale-in-ecs"
  s3_bucket        = "${var.s3_bucket}"
  s3_key           = "${var.s3_key}"
  role             = "${aws_iam_role.ecs_autoscale_in.arn}"
  handler          = "scale-in-ecs"
  source_code_hash = "${var.source_code_hash}"
  runtime          = "go1.x"

  environment {
    variables = {
      CLUSTER                    = "${terraform.workspace}"
      DESIRED_MEMORY_RESERVATION = "${aws_cloudwatch_metric_alarm.scale_out_ecs.threshold}"
    }
  }

  lifecycle {
    ignore_changes = ["last_modified"]
  }
}

// create schedule
resource "aws_cloudwatch_event_rule" "ecs_autoscale_in" {
  name                = "${aws_lambda_function.ecs_autoscale_in.function_name}"
  description         = "Scale in ECS cluster"
  schedule_expression = "rate(1 minute)"
}

// link rule to execute lambda
resource "aws_cloudwatch_event_target" "ecs_autoscale_in" {
  target_id = "${aws_lambda_function.ecs_autoscale_in.function_name}"
  rule      = "${aws_cloudwatch_event_rule.ecs_autoscale_in.name}"
  arn       = "${aws_lambda_function.ecs_autoscale_in.arn}"
}

// give cloudwatch permission to execute the lambda
resource "aws_lambda_permission" "ecs_autoscale_in" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ecs_autoscale_in.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ecs_autoscale_in.arn}"
}
