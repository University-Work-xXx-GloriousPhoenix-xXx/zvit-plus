terraform {
  backend "s3" {
    bucket       = "zvit-plus-terraform-state-290679927628"
    key          = "zvit-plus/terraform.tfstate"
    region       = "eu-north-1"
    profile      = "zvit-plus"
    encrypt      = true
    use_lockfile = true
  }
}