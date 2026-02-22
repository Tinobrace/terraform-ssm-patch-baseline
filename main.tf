module "patching" {
  source = "./modules/ssm-patch"

  instance_type = "t3.micro"
  environment   = "dev"
}