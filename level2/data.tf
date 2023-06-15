data "terraform_remote_state" "tf_remote_state" {
  backend = "s3"

  config = {
    bucket  = "tf-remote-state-ab"
    key     = "level1.tfstate"
    region  = "us-east-1"
    profile = "adrianpersonal"
  }
}
