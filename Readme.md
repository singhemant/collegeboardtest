# aws-serverless-api
Simple HTTP Restful API to read/retrieve data from dynamoDB using AWS API-Gateway &amp; Lambda Function (java8)

Deployment Steps:

a. Install terraform from "https://www.terraform.io/downloads.html"
b. Unzip the project and Initialize terraform
        - cd \collegeboardtest\terraform\infrastructure
        - terraform init -backend-config=..\backend-config\backend.tf -var-file=..\vars.tfvars
        - terraform apply -var-file=..\vars.tfvars --auto-approve

This should create and deploy the getFruitDetails API on AWS, after successful
setup of terraform

Note:
- Please update "\collegeboardtest\terraform\vars.tfvars" file with your AWS
access_key, secret_key & accountId
- if you are using profile based AWS credentials, then you can get rid of
aws_access_key & aws_secret_key from the vars.tfvars file and terraform should find your ~/.aws/credentials

for more information: please refer to "https://learn.hashicorp.com/terraform/getting-started/build.html#configuration"        
