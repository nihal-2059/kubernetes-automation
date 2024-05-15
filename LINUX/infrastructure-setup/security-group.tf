#### Create master Security group ####
resource "aws_security_group" "master-sg" {
  name        = "master-sg"
  description = "Master Node Security Group"

  //ingress rules for tcp protocol
  dynamic "ingress" {
    for_each = var.master-ports
    content {
      description = lookup(var.ports-desc, ingress.value)
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp" //contains(var.udp-ports, ingress.value) ? "udp" : "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  //ingress riles for udp protocol
  dynamic "ingress" {
    for_each = var.udp-ports
    content {
      description = lookup(var.ports-desc, ingress.value)
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "udp" //contains(var.udp-ports, ingress.value) ? "udp" : "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  //nodeport ports ingress
  ingress {
    description = "Nodeport Ports"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "master-sg"
  }
}

#### Create Worker Nodes Security Group ####
resource "aws_security_group" "worker-sg" {
  name        = "worker-sg"
  description = "Worker Node Security Group"

  //ingress for tcp protocol
  dynamic "ingress" {
    for_each = var.worker-ports
    content {
      description = lookup(var.ports-desc, ingress.value)
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp" //contains(var.udp-ports, ingress.value) ? "udp" : "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  //ingress for udp protocol
  dynamic "ingress" {
    for_each = var.udp-ports
    content {
      description = lookup(var.ports-desc, ingress.value)
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "udp" //contains(var.udp-ports, ingress.value) ? "udp" : "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  //nodeport ports ingress
  ingress {
    description = "Nodeport Ports"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "worker-sg"
  }
}

