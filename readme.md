# Foody Environments Terraform Configuration

This repository contains the Terraform configuration for managing the infrastructure of the Foody project. The configuration is organized to manage different environments, with the current setup focusing on the production environment.

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v1.9.6 or later
- Google Cloud SDK

### Setup

1. **Clone the repository:**

    ```sh
    git clone https://github.com/yourusername/foody-environments-tf.git
    cd foody-environments-tf/prod
    ```

2. **Initialize Terraform:**

    ```sh
    terraform init
    ```

3. **Review and apply the configuration:**

    ```sh
    terraform plan
    terraform apply
    ```

## Variables

The `variables.tf` file defines several variables used in the Terraform configuration. Below are some of the key variables:

- `redis_url`: Redis URL
- `grocery_be_datasource_url`: Grocery-be datasource URL
- `grocery_be_db_user`: Database user
- `food_details_base_url`: Food details base URL
- `project_id`: Project ID (default: `foody-me`)
- `grocery_base_url`: Grocery base URL
- `food_track_be_dsn`: Food track be DSN
- `food_details_integrator_version`: Food details integrator version
- `food_track_be_version`: Food track be version
- `grocery_be_version`: Grocery be version
- `billing_account`: Billing account

## State Management

The Terraform state is managed remotely using Terraform Cloud. The state configuration can be found in the `terraform.tfstate` file.

## License

This project is licensed under the terms of the Mozilla Public License, v. 2.0. See the [LICENSE.txt](prod/.terraform/providers/registry.terraform.io/hashicorp/google/6.7.0/darwin_amd64/LICENSE.txt) file for details.