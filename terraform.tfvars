region          = "ap-south-1"
vpc_cidr        = "10.200.0.0/16"

public  = ["10.200.1.0/24", "10.200.2.0/24"]
private  = ["10.200.4.0/24", "10.200.5.0/24"]

instance_count = 4


ami_id          = "ami-0e639fddd264584f2"
instance_type   = "t4g.micro"

# Control via tfvars
env             = "prod"