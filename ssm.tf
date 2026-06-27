resource "aws_ssm_document" "install_tomcat" {
  name            = "${var.project}-install-tomcat"
  document_type   = "Command"
  document_format = "JSON"

  # Run Command document content is maintained separately for readability
  content = file("${path.module}/scripts/install-tomcat.json")

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}