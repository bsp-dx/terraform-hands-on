locals {
  ecs_task_role_name   = "${module.ctx.project}EcsTasksRole"
  ecs_task_policy_name = "${module.ctx.project}EcsTasksPolicy"
  tags                 = module.ctx.tags
}

resource "aws_iam_role" "main_ecs_tasks" {
  name               = local.ecs_task_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(local.tags, { Name = local.ecs_task_role_name })
}

resource "aws_iam_role_policy" "main_ecs_tasks" {
  name = local.ecs_task_policy_name
  role = aws_iam_role.main_ecs_tasks.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [

        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}