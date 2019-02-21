data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"

  vars {
    ecs_cluster          = "${aws_ecs_cluster.main.name}"
    env                  = "${terraform.workspace}"
    efs_id               = "${aws_efs_file_system.main.id}"
    dockerhub_username   = "${var.dockerhub_username}"
    dockerhub_password   = "${var.dockerhub_password}"
    additional_user_data = "${var.additional_user_data}"
    dm_basesize          = "${var.dm_basesize}"
  }
}
