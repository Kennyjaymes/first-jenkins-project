terraform {
  backend "s3" {
    bucket         = "darky-jenkins-project"
    key            = "First-jenkins-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
