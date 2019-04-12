#section for provider definition

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

#defining an ec2-instance
resource "aws_instance" "example" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"
}

#defining elastic IP
resource "aws_eip" "ip" {
  #this will fetch the id of aws_instance with name example
  instance	= "${aws_instance.example.id}"
}
