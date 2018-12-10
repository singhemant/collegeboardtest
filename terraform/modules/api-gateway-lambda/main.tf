provider "aws" {
  region = "${var.region}"
}

resource "aws_lambda_function" "lambda" {
  function_name = "getFruitDetailsfromDynamoDB"

  # The bucket name as created earlier with "aws s3api create-bucket"
  #s3_bucket = "clouddrivers"
  #s3_key    = "getFruitDetails/getFruitDetailsAPI-1.0.0.jar"
  filename = "${var.filename}"

  handler          = "com.amazonaws.lambda.api.FruitController::handleRequest"
  runtime          = "java8"
  source_code_hash = "${base64sha256(file("${var.filename}"))}"
  role             = "${aws_iam_role.lambda_exec.arn}"
  timeout          = 60
  memory_size      = 512
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_dynamoDB_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "createExectionRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "dynamodbCRUDOperationsPolicy"
  path        = "/"
  description = "DynamoDB policy to read from and write to it"

  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "ReadWriteAccess",
              "Effect": "Allow",
              "Action": [
                  "logs:CreateLogStream",
                  "dynamodb:PutItem",
                  "dynamodb:DescribeTable",
                  "dynamodb:GetItem",
                  "dynamodb:Scan",
                  "dynamodb:Query",
                  "dynamodb:UpdateItem",
                  "logs:PutLogEvents",
                  "dynamodb:GetRecords"
              ],
              "Resource": [
                  "arn:aws:dynamodb:us-east-1:609080526910:table/fruits",
                  "arn:aws:logs:*:*:*"
              ]
          },
          {
              "Sid": "CloudWatchAccess",
              "Effect": "Allow",
              "Action": "logs:CreateLogGroup",
              "Resource": "arn:aws:logs:*:*:*"
          }
      ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

resource "aws_api_gateway_rest_api" "api" {
  name = "getFruitDetailsAPI"
}

resource "aws_api_gateway_resource" "resourcePost" {
  path_part   = "fruit"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_method" "methodPost" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resourcePost.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "{fruitName}"
  parent_id   = "${aws_api_gateway_resource.resourcePost.id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integrationGET" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda.invoke_arn}"

  request_templates {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
    "httpMethod" : "$context.httpMethod",
    "fruitName" : "$input.params('fruitName')"
}
EOF
  }
}

resource "aws_api_gateway_integration" "integrationPOST" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.resourcePost.id}"
  http_method             = "${aws_api_gateway_method.methodPost.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda.invoke_arn}"

  request_templates {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
    "httpMethod" : "$context.httpMethod",
    "fruit" : $input.json('$')
}
EOF
  }
}

# Lambda permission for GET API
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "getFruitDetailsAPI" {
  depends_on = [
    "aws_api_gateway_integration.integrationGET",
    "aws_api_gateway_integration.integrationPOST",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "dev"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.getFruitDetailsAPI.execution_arn}/*/*/*"
}

output "api_invoke_url" {
  value = "${aws_api_gateway_deployment.getFruitDetailsAPI.invoke_url}"
}
