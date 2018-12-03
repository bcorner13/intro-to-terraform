# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A SINGLE EC2 INSTANCE
# This template uses runs a simple "Hello, World" web server on a single EC2 Instance
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ------------------------------------------------------------------------------

provider "aws" {
  region = "us-east-2"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A SINGLE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "classroom" {
  ami = "ami-77724e12"
  key_name = "classroom"
  iam_instance_profile = "${var.host.["iam_instance_profile"]}"
  availability_zone = "${var.host.["availability_zone"]}"
  subnet_id = "${var.host.["subnet_id"]}"
  instance_type = "${var.host.["instance_type"]}"
  vpc_security_group_ids = ["${aws_security_group.classroom.id}"]
  user_data = <<-EOF
              #!/bin/bash
              echo "10.191.248.220 gsaohldrchef01.gsaws.local gsaohldrchef01" > /etc/hosts 
              EOF
  provisioner "chef" {
    connection {
      type     = "ssh"
      user     = "centos"
      private_key = "${file("~/.ssh/classroom")}"
    }
    attributes_json = <<-EOF
    {
      "tag": "chef-test",
      "chef_client_updater": {
          "version": "13.6.4",
          "prevent_downgrade": false,
          "download_url_override": "https://artifactory.svce1.greensky.net/Chef_Installation/rhel/chef-13.6.4-1.el6.x86_64.rpm"
      },
      "chef-client": {
          "interval": "1800",
          "splay": "300",
          "log_dir": "/var/log/chef-client"
      }
    }
    EOF
    environment     		= "_default"
    run_list        		= ["chef-client::service","chef_client_updater::default"]
    node_name       		= "${var.host.["name"]}"
    server_url      		= "${var.chef_provision.["server_url"]}"
    recreate_client 		= "${var.chef_provision.["recreate_client"]}"
    user_name       		= "${var.chef_provision.["user_name"]}"
    user_key    		= "${file("${var.chef_provision.["user_key_path"]}")}"
    version			= "13.6.4"
    fetch_chef_certificates	= true
    ssl_verify_mode 		= ":verify_none"
    client_options  		= ["enable_reporting", "enable_selinux_file_permission_fixup"]
  }
#  provisioner "remote-exec" {
#    connection {
#      host     = "${aws_instance.classroom.private_ip}"
#      type     = "ssh"
#      user     = "centos"
#      private_key = "${file("~/.ssh/classroom")}"
#    }
#    inline = [
#      "knife node delete ${var.host.["name"]}",
#      "knife client delete ${var.host.["name"]}",
#      ]
#    when = "destroy"
#  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "centos"
      private_key = "${file("~/.ssh/classroom")}"
    }
    inline = [
      "sudo yum update -y"
    ]
  }
  tags {
    Name = "${var.host.["name"]}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO THE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "classroom" {
  name = "chef-classroom"
  vpc_id = "vpc-1384447a"
  # Inbound HTTP from anywhere
  ingress {
    description = "Web Traffic"
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8", "10.191.200.0/21"]
  }
  ingress {
    description = "SSH"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8", "10.191.200.0/21"]
  }
  egress {
    description = "outbount TCP"
    protocol = "tcp"
    from_port = "0"
    to_port = "65535"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "outbount ICMP"
    protocol = "icmp"
    from_port = "0"
    to_port = "3"
    cidr_blocks = ["0.0.0.0/0"]
  }
 }
