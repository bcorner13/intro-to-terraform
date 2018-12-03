# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}
variable "host" {
  type = "map"
  description = "Configuration details for chef server"
  default = {
    name = "goldenimage-test"
    ami_id = "ami-fce2dd99"
    key_name = "chef"
#  aws_id = "ami-93417ef6"
    iam_instance_profile = "Classroom"
    availability_zone = "us-east-2a"
    subnet_id = "subnet-cde929a5"
    instance_type = "t2.micro"
  }
}
