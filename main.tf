provider "aws" {

  region     = "us-east-1"
 shared_credentials_files = ["~/.aws/credentials"]

}

resource "aws_vpc" "sl-vpc" {
  cidr_block       = "10.0.0.0/16"
tags = {
    Name = "sl-vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.sl-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch  = true
  depends_on = [aws_vpc.sl-vpc]
  tags = {
    Name = "sl-subnet"
  }
}

resource "aws_route_table" "sl-route-table" {
  vpc_id = aws_vpc.sl-vpc.id
  tags = {
    Name = "sl-route-table"
  }

}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.sl-route-table.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.sl-vpc.id
  depends_on = [aws_vpc.sl-vpc]
  tags = {
    Name = "sl-gw"
  }
}

resource "aws_route" "sl-route" {
  route_table_id = aws_route_table.sl-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id  = aws_internet_gateway.gw.id
}

resource "aws_security_group" "sl-sg" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.sl-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sl-sg"
  }
}

resource "tls_private_key" "web-key" {
  algorithm   = "RSA"
}

resource "aws_key_pair" "app-key" {
  key_name   = "web-key"
  public_key = tls_private_key.web-key.public_key_openssh
}

resource "local_file" "web-key" {
  content  = tls_private_key.web-key.private_key_pem
  filename = "web-key.pem"
}

resource "aws_instance" "myec2" {
  ami = "ami-04823729c75214919"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet-1.id
  key_name = "web-key"
  security_groups = [aws_security_group.sl-sg.id]
  tags = {
    Name = "Webserver"
 }

provisioner "remote-exec" {
   connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.web-key.private_key_pem
    host     = self.public_ip
  }
    inline = [
      "sudo yum install httpd php -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd"
    ]
  }

}
