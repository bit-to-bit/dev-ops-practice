variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace for Argo CD deployment"
  type        = string
  default     = "argocd"
}
