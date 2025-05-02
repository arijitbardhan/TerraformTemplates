Create terraform configuration and have empty backend block and run the "init" command

backend {
}

**ANSWER: This will throw error of missing kind for backend** 

 

3 As mentioned have the backend block without argument values and pass the values from config file while running the terraform init command

terraform {

  backend "s3" {

    bucket = ""

    region = ""

  }

}
terraform init <options>

**ANSWER: terraform init -backend-config=state.config**