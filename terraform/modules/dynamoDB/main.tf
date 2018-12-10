provider "aws" {
  region = "${var.region}"
}

# Configure the AWS Provider
resource "aws_dynamodb_table" "dynamodb-table" {
  name           = "${var.name}"
  billing_mode   = "${var.billing_mode}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "${var.hash_key}"

  attribute {
    name = "${var.hash_key}"
    type = "S"
  }

  tags {
    OwnerContact = "${var.OwnerContact}"
    Environment  = "${var.Environment}"
  }
}
