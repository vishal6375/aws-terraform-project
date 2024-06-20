resource "aws_vpc" "my-vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub-1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub-2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id
}

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub-1.id
 route_table_id = aws_route_table.myrt.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub-2.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_security_group" "my-sg" {
  name        = "my-sg"
  description = "This security group is for the terraform project"
  vpc_id      = aws_vpc.my-vpc.id

  tags = {
    Name = "my-sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.my-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
 resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.my-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "vishalterraformproject1"

  tags = {
    Name        = "My_s3_bucket"
    Environment = "Test"
  }
}

resource "aws_instance" "web1" {
  ami                    = "ami-0aa8fc2422063977a"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key-tf.key_name
  subnet_id              = aws_subnet.sub-1.id
  availability_zone      = "us-east-2a"
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  user_data              = base64encode(file("${path.module}/userdata.sh"))
  tags = {
    Name = "webserver1"
  }
}

resource "aws_instance" "web2" {
  ami                    = "ami-0aa8fc2422063977a"
  instance_type          = "t2.micro"
 key_name               = aws_key_pair.key-tf.key_name
  subnet_id              = aws_subnet.sub-2.id
  availability_zone      = "us-east-2b"
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  user_data              = base64encode(file("${path.module}/userdata1.sh"))
  tags = {
    Name = "webserver2"
  }
}

resource "aws_lb" "my_alb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my-sg.id]
  subnets            = [aws_subnet.sub-1.id, aws_subnet.sub-2.id]
  tags = {
    Name = "web-lb"
  }

}

resource "aws_lb_target_group" "my-tg" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.my-tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.my-tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

resource "aws_lb_listener" "my-listner" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.my-tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.my_alb.dns_name
}


                    