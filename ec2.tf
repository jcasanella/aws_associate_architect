provider "aws" {
  region = "eu-west-2"
}

data "aws_vpcs" "foo" {
  filter {
    name   = "tag:Name"
    values = ["VPC_Jordi2"]
  }
}

output "foo" {
  value = "${data.aws_vpcs.foo.ids}"
}

data "aws_subnet" "selected" {
  filter {
    name   = "vpc-id"
    values = [sort(data.aws_vpcs.foo.ids)[0]]
  }

  filter {
    name   = "tag:Name"
    values = ["PublicSubnetA"]
  }
}

output "selected" {
  value = "${data.aws_subnet.selected.id}"
}

resource "aws_security_group" "web_access_ec2" {
  name   = "ec2_web_access"
  vpc_id = sort(data.aws_vpcs.foo.ids)[0]

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "first_ec2" {
  ami                    = "ami-0389b2a3c4948b1a0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_access_ec2.id]
  subnet_id              = data.aws_subnet.selected.id

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              cd /var/www/html
              echo "<h1>Instance created</h1>" > index.html
              EOF

  tags = {
    Name = "jordi-ec2"
  }
}

output "public_ip" {
  value       = aws_instance.first_ec2.public_ip
  description = "The public IP of the web server"
}

