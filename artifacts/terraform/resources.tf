resource "aws_key_pair" "demo_key" {
  key_name   = "MyKeyPair"
  public_key = "${file(var.public_key)}"
}

/*
resource "aws_vpc" "my-vpc" {
  cidr_block           = "10.0.0.0/16" # Defines overall VPC address space
  enable_dns_hostnames = true          # Enable DNS hostnames for this VPC
  enable_dns_support   = true          # Enable DNS resolving support for this VPC
  instance_tenancy     = "default"
  enable_classiclink   = "false"

  tags {
    Name = "VPC-my-vpc" # Tag VPC with name
  }
}
*/

resource "aws_instance" "jenkins-ci" {
  count = "${var.instance_count}"

  #ami = "${lookup(var.amis,var.region)}"
  ami           = "${var.ami}"
  instance_type = "${var.instance}"
  key_name      = "${aws_key_pair.demo_key.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.web.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.egress-tls.id}",
    "${aws_security_group.ping-ICMP.id}",
	"${aws_security_group.web_server.id}"
  ]


  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 500
    volume_type           = "io1"
    iops                  = 2000
    encrypted             = true
    delete_on_termination = true
  }

  connection {
    private_key = "${file(var.private_key)}"
    user        = "${var.ansible_user}"
  }

  #user_data = "${file("../templates/install_jenkins.sh")}"

  # Ansible requires Python to be installed on the remote machine as well as the local machine.
  provisioner "remote-exec" {
    inline = ["sudo apt-get -qq install python -y"]
  }

  # This is where we configure the instance with ansible-playbook
  # Jenkins requires Java to be installed 
  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
	  >java.ini;
	  echo "[java]" | tee -a java.ini;
	  echo "${aws_instance.jenkins-ci.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}" | tee -a java.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	  ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i java.ini ../playbooks/install_java.yaml
    EOT
  }
  # This is where we configure the instance with ansible-playbook
  provisioner "local-exec" {
    command = <<EOT
      sleep 600;
	  >jenkins-ci.ini;
	  echo "[jenkins-ci]" | tee -a jenkins-ci.ini;
	  echo "${aws_instance.jenkins-ci.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}" | tee -a jenkins-ci.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	  ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i jenkins-ci.ini ../playbooks/install_jenkins.yaml
    EOT
  }

  tags {
    Name     = "jenkins-ci-${count.index +1 }"
    Batch    = "7AM"
    Location = "Singapore"
  }
}

resource "aws_instance" "gitLab" {
  count = "${var.instance_count}"

  #ami = "${lookup(var.amis,var.region)}"
  ami           = "${var.ami}"
  instance_type = "${var.instance}"
  key_name      = "${aws_key_pair.demo_key.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.web.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.egress-tls.id}",
    "${aws_security_group.ping-ICMP.id}",
	"${aws_security_group.web_server.id}"
  ]


  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 500
    volume_type           = "io1"
    iops                  = 2000
    encrypted             = true
    delete_on_termination = true
  }

  connection {
    private_key = "${file(var.private_key)}"
    user        = "${var.ansible_user}"
  }

  #user_data = "${file("../templates/install_gitLab.sh")}"

  # Ansible requires Python to be installed on the remote machine as well as the local machine.
  provisioner "remote-exec" {
    inline = ["sudo apt-get -qq install python -y"]
  }

  # This is where we configure the instance with ansible-playbook
  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
	  >gitLab.ini;
	  echo "[gitLab]" | tee -a gitLab.ini;
	  echo "${aws_instance.gitLab.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}" | tee -a gitLab.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	  ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i gitLab.ini ../playbooks/install_gitlab.yaml
    EOT
  }

  tags {
    Name     = "gitLab-${count.index +1 }"
    Batch    = "7AM"
    Location = "Singapore"
  }
}

resource "aws_security_group" "web" {
  name        = "default-web-example"
  description = "Security group for web that allows web traffic from internet"
  #vpc_id      = "${aws_vpc.my-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "web-example-default-vpc"
  }
}

resource "aws_security_group" "ssh" {
  name        = "default-ssh-example"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet"
  #vpc_id      = "${aws_vpc.my-vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ssh-example-default-vpc"
  }
}

resource "aws_security_group" "egress-tls" {
  name        = "default-egress-tls-example"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  #vpc_id      = "${aws_vpc.my-vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "egress-tls-example-default-vpc"
  }
}

resource "aws_security_group" "ping-ICMP" {
  name        = "default-ping-example"
  description = "Default security group that allows to ping the instance"
  #vpc_id      = "${aws_vpc.my-vpc.id}"

  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags {
    Name = "ping-ICMP-example-default-vpc"
  }
}

# Allow the web app to receive requests on port 8080
resource "aws_security_group" "web_server" {
  name        = "default-web_server-example"
  description = "Default security group that allows to use port 8080"
  #vpc_id      = "${aws_vpc.my-vpc.id}"
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "web_server-example-default-vpc"
  }
}
