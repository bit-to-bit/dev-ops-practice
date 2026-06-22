output "endpoint" {
  description = "The connection endpoint for the database"
  value       = try(aws_rds_cluster.this[0].endpoint, aws_db_instance.this[0].address, "")
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.this.id
}

output "db_name" {
  description = "The database name"
  value       = var.db_name
}
