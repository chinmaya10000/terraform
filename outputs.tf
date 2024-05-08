output "ec2_public_ip" {
  value = module.myapp-srver.instance.public_ip
}
