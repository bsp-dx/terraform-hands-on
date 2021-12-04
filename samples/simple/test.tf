data "aws_partition" "current" {}

resource "aws_iam_role" "this" {
  name               = "myTestInstanceProfileRole"
  path               = "/ecs/"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

output "test_value" {
  value = aws_iam_role.this.arn
}