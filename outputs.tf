output "aws_ami_id" {
  value = data.aws_ami.latest-ubuntu.id
}

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
}