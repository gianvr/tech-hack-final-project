

resource "aws_codecommit_repository" "CodeCommit_Repository" {
  repository_name = "Repository"
}

resource "aws_codedeploy_app" "Application" {
  name             = var.application_name
  #name             = "Ubuntu"
}

resource "aws_codedeploy_deployment_group" "ApplicationGroup" {
  app_name               = aws_codedeploy_app.Application.name
  deployment_group_name  = "${aws_codedeploy_app.Application.name}Group"
  #service_role_arn       = aws_iam_role.codedeploy.arn
  service_role_arn       = var.codedeploy_arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key    = "Name"
      value  = aws_codedeploy_app.Application.name
      type   = "KEY_AND_VALUE"
    }
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.application_name}-codedeploy-deployment"
  force_destroy = true
}

resource "aws_codepipeline" "codepipeline" {
  name     = "tf-test-pipeline"
  #role_arn = "arn:aws:iam::570234089813:role/service-role/CICDRole"
  role_arn = var.cicd_arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      namespace        = "SourceVariables"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName = aws_codecommit_repository.CodeCommit_Repository.repository_name
        BranchName     = "master"
        PollForSourceChanges     = true
        OutputArtifactFormat     = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      namespace        = "DeployVariables"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ApplicationName          = aws_codedeploy_app.Application.name
        DeploymentGroupName      = aws_codedeploy_deployment_group.ApplicationGroup.deployment_group_name  
      }
    }
  }
}