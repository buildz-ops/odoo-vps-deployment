#!/bin/bash

# Configuration Variables
ODOO_VERSION="17"
POSTGRES_VERSION="15"
PROJECT_NAME="odoo-server"
DB_USER="odoo"
DB_PASSWORD="odoo_password"
DB_NAME="postgres"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Starting Odoo Deployment Script...${NC}"

# 1. Update and Install Dependencies (Docker + Curl)
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

# 2. Setup Project Directory
echo -e "${GREEN}Setting up project directory at ~/$PROJECT_NAME...${NC}"
cd ~
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# 3. Generate docker-compose.yml
echo -e "${GREEN}Generating docker-compose.yml...${NC}"

cat <<EOF > docker-compose.yml
version: '3.1'
services:
  web:
    image: odoo:${ODOO_VERSION}
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

# 4. Create Subdirectories
mkdir -p config addons

# 5. Start Containers
echo -e "${GREEN}Starting Odoo and Database containers...${NC}"

if docker compose version &> /dev/null; then
    sudo docker compose up -d
else
    sudo docker-compose up -d
fi

# 6. Final Status
echo -e "${GREEN}Deployment Complete!${NC}"
echo "----------------------------------------------------"
echo "Odoo is running on port 8069."
echo "Access it via: http://$(curl -s ifconfig.me):8069"
echo "----------------------------------------------------"