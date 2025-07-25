## ✨ Features
- Strapi headless CMS with TypeScript support
- Docker Compose for local development and production
- Infrastructure as Code with Terragrunt and Terraform (modular AWS setup)
- Automated CI/CD with GitHub Actions (ci.yml for build/test, terraform.yml for infrastructure)
- Secure secrets management via GitHub Actions secrets
- Modular AWS resources: EC2, ECR, RDS, ALB, ECS, Security Groups, Key Pairs
- One-click deployment and update via GitHub Actions
- Example workflows for both application and infrastructure deployment

## 🚀 Infrastructure Provisioning & Deployment Sequence (with GitHub Actions)

To provision AWS resources and deploy Strapi using GitHub Actions, follow this recommended sequence:

### 1. Create RDS (Database)
**Workflow:** `.github/workflows/terraform.yml` (or your RDS provisioning workflow)
**Inputs to provide:**
  - `db_name`, `username`, `password`, `subnet_ids`, `vpc_id`, `security_group` (SG for DB access)
  - Any other required database parameters
**Result:**
  - Outputs: RDS endpoint, DB SG ID (save these for later)

### 2. Create ALB (Application Load Balancer)
**Workflow:** `.github/workflows/terraform.yml` (or your ALB provisioning workflow)
**Inputs to provide:**
  - `alb_sg` (security group for ALB, can reference DB SG if needed)
  - `subnets` (public subnets for ALB)
**Result:**
  - Outputs: ALB ARN, Listener ARN, ALB SG ID (save these for ECS)

### 3. Create ECS (Strapi Service)
**Workflow:** `.github/workflows/terraform.yml` (or your ECS provisioning workflow)
**Inputs to provide:**
  - `cluster_id` (ECS cluster ARN)
  - `container_image_uri` (ECR image URI from build/push workflow)
  - `security_group` (SG for ECS tasks, can reference ALB SG)
  - `existing_load_balancer_arn` (ALB ARN from previous step)
  - `existing_listener_arn` (Listener ARN from previous step)
  - `private_subnets` (private subnets for ECS tasks)
  - `environment_variables` (DB host, DB password, etc. from RDS)
**Result:**
  - ECS service running and accessible via ALB

### 4. Build and Push Docker Image to ECR
**Workflow:** `.github/workflows/ci.yml`
**Inputs to provide:**
  - `ecr-registry` (ECR registry URL)
  - `ecr-repository` (ECR repository name)
  - `dockerfile-path` (path to Dockerfile)
  - `aws-region` (AWS region)
  - Any build args/secrets (DB host, DB password, etc.)
**Result:**
  - Docker image is built and pushed to ECR
  - Image URI is used in ECS deployment

### 5. Update ECS Task Definition & Deploy (Optional)
**Workflow:** `.github/workflows/update-task.yml` (or similar)
**Inputs to provide:**
  - `ECR_REGISTRY`, `ECR_REPOSITORY`, `ECS_CLUSTER_NAME`, `ECS_TASK_DEFINITION`, `ECS_SERVICE_NAME`, `CONTAINER_NAME`, `aws_region`, `brand_name`
  - Environment variables and secrets as needed
**Result:**
  - ECS service is updated with the new image and environment variables

---

### Sequence Summary
1. **Provision RDS first** (get DB endpoint, SG ID)
2. **Provision ALB next** (get ALB ARN, Listener ARN, SG ID)
3. **Provision ECS last** (use outputs from RDS and ALB)
4. **Build and push Docker image to ECR** (use in ECS task definition)
5. **Update ECS task/service** (deploy new image and envs)

**Tip:** Always update the inputs in your Terragrunt/Terraform or workflow files with the outputs from the previous step (e.g., use the DB SG ID in ALB, ALB ARN in ECS, etc.).

For more details, see the comments and examples in each workflow file in `.github/workflows/`.

# 🚀 Strapi Setup Guide

Follow these steps to set up Strapi with Node.js v22 and start your project, or to deploy using this repository:

## 1. Clone Strapi GitHub Repository (Optional)

If you want to explore the Strapi source code:

```sh
git clone https://github.com/strapi/strapi.git
```

## 2. Install Node.js v22

Download and extract Node.js v22:

```sh
wget https://nodejs.org/dist/v22.0.0/node-v22.0.0-linux-x64.tar.xz
tar -xf node-v22.0.0-linux-x64.tar.xz
export PATH="$PWD/node-v22.0.0-linux-x64/bin:$PATH"
```

## 3. Create a New Strapi Project

Run the following command to create a new Strapi app quickly:

```sh
npx create-strapi-app@latest my-strapi-app --quickstart
```

When prompted, press `y` to proceed.

## 4. Sign Up / Login

After setup, you will be prompted to sign up or log in to the Strapi admin panel.

## 5. Access Strapi Admin Panel

Strapi will run on [http://localhost:1337](http://localhost:1337). Open this URL in your browser to access the admin panel.


## 6. Restart Strapi (if stopped)

Navigate to your project directory and run:

```sh
cd my-strapi-app
npm run develop
```

This will restart Strapi in development mode.

---

## 🚢 Deploying Strapi Using This Repository

To deploy Strapi using this repository, follow these steps:

1. **Clone this repository:**
   ```sh
   git clone https://github.com/PearlThoughts-DevOps-Internship/Strapi-Config-Crew.git  -b toufik-jamadar
   cd my-strapi-app
   ```

2. **Copy environment variables:**
   ```sh
   cp .env.example .env
   ```

3. **Install dependencies:**
   ```sh
   npm install
   ```

4. **Start Strapi in development mode:**
   ```sh
   npm run develop
   ```

## 🚢 Deploying Strapi Using This Repository (Docker Compose)

To deploy Strapi using Docker Compose, follow these steps:

1. **Clone the repository and switch to the correct branch:**
   ```sh
   git clone https://github.com/PearlThoughts-DevOps-Internship/Strapi-Config-Crew.git -b toufik-jamadar
   cd Strapi-Config-Crew/my-strapi-app/
   ```

2. **Install Docker and Docker Compose (if not already installed):**
   ```sh
   apt-get update
   apt-get install docker.io docker-compose -y
   ```

3. **Copy environment variables:**
   ```sh
   cp .env.example .env
   ```

4. **Start Strapi using Docker Compose:**
   ```sh
   docker-compose up -d --build
   ```

Strapi will be available at [http://localhost](http://localhost) on port 80.

## 🚢 Deploying Strapi Using This Repository (Docker Compose & GitHub Actions)

To deploy Strapi using Docker Compose and GitHub Actions, follow these steps:

1. **Set up GitHub Secrets:**
   - Go to your repository's `Settings > Secrets and variables > Actions`.
   - Add the following secrets:
     - `DOCKERHUB_USERNAME` (your Docker Hub username)
     - `DOCKERHUB_TOKEN` (your Docker Hub access token/password)
     - `AWS_ACCESS_KEY_ID` (if using AWS resources)
     - `AWS_SECRET_ACCESS_KEY` (if using AWS resources)
     - `TERRAGRUNT_GITHUB_TOKEN` (if using private repo access for Terragrunt)
     - Any other secrets referenced in your workflows or infrastructure.

2. **Run the desired GitHub Actions workflow:**
   - For CI (build, test, lint):
     - Use `.github/workflows/ci.yml`.
     - This runs automatically on push or pull request.
   - For CD (deploy):
     - Use `.github/workflows/terraform.yml`.
     - You can trigger this manually from the Actions tab.
     - Inputs (if any) can be set in the workflow dispatch or as environment variables in the workflow file.

3. **Inputs for CD workflow:**
   - Make sure your workflow file references the secrets above.
   - Common inputs:
     - `docker_image_name` (e.g., `my-strapi-app`)
     - `dockerhub_repo` (e.g., `yourusername/my-strapi-app`)
     - `aws_region` (e.g., `us-east-2`)

4. **What happens:**
   - The CD workflow will build the Docker image, log in to Docker Hub, and push the image.
   - If using AWS, it will use Terragrunt to provision infrastructure (EC2, security groups, etc.) using the secrets and inputs provided.
   - Strapi will be deployed and available at the configured endpoint (e.g., port 80).

---

For more details, visit the [Strapi documentation](https://docs.strapi.io/), [Terragrunt documentation](https://terragrunt.gruntwork.io/), and [GitHub Actions documentation](https://docs.github.com/en/actions).
