output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the created VPC."
}

output "main-public-1_subnet_id" {
  value       = aws_subnet.main-public-1.id
  description = "ID of the created subnet."
}

output "main-public-3_subnet_id" {
  value       = aws_subnet.main-public-3.id
  description = "ID of the created subnet."
}
