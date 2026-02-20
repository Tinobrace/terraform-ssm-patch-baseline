resource "aws_instance" "patch_server" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (verify region!)
  instance_type = "t3.micro"

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name       = "patch-lab-server"
    PatchGroup = "production"
  }
}
