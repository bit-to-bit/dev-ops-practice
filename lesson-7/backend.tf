terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-282a7c32-de00-49e6-ae2b-17d0ec4ff2e1"
    key            = "lesson-7/terraform.tfstate"   
    region         = "eu-west-1"                    
    dynamodb_table = "terraform-locks"              
    encrypt        = true                           
  }
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}