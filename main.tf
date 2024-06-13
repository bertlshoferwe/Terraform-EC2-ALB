//Main VPC
resource "aws_vpc" "mainVPC" {
  cidr_block = var.cidr

}

//Subnets 
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.mainVPC.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.mainVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

//Internet gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.mainVPC.id
}

//Route Table
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.mainVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}

//Associate the subnets with the route table
resource "aws_route_table_association" "RTA1" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.RT.id
} 
resource "aws_route_table_association" "RTA2" {
  subnet_id = aws_subnet.subnet2.id
  route_table_id = aws_route_table.RT.id
} 

//Security group for EC2's
resource "aws_security_group" "SG1" {
  name        = "web"
  vpc_id      = aws_vpc.mainVPC.id

//What traffic is allowed in
  ingress  {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

//What traffic is allowed out
  egress  {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//EC2 Ubuntu Instances
resource "aws_instance" "EC21" {
    ami = "ami-04b70fa74e45c3917"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.SG1.id]
    subnet_id = aws_subnet.subnet1.id
    user_data = base64encode(file("userData1.sh"))
}

resource "aws_instance" "EC22" {
    ami = "ami-04b70fa74e45c3917"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.SG1.id]
    subnet_id = aws_subnet.subnet2.id
    user_data = base64encode(file("userData2.sh"))
}

//Create ALB
resource "aws_lb" "myalb" {
  name = "myalb"
  internal = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.SG1.id]
  subnets = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

//Set ALB target group
resource "aws_lb_target_group" "tg" {
  name     = "targetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mainVPC.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

//Attach instances to target group
resource "aws_lb_target_group_attachment" "tga1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.EC21.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tga2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.EC22.id
  port             = 80
}

//Setup ALB Listner to forward traffic to target group
resource "aws_lb_listener" "albListener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}