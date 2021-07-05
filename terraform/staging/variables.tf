variable "region" {
  description = "Scaleway Region"
  type        = string
  default     = "fr-par"
}

variable "zone" {
  description = "Scaleway Zone"
  type        = string
  default     = "fr-par-1"
}

variable "fluctuo_testip_cluster_name" {
  type        = string
  description = "Fluctuo Cluster Name"
}

variable "fluctuo_testip_cluster_version" {
  type        = string
  description = "Fluctuo Cluster Version"
}

variable "fluctuo_testip_cluster_cni" {
  type        = string
  description = "Fluctuo Cluster CNI"
}

variable "tags" {
  type        = list(string)
  description = "Tags"
}

variable "fluctuo_testip_pool_name" {
  type        = string
  description = "Fluctuo Staging Pool Name"
}

variable "fluctuo_testip_pool_node_type" {
  type        = string
  description = "Fluctuo Staging Pool node type"
}

variable "fluctuo_testip_pool_size" {
  type        = string
  description = "Fluctuo Staging Pool size"
}

variable "fluctuo_helm_release_app_name" {
  type        = string
  description = "Fluctuo Helm Release ArgoCD Name"
}

variable "fluctuo_env" {
  type        = string
  description = "Fluctuo Env"
}

variable "fluctuo_ingress_argocd_wait_for_load_balancer" {
  type        = bool
  description = "Fluctio Ingress Argocd Waiting load balancer"
}
