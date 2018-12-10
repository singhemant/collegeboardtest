module "dynamodb" {
  source = "../modules/dynamoDB"
}

module "api-gateway-lambda-integration" {
  source    = "../modules/api-gateway-lambda"
  accountId = "${var.accountId}"
  filename  = "../getFruitDetailsAPI-1.0.0.jar"
}

output "api_invoke_url" {
  value = "${module.api-gateway-lambda-integration.api_invoke_url}"
}
