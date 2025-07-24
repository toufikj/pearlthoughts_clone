# Use Node.js 22 base image
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Copy package files first and install dependencies
COPY package*.json ./
RUN npm install && npm install pg --save

# Copy all project files
COPY . .


# Accept build-time environment variables as ARGs and set as ENV
ARG HOST=0.0.0.0
ARG PORT=1337
ARG APP_KEYS="key1,key2"
ARG API_TOKEN_SALT=tobemodified
ARG ADMIN_JWT_SECRET=tobemodified
ARG TRANSFER_TOKEN_SALT=tobemodified
ARG JWT_SECRET=tobemodified
ARG ENCRYPTION_KEY=tobemodified

# Database args
ARG DATABASE_CLIENT=postgres
ARG DATABASE_HOST
ARG DATABASE_PORT=5432
ARG DATABASE_NAME=strapi_db
ARG DATABASE_USERNAME=strapi
ARG DATABASE_PASSWORD
ARG DATABASE_SSL="true"
ARG DATABASE_SSL_REJECT_UNAUTHORIZED="false"

# Set environment variables
ENV HOST=${HOST} \
    PORT=${PORT} \
    APP_KEYS=${APP_KEYS} \
    API_TOKEN_SALT=${API_TOKEN_SALT} \
    ADMIN_JWT_SECRET=${ADMIN_JWT_SECRET} \
    TRANSFER_TOKEN_SALT=${TRANSFER_TOKEN_SALT} \
    JWT_SECRET=${JWT_SECRET} \
    ENCRYPTION_KEY=${ENCRYPTION_KEY} \
    DATABASE_CLIENT=${DATABASE_CLIENT} \
    DATABASE_HOST=${DATABASE_HOST} \
    DATABASE_PORT=${DATABASE_PORT} \
    DATABASE_NAME=${DATABASE_NAME} \
    DATABASE_USERNAME=${DATABASE_USERNAME} \
    DATABASE_PASSWORD=${DATABASE_PASSWORD} \
    DATABASE_SSL=${DATABASE_SSL} \
    DATABASE_SSL_REJECT_UNAUTHORIZED=${DATABASE_SSL_REJECT_UNAUTHORIZED}

# Expose Strapi port
EXPOSE 1337

# Start Strapi app in development mode
CMD ["npm", "run", "develop"]
