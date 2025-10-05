# Package the Lambda function code
data "archive_file" "example" {
  type = "zip"
  # source_file = "${path.module}/src/index.js"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src/function.zip"
}

# Lambda function
resource "aws_lambda_function" "anonymousLoginFunction" {
  filename         = data.archive_file.example.output_path
  function_name    = "anonymousLoginFunction"
  role             = aws_iam_role.example.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.example.output_base64sha256

  runtime = "nodejs20.x"

  environment {
    variables = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "info"
      # DB_HOST     = "my-postgres-db.cw1ogy28g1ak.us-east-1.rds.amazonaws.com"
      DB_HOST     = data.aws_db_instance.meu_rds.address
      DB_USER     = jsondecode(data.aws_secretsmanager_secret_version.credentials.secret_string)["username"]
      DB_PASS     = jsondecode(data.aws_secretsmanager_secret_version.credentials.secret_string)["password"]
      DB_NAME     = var.nome_banco
      JWT_SECRET  = var.JWT_SECRET
    }
  }

  tags = {
    Environment = "production"
    Application = "example"
  }

}

# URL pública da função
resource "aws_lambda_function_url" "anonymousLoginFunction" {
  function_name      = aws_lambda_function.anonymousLoginFunction.function_name
  authorization_type = "NONE"
}

# Output da URL
output "lambda_url" {
  value = aws_lambda_function_url.anonymousLoginFunction.function_url
}