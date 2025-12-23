#!/bin/bash

# Configuration Variables
ODOO_VERSION="17"
POSTGRES_VERSION="15"
DB_USER="odoo"
DB_PASSWORD="odoo_password"
DB_NAME="postgres"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Starting Odoo Deployment Script...${NC}"

# 1. Prompt for Project Name
read -p "Enter a name for your project (no spaces, e.g., my-odoo): " PROJECT_NAME

# Validate input (default to 'odoo-server' if empty)
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="odoo-server"
fi

echo -e "${GREEN}Project name set to: $PROJECT_NAME${NC}"

# 2. Update and Install Dependencies
echo -e "${GREEN}Checking system requirements...${NC}"

sudo apt-get update -qq

# Install Curl if missing
if ! command -v curl &> /dev/null; then
    echo "Curl not found. Installing..."
    sudo apt-get install -y curl
fi

# Install Docker if missing
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing..."
    sudo apt-get install -y docker.io
fi

# Install Docker Compose if missing
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing..."
    sudo apt-get install -y docker-compose-plugin || sudo apt-get install -y docker-compose
fi

# Ensure Docker service is running
sudo systemctl start docker
sudo systemctl enable docker

# 3. Setup Project Directory (in User Home)
echo -e "${GREEN}Setting up project directory at ~/$PROJECT_NAME...${NC}"
cd ~
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# 4. Generate docker-compose.yml with Custom Container Names
echo -e "${GREEN}Generating docker-compose.yml...${NC}"

cat <<EOF > docker-compose.yml
version: '3.1'
services:
  web:
    image: odoo:${ODOO_VERSION}
    container_name: ${PROJECT_NAME}-odoo
    depends_on:
      - db
    ports:
      - "8069:8069"
    volumes:
      - odoo-web-data:/var/lib/odoo
      - ./config:/etc/odoo
      - ./addons:/mnt/extra-addons
    environment:
      - HOST=db
      - USER=${DB_USER}
      - PASSWORD=${DB_PASSWORD}
    restart: always

  db:
    image: postgres:${POSTGRES_VERSION}
    container_name: ${PROJECT_NAME}-db
    environment:
      - POSTGRES_DB=${DB_NAME}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_USER=${DB_USER}
    volumes:
      - odoo-db-data:/var/lib/postgresql/data
    restart: always

volumes:
  odoo-web-data:
  odoo-db-data:
EOF

# 5. Create Subdirectories
mkdir -p config addons

# 6. Start Containers
echo -e "${GREEN}Starting Odoo and Database containers...${NC}"

if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

# 7. Get Local IP
# This grabs the first private IP address found on the machine
LOCAL_IP=$(hostname -I | awk '{print $1}')

# Final Status
echo -e "${GREEN}Deployment Complete!${NC}"
echo "----------------------------------------------------"
echo "Project: $PROJECT_NAME"
echo "Odoo Container: ${PROJECT_NAME}-odoo"
echo "DB Container:   ${PROJECT_NAME}-db"
echo ""
echo "Access Odoo via: http://${LOCAL_IP}:8069"
echo "----------------------------------------------------"
