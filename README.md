

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

---

For more details, visit the [Strapi documentation](https://docs.strapi.io/).
