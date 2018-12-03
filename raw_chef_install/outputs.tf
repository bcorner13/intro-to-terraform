output "private_ip" {
  value = "${aws_instance.classroom.private_ip}"
}
output "name" {
  value = "${aws_instance.classroom.key_name}"
}
