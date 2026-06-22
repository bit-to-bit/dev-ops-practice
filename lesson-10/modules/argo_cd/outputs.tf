output "argocd_server_url" {
  description = "URL for the Argo CD UI (wait for LoadBalancer to provision)"
  value       = "http://localhost:8080" # This depends on LB, fetch from k8s service
}
