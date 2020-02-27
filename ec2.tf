provider "aws" {
  region = "eu-west-2"
}

resource "aws_security_group" "web_access_ec2" {
  name = "ec2_web_access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "first_ec2" {
  ami = "ami-0389b2a3c4948b1a0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_access_ec2.id]
  
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

