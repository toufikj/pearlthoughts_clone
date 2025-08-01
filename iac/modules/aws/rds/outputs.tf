output "strapi-sg" {
  description = "Security group for Strapi RDS"
  value       = ["${aws_security_group.strapi-sg.id}"]
}