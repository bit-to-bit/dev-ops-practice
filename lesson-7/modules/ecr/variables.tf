variable "ecr_name" {
  description = "ECR repository name"
  type        = string
}

variable "scan_on_push" {
  description = "Whether to enable image scanning on download"
  type        = bool
  default     = true
}

variable "allowed_account_ids" {
  description = "List of AWS Account IDs that are allowed to access the repository"
  type        = list(string)
}