variable "profile_name" {
  description = "(Required) profile login configured by sso or aws configured"
  type        = string
  sensitive   = true
  # default     =
}

variable "account" {
  description = "(Required) account id for tf code to run on"
  type        = string
  # default     =
  sensitive   = true
}

variable "aws_region" {
  description = "(Required) in which region to run"
  type        = string
  default     = "eu-west-1"
}

# List of cidr blocks
variable "cidr_blocks" {
  type        = list(string)
  description = "cidr blocks definition"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "local_ip" {
  description = "Local machine IP address"
  type        = string
  default     = "$(curl -s https://ipinfo.io/ip)"
}

variable "private_instance_key" {
  type    = string
  default = "~/.ssh/private_instance.pem"
}

variable "nat_instance_key" {
  type    = string
  default = "~/.ssh/nat_instance.pem"
}

# variable "ssh_nat_key" {
#   description = "Path to an SSH public key"
#   type        = string
#   default     = "~/.ssh/aws/a_nothe_key.pub"
# }
#
# variable "ssh_private_key" {
#   description = "Path to an SSH public key"
#   type        = string
#   default     = "~/.ssh/aws/a_nothe_key.pub"
# }


variable "docker_image" {
  description = "Docker image to run"
  type        = string
  default     = "aharn/ngnix-edited:latest"
}

variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "nginx-ec2"
}
# Remote IP address for SSH access
# variable "remoteip" {
#   type        = string
#   description = "Remote admin IP address"
#   default     = ""
# }