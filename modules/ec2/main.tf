data "aws_ami" "amzn_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_iam_instance_profile" "ssm" {
  name = "ssm_managed_instance"
  role = "SSM"
}

resource "aws_instance" "gitea" {
  ami                  = data.aws_ami.amzn_linux.id
  instance_type        = "t2.small"
  key_name             = "kokwayaws"
  iam_instance_profile = aws_iam_instance_profile.ssm.name
  vpc_security_group_ids = [var.sg_ec2]
  subnet_id            = var.subnet_id
  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp3"
    tags = {
      Name = "test_gitea"
    }
  }
  user_data = <<EOF
  #!/bin/bash -ex
  sudo yum update -y
  sudo yum update -y
  sudo amazon-linux-extras install docker
  sudo service docker start
  sudo systemctl enable docker.service
  sudo systemctl start docker.service
  sudo usermod -a -G docker ec2-user
  sudo chkconfig docker on
  sudo pip3 install --upgrade pip
  sudo python3 -m pip install docker-compose
  sudo mkdir -v -p /usr/local/bin/gitea
  sudo chmod 777 /usr/local/bin/gitea

 EOF

  tags = {
    "Name" = "test_gitea"
  }
  depends_on = [var.sg_ec2]
}

resource "aws_eip" "public-ip" {
  instance = aws_instance.gitea.id
  vpc      = true
}

resource "null_resource" "provisioner" {
  
  provisioner "file" {
    source      = "modules/ec2/file/docker-compose.yaml"
    destination = "/usr/local/bin/gitea/docker-compose.yaml"
    connection {   
      host        = aws_instance.gitea.public_ip
      user        = "ec2-user"
      private_key = file("${path.module}/file/kokwayaws.pem")
    }   
  }

  provisioner "remote-exec" {
    inline = [
      "cd /usr/local/bin/gitea",
      "docker-compose -f ./docker-compose.yaml up -d",
    ]
    connection {   
      host        = aws_instance.gitea.public_ip
      user        = "ec2-user"
      private_key = file("${path.module}/file/kokwayaws.pem")
    }  
  }
}