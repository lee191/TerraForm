variable "instance_type" {
  default = "t2.micro"
}

variable "instance_tag" {
  default = {
    Name = "myinstance"
  }
}