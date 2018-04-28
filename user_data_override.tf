data "template_file" "user_data" {
  template = "${file("${path.module}/user_data_govcloud.sh.tpl")}"

  vars {
    ecs_cluster        = "${aws_ecs_cluster.main.name}"
    env                = "${terraform.workspace}"
    dockerhub_username = "${var.dockerhub_username}"
    dockerhub_password = "${var.dockerhub_password}"
  }
}
