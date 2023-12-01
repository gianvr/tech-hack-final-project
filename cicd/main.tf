

resource "aws_codecommit_repository" "CodeCommit_Repository" {
  repository_name = "Repository"
}

resource "aws_codedeploy_app" "Application" {
  name             = var.application_name
}

resource "aws_codedeploy_deployment_group" "ApplicationGroup" {
  app_name               = aws_codedeploy_app.Application.name
  deployment_group_name  = "${aws_codedeploy_app.Application.name}Group"
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

// Testing Enviroment Deploy Application

resource "aws_codedeploy_app" "testing_Application" {
  name             = var.testing_application_name
}

resource "aws_codedeploy_deployment_group" "testing_ApplicationGroup" {
  app_name               = aws_codedeploy_app.testing_Application.name
  deployment_group_name  = "${aws_codedeploy_app.testing_Application.name}Group"
  service_role_arn       = var.codedeploy_arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key    = "Name"
      value  = aws_codedeploy_app.testing_Application.name
      type   = "KEY_AND_VALUE"
    }
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.application_name}-codedeploy-deployment"
  force_destroy = true
}

resource "aws_sns_topic" "approval_topic" {
  name = "approval_topic"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "pipeline"
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
    name = "Testing"

    action {
      name            = "Deploy"
      namespace        = "Testing_DeployVariables"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ApplicationName          = aws_codedeploy_app.testing_Application.name
        DeploymentGroupName      = aws_codedeploy_deployment_group.testing_ApplicationGroup.deployment_group_name  
      }
    }
  }

  stage {
    name = "Production"

    action {
      name            = "Approval"
      category        = "Approval"
      owner           = "AWS"
      provider        = "Manual"
      version         = 1

      configuration = {
        NotificationArn = aws_sns_topic.approval_topic.arn
        CustomData      = "Approve Deploy for Production"
      }
      run_order       = 1
    }

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

      run_order       = 2
    }
  }
}