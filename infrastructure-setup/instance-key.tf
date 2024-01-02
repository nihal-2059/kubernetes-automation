resource "aws_key_pair" "main-key-pair" {
  key_name   = "main-key-pair"
  public_key = file("${path.module}/id_rsa.pub")
}