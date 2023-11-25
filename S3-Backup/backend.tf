terraform {
  backend "s3" {
    bucket         = "manoj-9143"
    key            = "global/mystate/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "state-lock"
  }
}
