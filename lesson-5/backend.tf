terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-282a7c32-de00-49e6-ae2b-17d0ec4ff2e1"
    key            = "lesson-5/terraform.tfstate"   
    region         = "eu-west-1"                    
    dynamodb_table = "terraform-locks"              
    encrypt        = true                           
  }
}