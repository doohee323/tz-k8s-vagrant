#------------------------------------------------------------------------------#
# EC2 instances
#------------------------------------------------------------------------------#

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = var.master_instance_type
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    aws_security_group.egress.id,
    aws_security_group.ingress_internal.id,
    aws_security_group.ingress_k8s.id,
    aws_security_group.ingress_ssh.id
  ]
  tags      = merge(local.tags, { "terraform-kubeadm:node" = "master" })
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # iam instance profile
  iam_instance_profile = aws_iam_instance_profile.master-role.name

  # user data
  user_data = data.template_cloudinit_config.cloudinit-master.rendered

}

resource "aws_ebs_volume" "master-data" {
  availability_zone = "us-west-1a"
  size              = 20
  type              = "gp2"
  tags = {
    Name = "master-data"
  }
}

resource "aws_volume_attachment" "master-data-attachment" {
  device_name  = var.INSTANCE_DEVICE_NAME
  volume_id    = aws_ebs_volume.master-data.id
  instance_id  = aws_instance.master.id
  skip_destroy = true
}

resource "aws_instance" "workers" {
  count                       = var.num_workers
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = var.worker_instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = false
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    aws_security_group.egress.id,
    aws_security_group.ingress_internal.id,
    aws_security_group.ingress_ssh.id
  ]
  tags      = merge(local.tags, { "terraform-kubeadm:node" = "worker-${count.index}" })
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  user_data = <<-EOF
  #!/bin/bash

  # Install kubeadm and Docker
  apt-get update
  apt-get install -y apt-transport-https curl
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
  apt-get update
  apt-get install -y docker.io kubeadm

  # Run kubeadm
  kubeadm join ${aws_instance.master.private_ip}:6443 \
    --token ${local.token} \
    --discovery-token-unsafe-skip-ca-verification \
    --node-name worker-${count.index}

  # Indicate completion of bootstrapping on this node
  touch /home/ubuntu/done
  EOF

  provisioner "file" {
    source      = "scripts/node-init.sh"
    destination = "/home/ubuntu/node-init.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_file)
      host        = self.public_dns
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/node-init.sh",
      "/home/ubuntu/node-init.sh ${var.INSTANCE_DEVICE_NAME} ${count.index}",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_file)
      host        = self.public_dns
    }
  }
}
