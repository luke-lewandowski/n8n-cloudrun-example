# n8n on CloudRun using Terraform

CloudRun is a Google Cloud Platform product that allows for a frictionless docker deployments.

## How to setup

1. We are to using [Terraform](https://www.terraform.io/) to deploy to Google Cloud Platform.
1. We have provided configs for `dev` and `prod` environments with following variables;
1. You can place all your custom nodes in the `./nodes` folder.
1. You need to provide all the variables below to Terraform; either through the specific environment [terraform file](infrastructure/dev.tfvars) or via command line while deploying.

| Variable                | Description                                                                                                         | Example           |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------- | ----------------- |
| project_id              | Google's Project ID                                                                                                 |                   |
| region                  | Region to where the resources should be deployed to.                                                                | eg. us-central1   |
| build_number            | Build number for the purpose of changing the docker image for deployment purposes                                   | eg. 20210801.01   |
| database_instance       | PostgreSQL database instance (server name on GCP)                                                                   | eg. postgres      |
| database_name           | Database name on the PostgreSQL server                                                                              | eg. n8n           |
| database_user           | Database user.                                                                                                      |                   |
| database_password       | Database user's password.                                                                                           |                   |
| domain_name             | Domain hosted on GCP that we will create subdomain for to host n8n on.                                              | eg. example.com   |
| subdomain               | Subdomain that will be used to host n8n.                                                                            | eg. n8n           |
| zone_name               | Zone name on GCP when hosting your domain on GCP.                                                                   | eg. example-com   |
| n8n_encryption_key      | Encription key used to encrypt credentials inside n8n.                                                              |                   |
| n8n_basic_auth          | Username to be used for basic authentication to log in to n8n.                                                      |                   |
| n8n_basic_auth_password | Password for authenticating to n8n.                                                                                 |                   |
| n8n_execution_process   | Execution process (See [documentation](https://docs.n8n.io/getting-started/installation/advanced/scaling-n8n.html)) | `main` or `queue` |

## What do we provision

1. CloudRun
2. Domain Mapping (associating your CloudRun)
3. DNS setup
4. Security (IAM) for the service - to allow requests without authentication to n8n endpoints.

## What we NOT provision

1. Your PostgreSQL instance and database.
2. [Cloud Scheduler](https://cloud.google.com/scheduler/) to setup HTTP request to your n8n instance to keep it alive. Otherwise your docker instance will be only created and running when you call it - which sometimes it too slow. **Note:** You are paying for how long your docker runs for - so when your n8n is not running you aren't paying.
3. Blob/File storage for `terraform` session.

## How to set it all up

1. [Read up some basics of Terraform](https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform) if you have not used it before. Please.
2. `terraform init`
3. `terraform plan`
4. `terraform validate and apply`

## How is this different from vanilla n8n

1. GCP doesn't allow us to connect directly to the database that's why we are bundling the [SQL Proxy](https://github.com/GoogleCloudPlatform/cloudsql-proxy) into the docker image. n8n is then able to log in to PostgreSQL as if the server is available locally.

A good thing about this approach is that you can actually securely connect to the GCP database from your local machine via script in the `scripts/` folder.

1. Update [`proxy-sql.zsh`](scripts/proxy-sql.zsh) with your `Connection name` from SQL settings in GCP.
2. Start the script.
3. You can now connect to your PostgreSQL as if it was hosted locally.
