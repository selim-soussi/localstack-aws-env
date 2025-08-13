provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true
  endpoints {
    s3 = "http://localhost:4566"
    ec2 = "http://localhost:4566"
    lambda = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    sqs = "http://localhost:4566"
  }
}

# S3 Bucket (mirrors GCP storage bucket)
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name"
}

resource "aws_dynamodb_table" "my_table" {
  name           = "my-local-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_sqs_queue" "my_queue" {
  name = "my-local-queue"
}

# -----------------------
# EC2 Instance
# -----------------------
resource "aws_instance" "my_ec2" {
  ami           = "ami-12345678" # Localstack accepts fake AMI
  instance_type = "t2.micro"
}

# -----------------------
# Lambda Function
# -----------------------
resource "aws_lambda_function" "my_lambda" {
  function_name = "my-local-lambda"
  role          = "arn:aws:iam::000000000000:role/lambda-role"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  filename      = "lambda.zip" # Must exist locally
}


# Lifecycle rule: delete objects after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id     = "delete-old-files"
    status = "Enabled"

    filter {
      prefix = ""   # Apply to all objects
    }

    expiration {
      days = 30
    }
  }
}

