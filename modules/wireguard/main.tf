locals {
  tags = {
    Project  = "wireguard"
    Name = aws_launch_configuration.wireguard_launch_config.name
  }

  # turn the sg into a sorted list of string
  sg_wireguard_external = sort([aws_security_group.sg_wireguard_external.id])

  # clean up and concat the above wireguard default sg with the additional_security_group_ids
  security_groups_ids = compact(concat(var.additional_security_group_ids, local.sg_wireguard_external))
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.txt")

  vars = {
    wg_server_port        = var.wg_server_port
    peers                 = join("\n", data.template_file.wg_client_data_json.*.rendered)
  }
}

data "template_file" "wg_client_data_json" {
  template = file("${path.module}/templates/client-data.tpl")
  count    = length(var.wg_client_public_keys)

  vars = {
    client_pub_key       = element(values(var.wg_client_public_keys[count.index]), 0)
    client_ip            = element(keys(var.wg_client_public_keys[count.index]), 0)
    persistent_keepalive = var.wg_persistent_keepalive
  }
}

# We're using ubuntu images - this lets us grab the latest image for our region from Canonical
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_instances" "wireguards" {
  instance_tags = local.tags

  depends_on = [aws_autoscaling_group.wireguard_asg]
}

resource "aws_launch_configuration" "wireguard_launch_config" {
  name_prefix                 = "wireguard-${var.env}-"
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_id
  user_data                   = data.template_file.user_data.rendered
  security_groups             = local.security_groups_ids

  associate_public_ip_address = var.use_eip

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "wireguard_asg" {
  name                 = aws_launch_configuration.wireguard_launch_config.name
  launch_configuration = aws_launch_configuration.wireguard_launch_config.name
  min_size             = var.asg_min_size
  desired_capacity     = var.asg_desired_capacity
  max_size             = var.asg_max_size
  vpc_zone_identifier  = [var.subnet.id]
  health_check_type    = "EC2"
  termination_policies = ["OldestLaunchConfiguration", "OldestInstance"]
  target_group_arns    = var.target_group_arns

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = aws_launch_configuration.wireguard_launch_config.name
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "wireguard"
      propagate_at_launch = true
    },
    {
      key                 = "env"
      value               = var.env
      propagate_at_launch = true
    },
    {
      key                 = "tf-managed"
      value               = "True"
      propagate_at_launch = true
    },
  ]
}
