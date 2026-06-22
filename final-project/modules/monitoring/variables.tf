variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace for monitoring tools"
  type        = string
  default     = "monitoring"
}
