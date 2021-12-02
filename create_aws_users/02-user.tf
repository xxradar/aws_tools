resource "aws_iam_user" "students" {
  count = length(var.students_user_names)
  name  = element(var.students_user_names, count.index)

  # force_destroy - (Optional, default false) When destroying this user,
  # destroy even if it has non-Terraform-managed IAM access keys,
  # login profile or MFA devices. Without force_destroy a user with
  # non-Terraform-managed access keys and login profile will fail to be destroyed.
  force_destroy = true
}

resource "aws_iam_user_login_profile" "students" {
  count                   = length(aws_iam_user.students.*.name)
  user                    = element(aws_iam_user.students.*.name, count.index)
  pgp_key                 = filebase64("./labuserkey.pub")
  password_reset_required = true
}

resource "aws_iam_group" "students" {
  name = "students"
}

resource "aws_iam_group_policy" "students" {
  name   = "iam_access_policy_for_students"
  group  = aws_iam_group.students.id
  policy = data.aws_iam_policy_document.students.json
}

data "aws_iam_policy_document" "students" {
    # EC2/VPC Full Access
	statement {
		actions = ["ec2:*"]
		effect    = "Allow"
		resources = ["*"]
	}

    # S3 Full Access
	statement {
		actions = ["s3:*"]
		effect    = "Allow"
		resources = ["*"]
	}

    # Cloudformation Full Access
	statement {
		actions = ["cloudformation:*"]
		effect    = "Allow"
		resources = ["*"]
	}

    # APIgateway Full Access
	statement {
		actions = ["apigateway:*"]
		effect    = "Allow"
		resources = ["*"]
	}

    # IAM Full Access
	statement {
		actions = ["iam:*"]
		effect    = "Allow"
		resources = ["*"]
	}

    # Lambda Full Access
	statement {
		actions = ["lambda:*"]
		effect    = "Allow"
		resources = ["*"]
	}

	# CloudWatch Full Access
	statement {
		actions = [
			"autoscaling:Describe*",
			"cloudwatch:*",
			"logs:*",
			"sns:*"
		]
		effect    = "Allow"
		resources = ["*"]
	}

	# Marketplace
	statement {
		actions = ["aws-marketplace:*"]
		effect	= "Allow"
		resources = ["*"]
	}

	# ChangePassword
	statement {
        actions = ["iam:ChangePassword"]
		effect = "Allow"
    	resources = ["arn:aws:iam::*:user/*"]
    }
    statement {
		actions = ["iam:GetAccountPasswordPolicy"]
		effect = "Allow"
        resources = ["*"]
	}
}

#resource "aws_iam_group_membership" "students" {
#  count = length(aws_iam_user.students.*.name)
#  name  = "students_group_membership"
#  users = [aws_iam_user.students[count.index].name]
#  group = aws_iam_group.students.name
#}

resource "aws_iam_group_membership" "students" {
    count = length(aws_iam_user.students.*.name)
    name  = "students_group_membership"
    users = ["${aws_iam_user.students[count.index].name}"]
    group = aws_iam_group.students.name
}

#variable "students_user_names" {
#    type="list"
#    description="a list which contains the names of the users"
#    default=["user1@gmail.com","user2@gmail.com"]
#}

output "new_iam_user_password" {
  value = ["${aws_iam_user_login_profile.students.*.encrypted_password}"]
}
