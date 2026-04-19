output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}

output "table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}

output "table_arn" {
  value = aws_dynamodb_table.terraform_locks.arn
}