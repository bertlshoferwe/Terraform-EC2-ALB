# Terraform ALB with EC2 Instances Setup

This repository contains Terraform code to create an Application Load Balancer (ALB) on AWS in front of two EC2 Ubuntu instances.

## Overview

This Terraform configuration automates the setup of infrastructure on AWS to deploy a scalable web application. It provisions an Application Load Balancer (ALB)
to distribute incoming traffic across multiple EC2 instances. The EC2 instances are configured with Ubuntu and are designed to host a simple web application.

## Prerequisites

Before getting started, ensure you have the following prerequisites:

- Terraform installed on your local machine.
- AWS account with appropriate permissions.
- AWS CLI configured with access credentials.

## Deployment Steps

1. **Clone the Repository:**

    git clone <repository-url>
    cd terraform-alb-ec2
  

2. **Initialize Terraform:**

    terraform init

3. **Set AWS Credentials:**

    aws configure

4. **Review and Customize Configuration:**

    Review the `variables.tf` file and customize the variables according to your requirements.

5. **Deploy the Infrastructure:**

    terraform apply

    Terraform will prompt for confirmation before making any changes. Review the plan carefully before proceeding.

6. **Accessing the ALB:**

    After the deployment is complete, Terraform will output the DNS name of the ALB. You can access your application using this DNS name.

8. **Cleaning Up:**

    When you're done testing, you can destroy the infrastructure to avoid incurring charges:

    terraform destroy

