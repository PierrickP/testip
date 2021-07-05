provider "scaleway" {
  zone   = var.zone
  region = var.region
  version = "1.17.2"
}

terraform {
  backend "s3" {
    # region                      = var.region
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}

resource "scaleway_k8s_cluster_beta" "fluctuo_testip_cluster" {
  name             = var.fluctuo_testip_cluster_name
  version          = var.fluctuo_testip_cluster_version
  cni              = var.fluctuo_testip_cluster_cni
  enable_dashboard = false
  tags             = var.tags
}

resource "scaleway_k8s_pool_beta" "fluctuo_testip_pool" {
  cluster_id          = scaleway_k8s_cluster_beta.fluctuo_testip_cluster.id
  name                = var.fluctuo_testip_pool_name
  node_type           = var.fluctuo_testip_pool_node_type
  size                = var.fluctuo_testip_pool_size
  autoscaling         = false
  autohealing         = false
  wait_for_pool_ready = false
  container_runtime   = "docker"
  tags                = ["testip"]
}

resource "null_resource" "kubeconfig" {
  depends_on = [scaleway_k8s_pool_beta.fluctuo_testip_pool] # at least one pool here
  triggers = {
    host                   = scaleway_k8s_cluster_beta.fluctuo_testip_cluster.kubeconfig[0].host
    token                  = scaleway_k8s_cluster_beta.fluctuo_testip_cluster.kubeconfig[0].token
    cluster_ca_certificate = scaleway_k8s_cluster_beta.fluctuo_testip_cluster.kubeconfig[0].cluster_ca_certificate
  }
}

provider "kubernetes" {
  load_config_file = "false"

  host  = null_resource.kubeconfig.triggers.host
  token = null_resource.kubeconfig.triggers.token
  cluster_ca_certificate = base64decode(
    null_resource.kubeconfig.triggers.cluster_ca_certificate
  )
}

resource "scaleway_lb_ip_beta" "ip" {
}

resource "scaleway_lb_beta" "fluctuo_service_lb_staging" {
  ip_id  = scaleway_lb_ip_beta.ip.id
  region = "fr-par"
  type   = "LB-S"
}

resource "scaleway_lb_certificate_beta" "fluctuo_testip_certificate" {
  lb_id = scaleway_lb_beta.fluctuo_service_lb_staging.id
  name  = "fluctuo_testip_certificate"
  letsencrypt {
    common_name = "testip.fluctuo.dev"
    subject_alternative_name = []
  }
}

provider "helm" {
  kubernetes {
    # load_config_file = false

    host  = null_resource.kubeconfig.triggers.host
    token = null_resource.kubeconfig.triggers.token

    cluster_ca_certificate = base64decode(
      null_resource.kubeconfig.triggers.cluster_ca_certificate
    )
  }
}

resource "helm_release" "fluctuo_helm_app" {
  name       = var.fluctuo_helm_release_app_name
  chart      = "../../helm/app"

  wait = true

  timeout = 400
}

resource "helm_release" "fluctuo_nginx_ingress" {
  name      = "nginx-ingress"
  namespace = "kube-system"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  values = [templatefile("../../helm/nginx-ingress-controller/${var.fluctuo_env}/values.yml", {
    lb_id     = scaleway_lb_beta.fluctuo_service_lb_staging.id
    certif_id = trimprefix(scaleway_lb_certificate_beta.fluctuo_testip_certificate.id, "fr-par/")
  })]
}
