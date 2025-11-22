terraform {
  backend "s3" {
    bucket               = "subhash-tf-state-bucket"   # CHANGE THIS
    key                  = "workspace-demo/terraform.tfstate"
    region               = "ap-south-1"
    dynamodb_table       = "subhash-tf-locks"          # CHANGE THIS
    encrypt              = true
    workspace_key_prefix = "env"
  }
}
