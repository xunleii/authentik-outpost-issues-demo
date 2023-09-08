terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2023.8.0"
    }
  }
}

provider "authentik" {
  url   = "http://authentik.127-0-0-1.nip.io"
  token = "aktoken"
}

data "authentik_flow" "default_authorization_flow" { slug = "default-provider-authorization-explicit-consent" }

resource "authentik_provider_proxy" "debug" {
  name               = "debug"
  external_host      = "http://debug.127-0-0-1.nip.io"
  authorization_flow = data.authentik_flow.default_authorization_flow.id

  mode = "forward_single"
}

resource "authentik_application" "debug" {
  name              = "debug"
  slug              = "debug"
  protocol_provider = authentik_provider_proxy.debug.id
}

locals {
  kubeconfig = yamldecode(file(".direnv/kube/config"))
  patch = {
    "clusters" : [
      {
        "cluster" : {
          "certificate-authority-data" : local.kubeconfig.clusters[0].cluster["certificate-authority-data"],
          "server" : "https://kubernetes.default.svc.cluster.local"
        },
        "name" : local.kubeconfig.clusters[0].name
      }
    ],
  }
  kubeconfig_patched = merge(local.kubeconfig, local.patch)
}
resource "authentik_service_connection_kubernetes" "default" {
  name       = "default"
  kubeconfig = jsonencode(local.kubeconfig_patched)
}

resource "authentik_outpost" "default" {
  name = "in-cluster outpost"
  protocol_providers = [
    authentik_provider_proxy.debug.id
  ]

  config = jsonencode({
    "authentik_host_browser" : "",
    "authentik_host_insecure" : false,
    "authentik_host" : "http://authentik.authentik.svc.cluster.local",
    "kubernetes_disabled_components" : [],
    "kubernetes_image_pull_secrets" : [],
    "kubernetes_ingress_annotations" : {},
    "kubernetes_ingress_secret_name" : "authentik-outpost-tls"
    "kubernetes_namespace" : "authentik",
    "kubernetes_replicas" : 3,
    "kubernetes_service_type" : "ClusterIP",
    "log_level" : "trace",
    "object_naming_template" : "ak-outpost-default",
  })
  service_connection = authentik_service_connection_kubernetes.default.id
  type               = "proxy"
}
