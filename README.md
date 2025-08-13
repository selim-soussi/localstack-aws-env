#  Localstack AWS Environment - Terraform Project

This project provides a ready-to-run Localstack environment to simulate AWS services locally. It allows you to practice Terraform deployments, AWS CLI commands, and serverless workflows without using a real AWS account, making it ideal for testing and learning.

🏗️ Project Overview

Services Included:

S3 (Object Storage)

DynamoDB (NoSQL Database)

SQS (Queue Service)

EC2 (Compute Instances)

Lambda (Serverless Functions)

Purpose of This TP:

Learn to simulate AWS services locally using Localstack.

Understand how to deploy resources with Terraform.

Practice interacting with AWS APIs via CLI.

Provide a safe, local environment for experimentation.

Serve as a foundation for more advanced cloud automation projects.

⚡ Prerequisites
Docker installed

Terraform installed

AWS CLI installed

Localstack Docker image

# 🐳 Setup Localstack
Start Localstack with the required services:

docker run -itd --name localstack \
  -p 4566:4566 -p 4571:4571 \
  -e SERVICES=s3,ec2,lambda,dynamodb,sqs \
  -e DEBUG=1 \
  localstack/localstack
Verify Localstack is running:

docker ps

# 📝 Terraform Setup
Provider Configuration (main.tf):

provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    sqs      = "http://localhost:4566"
    ec2      = "http://localhost:4566"
    lambda   = "http://localhost:4566"
  }
}
Resources:

# S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-localstack-bucket"
}

# DynamoDB Table
resource "aws_dynamodb_table" "my_table" {
  name         = "my-local-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# SQS Queue
resource "aws_sqs_queue" "my_queue" {
  name = "my-local-queue"
}

# EC2 Instance (simulated)
resource "aws_instance" "my_ec2" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  tags = {
    Name = "localstack-ec2"
  }
}

# Lambda Function
resource "aws_lambda_function" "my_lambda" {
  function_name = "my-local-lambda"
  role          = "arn:aws:iam::000000000000:role/lambda-role"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  filename      = "lambda.zip"
}

# S3 Lifecycle Rule
resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id     = "delete-old-files"
    status = "Enabled"

    filter { prefix = "" }

    expiration {
      days = 30
    }
  }
}
🚀 Initialize and Apply Terraform

terraform init
terraform apply -auto-approve
📦 Localstack Resource Commands Cheat Sheet 

**S3**

aws --endpoint-url=http://localhost:4566 s3 ls
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-localstack-bucket
aws --endpoint-url=http://localhost:4566 s3 cp file.txt s3://my-localstack-bucket/
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-localstack-bucket/file.txt ./file.txt
aws --endpoint-url=http://localhost:4566 s3 rm s3://my-localstack-bucket/file.txt
aws --endpoint-url=http://localhost:4566 s3 rb s3://my-localstack-bucket --force

**DynamoDB**

aws --endpoint-url=http://localhost:4566 dynamodb list-tables
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name my-local-table \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name my-local-table \
    --item '{"id": {"S": "123"}, "name": {"S": "Selim"}}'
aws --endpoint-url=http://localhost:4566 dynamodb get-item \
    --table-name my-local-table \
    --key '{"id": {"S": "123"}}'
aws --endpoint-url=http://localhost:4566 dynamodb delete-table --table-name my-local-table

**SQS**

aws --endpoint-url=http://localhost:4566 sqs list-queues
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name my-local-queue
aws --endpoint-url=http://localhost:4566 sqs send-message \
    --queue-url http://localhost:4566/000000000000/my-local-queue \
    --message-body "Hello Localstack!"
aws --endpoint-url=http://localhost:4566 sqs receive-message \
    --queue-url http://localhost:4566/000000000000/my-local-queue
aws --endpoint-url=http://localhost:4566 sqs delete-message \
    --queue-url http://localhost:4566/000000000000/my-local-queue \
    --receipt-handle <ReceiptHandle>

**EC2**

aws --endpoint-url=http://localhost:4566 ec2 describe-instances
aws --endpoint-url=http://localhost:4566 ec2 run-instances \
    --image-id ami-12345678 --count 1 --instance-type t2.micro
aws --endpoint-url=http://localhost:4566 ec2 stop-instances --instance-ids i-INSTANCEID
aws --endpoint-url=http://localhost:4566 ec2 start-instances --instance-ids i-INSTANCEID
aws --endpoint-url=http://localhost:4566 ec2 terminate-instances --instance-ids i-INSTANCEID

**Lambda**

aws --endpoint-url=http://localhost:4566 lambda list-functions
aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name my-local-lambda \
    --runtime nodejs14.x \
    --role arn:aws:iam::000000000000:role/lambda-role \
    --handler index.handler \
    --zip-file fileb://lambda.zip
aws --endpoint-url=http://localhost:4566 lambda invoke \
    --function-name my-local-lambda output.json
    
# 🗺️ Architecture Overview
<img width="675" height="602" alt="image" src="https://github.com/user-attachments/assets/9f2aac03-5b8f-4f75-9acd-e15678fe63bd" />


                          
Resource Relationships & Data Flow:

Upload a file → S3 Bucket

S3 event triggers → Lambda Function

Lambda writes metadata → DynamoDB Table

Lambda sends message → SQS Queue

EC2 Instance reads from SQS → processes tasks

All resources are fully local, require no AWS billing, and let you practice real AWS workflows safely.

