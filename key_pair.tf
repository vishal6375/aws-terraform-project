resource "aws_key_pair" "key-tf" {
  key_name = "key-tf"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIGYVNSpR4UrFTa+Q9XrGml/ZcAnDzGJm8RiLrqu5Wd4 root@terraform.vishal"
}