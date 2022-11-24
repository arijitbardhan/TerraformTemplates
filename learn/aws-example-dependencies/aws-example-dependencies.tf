#credentials
provider "aws" {
 
}

# New resource for the S3 bucket our application will use.

resource "aws_s3_bucket" "arijitexample123" {

  # NOTE: S3 bucket names must be unique across _all_ AWS accounts, so
  # this name must be changed before applying this example to avoid naming
  # conflicts.

  bucket = "bucket-by-terraform"
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.arijitexample123.id
  acl    = "private"
}

# Change the aws_instance we declared earlier to now include "depends_on"

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "sample-ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  # Tells Terraform that this EC2 instance must be created only after the
  # S3 bucket has been created.
  
  provisioner "local-exec" {
    command = "echo ${aws_instance.sample-ec2.public_ip} > ip_address.txt"
  }
  depends_on = [aws_s3_bucket.arijitexample123]
}

resource "aws_eip" "ip" {
  #this will fetch the id of aws_instance with name example
  instance      = "${aws_instance.sample-ec2.id}"
}

