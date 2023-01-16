
#Created by Christian Tchimi
#last modified date 01/16/2022


variable "awsprops" {
    type = map(string)
    default = {
    region = "us-east-1"
    vpc = "vpc-0f3e2b4a4b5da755a"
    ami = "ami-026b57f3c383c2eec"
    itype = "t2.micro"
    subnet = "subnet-0fb7c4dd98c4f6e41"
    publicip = true
    keyname = "devops-key"
    groupname_sec = "ansible-sg"
  }
}

provider "aws" {
  region = lookup(var.awsprops, "region")
}

resource "aws_security_group" "project-iac-sec" {
  name = lookup(var.awsprops, "groupname_sec")
  description = lookup(var.awsprops, "groupname_sec")
  vpc_id = lookup(var.awsprops, "vpc")

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Creation server1

resource "aws_instance" "project-iac" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")
  user_data                   = <<EOF
                    #!/bin/bash
                    sudo yum update -y && sudo yum install -y docker
                    sudo systemctl start docker
                    sudo usermod -aG docker ec2-user
                    docker run -d -p 80:80 amigoscode/2048
                EOF


  vpc_security_group_ids = [
    aws_security_group.project-iac-sec.id
  ]
  
  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.project-iac-sec ]
}


output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}


#Creation server2

resource "aws_instance" "project-iac2" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")
  user_data                   = <<EOF
                    #!/bin/bash
                    sudo yum update -y && sudo yum install -y docker
                    sudo systemctl start docker
                    sudo usermod -aG docker ec2-user
                    docker run -d -p 80:80 amigoscode/2048
                EOF


  vpc_security_group_ids = [
    aws_security_group.project-iac-sec.id
  ]
  
  tags = {
    Name ="SERVER02"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.project-iac-sec ]
}


output "ec2instance2" {
 
  value = aws_instance.project-iac2.public_ip
}