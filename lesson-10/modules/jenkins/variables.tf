variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace for Jenkins deployment"
  type        = string
  default     = "jenkins"
}
