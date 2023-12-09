data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "token" {}

provider "docker" {
    registry_auth {
        address = "${data.aws_caller_identity.ecr_identity.account_id}.dkr.ecr.${var.region}.amazonaws.com"
        username = data.aws_ecr_authorization_token.token.user_name
        password = data.aws_ecr_authorization_token.token.password
        
    }
}