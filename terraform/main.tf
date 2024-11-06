provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "image_bucket" {
  bucket = "new-image-bucket"
}

resource "aws_s3_bucket_notification" "image_resizer_notification" {
  bucket = aws_s3_bucket.image_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_resizer.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_function" "image_resizer" {
  filename         = "lambda.zip"
  function_name    = "image-resizer"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler" 
  source_code_hash = filebase64sha256("lambda.zip")
  runtime          = "nodejs18.x" 
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
