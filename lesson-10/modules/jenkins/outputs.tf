output "jenkins_url" {
  description = "URL for the Jenkins UI (wait for LoadBalancer to provision)"
  value       = "http://localhost:8080" # This depends on LB, but normally you'd fetch from kubernetes_service
}
