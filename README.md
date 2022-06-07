### Terraform project

### This project provides the AWS infra provisioning with Terraform

#### Provides a simple html application exposed as a docker container automatically

* Dependencies:
    Changes required in the main.tf
    1. Fill the public ssh key with ssh-keygen in your terminal or gitbash (Line 3)
    2. Replace your own public IP (Line 73)

* Build & Deploy
    ```
    terraform init
    terrform plan
    terraform apply
        
    ```


