variable "db_username" {
  description = "The database username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true
  default     = "SuperSecret123!" # Для навчальних цілей, але в реальному житті це значення має передаватися через змінні середовища (TF_VAR_db_password)
}
