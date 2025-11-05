resource "aws_vpc" "main" {
	cidr_block = var.vpc_cidr
	tags = {
	    Name = "${var.env}-vpc"
	}
    lifecycle {
      prevent_destroy = false
    }
}

resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.main.id
	tags = {
	    Name = "${var.env}-igw"
	}
}

data "aws_availability_zones" "available" {
    state = "available"
}

resource "aws_subnet" "public" {
    count = length(var.public)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public[count.index]
    map_public_ip_on_launch = true
    availability_zone = element(data.aws_availability_zones.available.names, count.index)
    tags = {
        Name = "${var.env}-public-subnet-${count.index + 1}"
    }
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_subnet" "private" {
    count = length(var.private)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private[count.index]
    map_public_ip_on_launch = false
    availability_zone = element(data.aws_availability_zones.available.names, count.index)
    tags = {
        Name = "${var.env}-private-subnet-${count.index + 1}"
    }
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_security_group" "webserver_sg" {
    name = "${var.env}-webserver-sg"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.env}-webserver-sg"
    }
}

resource "aws_instance" "webserver" {
    count = var.instance_count
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = element(aws_subnet.public[*].id, count.index)
    vpc_security_group_ids = [aws_security_group.webserver_sg.id]
    tags = {
        Name = "${var.env}-webserver-${count.index + 1}"
    }

    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_s3_bucket" "logs" {
    bucket = "${var.env}-logs-${random_id.bucket_suffix.hex}"
    tags = {
        Name = "${var.env}-logs"
        Environment = var.env
    }
    lifecycle {
      prevent_destroy = false
    }
}

resource "random_id" "bucket_suffix" {
    byte_length = 4
}

resource "aws_s3_bucket_versioning" "logs_versioning" {
    bucket = aws_s3_bucket.logs.id
    versioning_configuration {
        status = "Enabled"
    }
}



