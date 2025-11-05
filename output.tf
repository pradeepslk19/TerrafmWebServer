output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "web_instances" {
  value = aws_instance.webserver[*].public_ip
}

output "s3_bucket" {
  value = aws_s3_bucket.logs.bucket
}