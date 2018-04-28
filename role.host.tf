data "aws_iam_policy_document" "ecs_host" {
  statement = [
    {
      effect = "Allow"

      actions = [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ec2:Get*",
        "ec2:Describe*",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:PutLogEvents",
        "cloudwatch:Get*",
        "cloudwatch:Describe*",
        "cloudwatch:List*",
        "cloudwatch:Put*",
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:DescribeMountTargets",
      ]

      resources = ["*"]
    },
  ]
}

resource "aws_iam_policy" "ecs_host" {
  name   = "${var.cluster_name}-ecs-host"
  path   = "/"
  policy = "${data.aws_iam_policy_document.ecs_host.json}"
}

data "aws_iam_policy_document" "ecs_host_role" {
  statement = [
    {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals = [
        {
          type        = "Service"
          identifiers = ["ec2.amazonaws.com"]
        },
      ]
    },
  ]
}

resource "aws_iam_role" "ecs_host" {
  name               = "${terraform.workspace}-ecs-host"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_host_role.json}"
}

resource "aws_iam_instance_profile" "ecs_host" {
  name = "${terraform.workspace}-ecs-host"
  role = "${aws_iam_role.ecs_host.name}"
}

resource "aws_iam_role_policy_attachment" "ecs_host" {
  role       = "${aws_iam_role.ecs_host.name}"
  policy_arn = "${aws_iam_policy.ecs_host.arn}"
}
