provider "aws" {
  region     = "eu-central-1"
  profile    = "student" # Ersetzen Sie dies durch Ihre Region
  access_key = "ASIAVEEYQMUKGAXLPBXL" # Ersetzen Sie dies durch Ihren Access Key
  secret_key = "pXdT1BBh1zLTbaBPCpae7RHw7agt482XSAnN3VUy" # Ersetzen Sie dies durch Ihren Secret Key
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-deployer"
  public_key = file("/mnt/c/Users/rajam/123.pem") # Ersetzen Sie dies durch Ihren Key-Pfad
}

resource "aws_security_group" "prometheus_sg" {
  name        = "prometheus-sg"
  description = "Security group for Prometheus EC2 instance"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["91.9.14.150"] # Ersetzen Sie dies durch Ihre IP-Adresse
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "prometheus_server" {
  ami           = "ami-06dd92ecc74fdfb36" 
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  security_groups = [aws_security_group.prometheus_sg.name]

  tags = {
    Name = "Prometheus Server"
  }
}

resource "aws_instance" "node_server" {
  ami           = "ami-06dd92ecc74fdfb36"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  security_groups = [aws_security_group.prometheus_sg.name]

  tags = {
    Name = "Node Server"
  }
}

output "prometheus_server_ip" {
  value = aws_instance.prometheus_server.public_ip
}

output "node_server_ip" {
  value = aws_instance.node_server.public_ip
}
