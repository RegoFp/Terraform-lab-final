terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}



resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "db_credenciales"
  description = "Credenciales para jardinero"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "jardinero"
    password = "jardinero"
  })
}



# Import existing certificate into ACM
resource "aws_acm_certificate" "certs" {
  private_key       = file("Certs/clave.pem")
  certificate_body  = file("Certs/certificado.pem")

  tags = {
    Name  = "backend-cert"
    ENV   = var.env
    OWNER = "IT"
  }
}

