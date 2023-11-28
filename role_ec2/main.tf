resource "aws_iam_role" "ec2_codedeploy" {
  name = "EC2-CodeDeploy"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            },
            "Action": [
                "sts:AssumeRole"
            ]
        }
    ]
})
}

resource "aws_iam_policy_attachment" "ec2_policy_attachment_1" {
  name       = "ec2-policy-attachment-1"
  roles      = [aws_iam_role.ec2_codedeploy.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy" 
}

resource "aws_iam_policy_attachment" "ec2_policy_attachment_2" {
  name       = "ec2-policy-attachment-2"
  roles      = [aws_iam_role.ec2_codedeploy.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" 
}

resource "aws_iam_instance_profile" "ec2_iam_profile" {
  name = "EC2-CodeDeploy"
  role = aws_iam_role.ec2_codedeploy.name
}