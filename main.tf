module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = "xashy-university-portal"
  }
}

resource "aws_security_group" "web_app_sg" {
  name   = "${var.project}-web-app-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "${var.project}-artifact-${random_id.suffix.hex}"

}


resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.artifact_bucket.id

  versioning_configuration {

    status = "Enabled"
  }

}


# IAM assume role policy for EC2
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM role for EC2 instance
resource "aws_iam_role" "web_app_role" {
  name               = "${var.project}-web-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Attach Systems Manager policy
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.web_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# S3 permissions for artifact bucket
data "aws_iam_policy_document" "s3_artifact_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.artifact_bucket.arn,
      "${aws_s3_bucket.artifact_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "s3_artifact_policy" {
  name   = "${var.project}-s3-artifact-policy"
  role   = aws_iam_role.web_app_role.id
  policy = data.aws_iam_policy_document.s3_artifact_access.json
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "web_app_profile" {
  name = "${var.project}-web-app-profile"
  role = aws_iam_role.web_app_role.name
}

# Update the EC2 instance resource
resource "aws_instance" "web_app" {
  ami                    = "ami-0741dc526e1106ae5"
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.web_app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.web_app_profile.name

  tags = {
    Name = "web-app-${var.project}"
  }
}
