data "aws_iam_user" "principal_user" {
  user_name = "herlessi"
}

data "aws_eks_cluster" "cluster" {
  name = "eks-techchallenge-fiap-fase3-2153"
}

data "aws_eks_cluster_auth" "auth" {
  name = "eks-techchallenge-fiap-fase3-2153"
}

# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_secretsmanager_secret" "credentials" {
  name = var.nome_credencial_secrets
}

data "aws_secretsmanager_secret_version" "credentials" {
  secret_id = data.aws_secretsmanager_secret.credentials.id
}

data "aws_db_instance" "meu_rds" {
  db_instance_identifier = var.nome_instancia_rds
}