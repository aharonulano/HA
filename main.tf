resource "aws_vpc" "main" {
  cidr_block           = var.cidr_blocks[0]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main--igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr_blocks[1]
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
  tags = {
    Name = "public-subnet"
  }
}


resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_blocks[2]
  availability_zone = "eu-west-1b"
  tags = {
    Name = "private-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
  }

}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private.id
}


# Security Group for NAT Instance
resource "aws_security_group" "sg_for_nat_instance" {
  name        = "sg_for_nat_instance"
  description = "Security Group for NAT instance"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "gnat-instance"
  }
}

# NAT Instance Security group rule to allow SSH from remote ip
resource "aws_security_group_rule" "remote_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # var.remoteip
  security_group_id = aws_security_group.sg_for_nat_instance.id
}

resource "aws_security_group_rule" "remote_admin_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_nat_instance.id
}

resource "aws_security_group_rule" "remote_admin_http_more" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_nat_instance.id
}

# NAT Instance security group rule to allow all traffic from within the VPC
resource "aws_security_group_rule" "vpc_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"] #
  security_group_id = aws_security_group.sg_for_nat_instance.id
}

# NAT Instance security group rule to allow outbound traffic
resource "aws_security_group_rule" "outbound_nat_instance" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_nat_instance.id
}

resource "aws_security_group" "sg_for_private_instance" {
  name        = "sg_for_private_instance"
  vpc_id      = aws_vpc.main.id
  description = "sg for private instance"

  tags = {
    Name = "private_ec2_sg"
  }
}

# private instance security group rule to allow all traffic from public subnet 1
resource "aws_security_group_rule" "private_subnet_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"] #aws_subnet.public.cidr_block, aws_vpc.main.cidr_block, var.remoteip
  security_group_id = aws_security_group.sg_for_private_instance.id
}

# private instance security group rule to allow all traffic from public subnet 1
resource "aws_security_group_rule" "private_ssh_subnet_inbound" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #
  security_group_id = aws_security_group.sg_for_private_instance.id
}

resource "aws_security_group_rule" "private_http_subnet_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #var.cidr_blocks[1], var.cidr_blocks[0], var.remoteip
  security_group_id = aws_security_group.sg_for_private_instance.id
}

resource "aws_security_group_rule" "private_mor_http_subnet_inbound" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #var.cidr_blocks[1], var.cidr_blocks[0], var.remoteip
  security_group_id = aws_security_group.sg_for_private_instance.id
}

# private instance security group rule to allow outbound access
resource "aws_security_group_rule" "outbound_private_instance" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_private_instance.id
}

# Get the community AMI Image Id
data "aws_ami" "fck_nat" {
  filter {
    name   = "name"
    values = ["fck-nat-amzn2-*"]
  }

  owners      = ["568608671756"]
  most_recent = true
}
# data "aws_ami" "hi" {
#   executable_users = ["self"]
#   most_recent      = true
#   name_regex       = "^myami-[0-9]{3}"
#   owners           = ["self"]
#
#   filter {
#     name   = "name"
#     values = ["myami-*"]
#   }
#
#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }
#
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Build the NAT Instance
resource "aws_instance" "nat_instance" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.sg_for_nat_instance.id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = "nat_instance.pem"
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.id
  # Root disk for NAT instance
  root_block_device {
    volume_size = "8"
    volume_type = "gp2"
    encrypted   = true
  }

  user_data = <<-EOF
# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf

# Set up NAT rules
PRIVATE_IP="10.0.2.239"
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $PRIVATE_IP:80
sudo iptables -A FORWARD -p tcp -d $PRIVATE_IP --dport 80 -j ACCEPT
sudo yum install iptables-services -y
sudo service iptables save

EOF
  tags = {
    Name = "Nat-instance"
  }
}

# Get private instance Image Id for Amazon Linux 2023


# Build the private instance
resource "aws_instance" "private_instance" {
  ami                    = data.aws_ami.amzn-linux-2023-ami.id # Free-tier
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.sg_for_private_instance.id]
  key_name               = "private_instance.pem"
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.id

  private_ip = "10.0.2.239"
  # Root disk for private instance
  root_block_device {
    volume_size = "8"
    volume_type = "gp2"
    encrypted   = true
  }

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum -y install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chmod 666 /var/run/docker.sock
docker pull nginx
echo "yo this is nginx" > /usr/share/nginx/html/index.html
mkdir site-content
# cat <<EOF_HTML > site-content/index.html
# <html>
# <head>
#     <meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
#     <title>Document</title>
# </head>
# <body>
# <h1>yo this is nginx</h1>
# </body>
# </html>
# EOF_HTML
# sudo chmod -R 755 /home/ec2-user/site-content
# sudo chown -R ec2-user:ec2-user /home/ec2-user/site-content
# sudo chown -R nginx:nginx /home/ec2-user/site-content
# --name web -v ~/site-content:/usr/share/nginx/html
  docker run -it --rm -d -p 80:80 nginx
              EOF
  tags = {
    Name = "private_ec2_instance"
  }
}

# Route table entry to forward traffic to NAT instance
resource "aws_route" "outbound_nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat_instance.primary_network_interface_id

  depends_on = [aws_instance.nat_instance]
}


