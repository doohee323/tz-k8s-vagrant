data "template_file" "master-init" {
  template = file("scripts/master-init.sh")
  vars = {
    DEVICE            = var.INSTANCE_DEVICE_NAME
    local_token = local.token
    aws_eip_master_public_ip = aws_eip.master.public_ip
//    var_pod_network_cidr_block = var.pod_network_cidr_block
  }
}

data "template_cloudinit_config" "cloudinit-master" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.master-init.rendered
  }
}
