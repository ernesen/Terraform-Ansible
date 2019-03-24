variable "profile" {
  default = "terraform_iam_user"
}

variable "region" {
  default = "ap-southeast-1"
}

variable "instance" {
  default = "t2.nano"
}

variable "instance_count" {
  default = "1"
}

variable "public_key" {
  default = "~/.ssh/MyKeyPair.pub"
}

variable "private_key" {
  default = "~/.ssh/MyKeyPair.pem"
}

variable "ansible_user" {
  default = "ubuntu"
}

variable "amis" {
  type = "map"

  default = {
    ap-northeast-1 = "ami-b25d44b3" # Asia Pacific (Tokyo)
    ap-southeast-1 = "ami-aeb49ffc" # Asia Pacific (Singapore)
    ap-southeast-2 = "ami-6b770351" # Asia Pacific (Sydney)
  }
}

variable "ami" {
  default = "ami-0c5199d385b432989"
}
