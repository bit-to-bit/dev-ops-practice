variable "use_aurora" {
  description = "If true, creates an Aurora cluster. If false, creates a regular RDS instance."
  type        = bool
  default     = false
}

variable "engine" {
  description = "The database engine to use (e.g., postgres, mysql, aurora-postgresql)"
  type        = string
}

variable "engine_version" {
  description = "The version of the database engine"
  type        = string
}

variable "parameter_group_family" {
  description = "The family of the DB parameter group (e.g., postgres14, aurora-postgresql14)"
  type        = string
}

variable "instance_class" {
  description = "The instance class for the database"
  type        = string
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
}

variable "password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "The VPC ID where the database will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  type        = number
}
