# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "install_metricserver" {
  template = file("${path.module}/scripts/install_metricserver.template.sh")

  count = var.install_metricserver == true ? 1 : 0
}

resource null_resource "install_metricserver" {
  connection {
    host        = var.oke_bastion.bastion_public_ip
    private_key = file(var.oke_ssh_keys.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"
  }

  depends_on = ["null_resource.install_kubectl_bastion", "null_resource.write_kubeconfig_bastion"]

  provisioner "file" {
    content     = data.template_file.install_metricserver[0].rendered
    destination = "~/install_metricserver.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/install_metricserver.sh",
      "$HOME/install_metricserver.sh",
      "rm -f $HOME/install_metricserver.sh"
    ]
  }

  count = var.oke_bastion.create_bastion == true && var.install_metricserver == true ? 1 : 0
}
