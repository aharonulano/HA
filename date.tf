# Get availability zones (no local zones)
data "aws_availability_zones" "nolocal" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}