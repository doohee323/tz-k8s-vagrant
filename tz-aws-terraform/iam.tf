resource "aws_iam_role" "master-role" {
  name               = "master-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_instance_profile" "master-role" {
  name = "master-role"
  role = aws_iam_role.master-role.name
}

resource "aws_iam_role_policy" "admin-policy" {
  name = "master-admin-role-policy"
  role = aws_iam_role.master-role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}
