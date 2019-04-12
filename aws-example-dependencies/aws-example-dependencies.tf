#credentials
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# New resource for the S3 bucket our application will use.

resource "aws_s3_bucket" "arijitexample123" {

  # NOTE: S3 bucket names must be unique across _all_ AWS accounts, so
  # this name must be changed before applying this example to avoid naming
  # conflicts.

  bucket = "bucket-by-terraform"
  acl    = "private"
}

# Change the aws_instance we declared earlier to now include "depends_on"

resource "aws_instance" "sample-ec2" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"

  # Tells Terraform that this EC2 instance must be created only after the
  # S3 bucket has been created.
 
  depends_on = ["aws_s3_bucket.arijitexample123"]
}
