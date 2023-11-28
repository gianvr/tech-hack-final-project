resource "aws_iam_role" "codedeploy" {
  name = "CodeDeploy"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "codedeploy.amazonaws.com"
                ]
            },
            "Action": [
                "sts:AssumeRole"
            ]
        }
    ]
})
}

resource "aws_iam_policy_attachment" "codedeploy_policy_attachment" {
  name       = "codedeploy-policy-attachment"
  roles      = [aws_iam_role.codedeploy.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole" 
}

resource "aws_iam_instance_profile" "codedeploy_iam_profile" {
  name = "CodeDeploy"
  role = aws_iam_role.codedeploy.name
}


