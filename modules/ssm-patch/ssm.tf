resource "aws_ssm_patch_baseline" "linux_baseline" {
  name             = "linux-patch-baseline"
  operating_system = "AMAZON_LINUX_2"

  approval_rule {
    approve_after_days = 7

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security"]
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important"]
    }
  }
}

resource "aws_ssm_maintenance_window" "monthly_window" {
  name     = "monthly-patching-window"
  schedule = "cron(0 2 ? * SUN#1 *)"
  duration = 3
  cutoff   = 1
}

resource "aws_ssm_maintenance_window_target" "patch_target" {
  window_id     = aws_ssm_maintenance_window.monthly_window.id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:PatchGroup"
    values = ["production"]
  }
}

resource "aws_ssm_maintenance_window_task" "patch_task" {
  window_id        = aws_ssm_maintenance_window.monthly_window.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  max_concurrency  = "1"
  max_errors       = "1"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch_target.id]
  }

  service_role_arn = aws_iam_role.ssm_role.arn
}
