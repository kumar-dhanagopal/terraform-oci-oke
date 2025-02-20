# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.oke_identity.compartment_id
  kubernetes_version = local.kubernetes_version
  kms_key_id         = var.oke_cluster.use_encryption == true ? var.oke_cluster.kms_key_id : null
  name               = "${var.oke_general.label_prefix}-${var.oke_cluster.cluster_name}"

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = var.oke_cluster.cluster_options_add_ons_is_kubernetes_dashboard_enabled
      is_tiller_enabled               = var.oke_cluster.cluster_options_add_ons_is_tiller_enabled
    }

    kubernetes_network_config {
      pods_cidr     = var.oke_cluster.cluster_options_kubernetes_network_config_pods_cidr
      services_cidr = var.oke_cluster.cluster_options_kubernetes_network_config_services_cidr
    }

    service_lb_subnet_ids = var.lbs.preferred_lb_subnets == "public" ? [var.oke_cluster.cluster_subnets["pub_lb"]] : [var.oke_cluster.cluster_subnets["int_lb"]]
  }

  vcn_id = var.oke_cluster.vcn_id
}
