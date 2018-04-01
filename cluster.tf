resource "aws_ecs_cluster" "main" {
  name = "${var.cluster_name}"
}

output "arn" {
  value = "${aws_ecs_cluster.main.id}"
}
