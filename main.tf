resource "aws_key_pair" "deployment" {
  key_name   = "deployment-key"
  public_key = ""  # TO BE FILLED WITH PUBLIC SSH KEY 
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
} 

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "demo" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name   = "Public route table"
    source = "terraform"
  }
}

resource "aws_route" "allow_anywhere" {
  route_table_id         = "${aws_route_table.public_route.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = "${aws_subnet.demo.id}"
  route_table_id = "${aws_route_table.public_route.id}"
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "Allow  traffic for http and ssh"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

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
    cidr_blocks = [""] # REPLACE YOUR OWN IP, ex: 44.225.30.167/32
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_role_policy" "demo_policy" {
  name = "iam-demo-policy"
  role = "${aws_iam_role.demo_role.id}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "demo_role" {
  name = "iam-demo-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "demo_profile" {
  name = "demo_profile"
  role = "${aws_iam_role.demo_role.name}"
}

resource "aws_instance" "demo" {
  ami           = "ami-0ca285d4c2cda3300"          #Amazon Linux AMI in us-west-2
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.demo.id}"

  vpc_security_group_ids = ["${aws_security_group.demo-sg.id}"]

  associate_public_ip_address = true

  iam_instance_profile = "${aws_iam_instance_profile.demo_profile.name}"

  tags = {
    source = "terraform"
    Name   = "demo-aws"
  }

  key_name = "deployment-key"

  user_data = "${file("scripts/shell.sh")}"
}

resource "aws_eip" "demo" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.demo.id}"
  allocation_id = "${aws_eip.demo.id}"
}

resource "aws_ebs_volume" "demo" {
  availability_zone = "us-west-2a"
  size              = 1

  tags = {
    Name = "demo"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdg"
  volume_id   = "${aws_ebs_volume.demo.id}"
  instance_id = "${aws_instance.demo.id}"
}