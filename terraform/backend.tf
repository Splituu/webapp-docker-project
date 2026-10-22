terraform {
  backend "s3" {
    bucket = "giy-terraform-state"
    key    = "webapp/terraform.tfstate"
    region = "eu-central-1"
    encrypt = true
    use_lockfile = true
  }
}
