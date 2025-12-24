# Odoo VPS Deployment with Docker

Complete guide for deploying Odoo with Docker, PostgreSQL, and HTTPS via Nginx Proxy Manager.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ⚡ Automated Deployment (Recommended)

**For a fully automated setup, use the included deployment script:**

```bash
# Download the script
wget https://raw.githubusercontent.com/buildz-ops/odoo-vps-deployment/main/auto-deploy.sh

# Make it executable
chmod +x auto-deploy.sh

# Run the deployment
./auto-deploy.sh
```

**What the script does:**
- ✅ Installs Docker and Docker Compose automatically
- ✅ Creates project directory structure
- ✅ Generates docker-compose.yml with Odoo 19 and PostgreSQL 16
- ✅ Starts containers in detached mode
- ✅ Displays access URL with your public IP

**After deployment:**
- Access Odoo at: `http://your-vps-ip:8069`
- Follow [HTTPS Configuration](#https-configuration) for production setup

**⚠️ Security Note:** The script uses default passwords. **Change them immediately** in `~/odoo-server/docker-compose.yml` before production use:
```bash
cd ~/odoo-server
nano docker-compose.yml
# Change DB_PASSWORD and POSTGRES_PASSWORD to secure values
docker compose down && docker compose up -d
```

---

**Prefer manual installation?** Continue with the detailed steps below.

---

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Initial Setup](#initial-setup)
4. [Basic Odoo Deployment](#basic-odoo-deployment)
5. [HTTPS Configuration](#https-configuration)
6. [Firewall Configuration](#firewall-configuration)
7. [Docker Management](#docker-management)
8. [Container Navigation](#container-navigation)
9. [Automated Deployment Details](#-automated-deployment-details)
10. [Troubleshooting](#troubleshooting)

---

## 🔧 Prerequisites

- Ubuntu Server (20.04 or later recommended)
- Docker and Docker Compose installed
- Root or sudo access
- Public IP address
- Domain name (DuckDNS or custom domain)

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/odoo-vps-deployment.git
cd odoo-vps-deployment

# Copy the docker-compose file
cp docker-compose.http.yml docker-compose.yml

# Edit passwords (IMPORTANT!)
nano docker-compose.yml

# Start Odoo
docker compose up -d

# Access Odoo at http://your-vps-ip:8069
```

---

## Initial Setup

### Create Project Directory
```bash
# Create and navigate to project directory
mkdir odoo-vps
cd odoo-vps
```

---

## Basic Odoo Deployment

### Step 1: Use the HTTP Configuration

Download or copy `docker-compose.http.yml` from this repository and rename it to `docker-compose.yml`.

**⚠️ IMPORTANT**: Change the password placeholders:
- Replace `YOUR_SECURE_PASSWORD_HERE` with a strong password
- Ensure both `POSTGRES_PASSWORD` and `PASSWORD` match

### Step 2: Start Docker Containers

```bash
# Start containers in detached mode
docker compose up -d
```

### Step 3: Verify Deployment

```bash
# Check container status
docker compose ps
```

### Step 4: Access Web Interface

Navigate to: `http://your-vps-ip:8069`

**Initial Setup Screen:**
- **Master Password**: Auto-generated or set in config
- **Database Name**: Choose your database name (e.g., `my_company`)
- Complete the setup wizard

---

## HTTPS Configuration

### Step 1: Update Docker Compose for HTTPS

```bash
# Stop current containers
docker compose down

# Use the HTTPS configuration
cp docker-compose.https.yml docker-compose.yml

# Edit passwords again
nano docker-compose.yml
```

### Step 2: Restart with New Configuration

```bash
# ⚠️ IMPORTANT: Run this from the docker-compose.yml directory
docker compose up -d
```

### Step 3: Configure Domain Name (DuckDNS)

1. Visit [DuckDNS.org](https://www.duckdns.org)
2. Sign up/login
3. Create a subdomain: `yourproject.duckdns.org`
4. Point it to your VPS IP address

**Verify DNS Configuration:**
```bash
# Check DNS propagation
nslookup yourproject.duckdns.org
```

### Step 4: Configure Nginx Proxy Manager

**Access Nginx Admin Panel:**
- URL: `http://your-vps-ip:81`
- **Default Email**: `admin@example.com`
- **Default Password**: `changeme`
- ⚠️ **Change these credentials immediately after first login**

**Add Proxy Host:**
1. Click **Proxy Hosts** → **Add Proxy Host**
2. **Details Tab:**
   - **Domain Names**: `yourproject.duckdns.org`
   - **Scheme**: `http`
   - **Forward Hostname/IP**: `odoo`
   - **Forward Port**: `8069`
   - ✅ Enable: **Block Common Exploits**
   - ✅ Enable: **Websockets Support**

3. **SSL Tab:**
   - ✅ Request a new SSL Certificate
   - ✅ Force SSL
   - ✅ HTTP/2 Support
   - Enter email for Let's Encrypt notifications
   - ✅ Agree to Let's Encrypt Terms

4. Click **Save**

### Step 5: Access Secure Odoo

Navigate to: `https://yourproject.duckdns.org`

---

## Firewall Configuration

### Install and Configure UFW

```bash
# Install UFW (if not already installed)
sudo apt install ufw

# Allow SSH (⚠️ CRITICAL - Do this first to avoid lockout)
sudo ufw allow ssh

# Allow HTTP traffic (for Let's Encrypt validation and redirects)
sudo ufw allow 80/tcp

# Allow HTTPS traffic
sudo ufw allow 443/tcp

# ⚠️ DO NOT expose port 8069 after Nginx setup (security best practice)
# Port 8069 remains internal to Docker network only

# Enable firewall
sudo ufw enable

# Verify firewall rules
sudo ufw status verbose
```

**Expected Output:**
```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
```

---

## Docker Management

### Essential Commands

```bash
# Check container status
docker compose ps

# View container logs
docker compose logs -f odoo

# Restart specific service
docker compose restart odoo

# Restart all services
docker compose restart

# Stop all services
docker compose down

# Stop all services and remove volumes (⚠️ DATA LOSS)
docker compose down -v

# Restart individual container by ID
docker restart CONTAINER_ID
```

### Docker Installation Paths

- **Default Storage**: `/var/lib/docker`
- **Binary Location**: `/usr/bin/docker` or `/usr/local/bin/docker`
- **Service File**: `/lib/systemd/system/docker.service`

**Verify Docker Root Directory:**
```bash
docker info | grep "Docker Root Dir"
```

**Restart Docker Service:**
```bash
sudo systemctl restart docker
```

---

## Container Navigation

### Odoo Container Internal Structure

| Path | Description |
|------|-------------|
| `/etc/odoo/odoo.conf` | Odoo configuration file |
| `/var/lib/odoo` | Filestore (attachments, sessions) |
| `/usr/lib/python3/dist-packages/odoo` | Odoo source code |
| `/mnt/extra-addons` | Custom addons directory |

### Access Odoo Container Shell

```bash
# Enter Odoo container
docker exec -it odoo /bin/bash

# Exit container
exit
```

---

## 🤖 Automated Deployment Details

### Script Configuration

The `auto-deploy.sh` script uses these default values:

| Variable | Default Value | Customizable |
|----------|---------------|--------------|
| ODOO_VERSION | 17 | Yes - Edit line 4 |
| POSTGRES_VERSION | 15 | Yes - Edit line 5 |
| PROJECT_NAME | odoo-server | Yes - Edit line 6 |
| DB_USER | odoo | Yes - Edit line 7 |
| DB_PASSWORD | odoo_password | ⚠️ **CHANGE THIS** - Edit line 8 |

### Customizing the Script

```bash
# Edit configuration variables
nano auto-deploy.sh

# Modify these lines as needed:
ODOO_VERSION="17"           # Change Odoo version
DB_PASSWORD="your_secure_password"  # Set strong password
PROJECT_NAME="my-odoo"      # Customize directory name
```

### What Happens During Deployment

1. **System Check**: Verifies and installs Docker, Docker Compose, and curl
2. **Directory Setup**: Creates `~/odoo-server/` with subdirectories
3. **Configuration**: Generates docker-compose.yml with your settings
4. **Container Launch**: Starts Odoo and PostgreSQL containers
5. **IP Detection**: Displays your public IP for immediate access

### Post-Deployment Steps

```bash
# Navigate to project directory
cd ~/odoo-server

# View running containers
docker compose ps

# Check logs
docker compose logs -f

# Stop containers
docker compose down
```

---

## Troubleshooting

### File Permissions for Development

**Check Folder Ownership:**
```bash
ls -ld /path/to/your/folder
```

**Fix Ownership Issues:**
```bash
# Change ownership to current user
sudo chown -R $USER:$USER ~/odoo-vps

# Grant full permissions (development only)
sudo chmod -R 777 ~/odoo-vps

# Set addons folder permissions
sudo chown -R $USER:$USER ~/odoo-vps/addons
```

### Common Issues

**Issue: Can't access Odoo after HTTPS setup**
- Verify DNS propagation: `nslookup yourproject.duckdns.org`
- Check Nginx logs: `docker compose logs nginx-proxy`
- Ensure SSL certificate was issued successfully in Nginx admin panel

**Issue: Database connection error**
- Verify passwords match in `docker-compose.yml`
- Check database container is running: `docker compose ps`
- Review logs: `docker compose logs db`

**Issue: Port 8069 blocked**
- After HTTPS setup, port 8069 should NOT be accessible externally
- Access only via: `https://yourproject.duckdns.org`
- Internal access for debugging: `docker exec -it odoo /bin/bash`

---

## 🔒 Security Checklist

- ✅ Change default PostgreSQL password
- ✅ Change Nginx Proxy Manager admin credentials
- ✅ Configure UFW firewall
- ✅ Do NOT expose port 8069 after HTTPS setup
- ✅ Enable Force SSL in Nginx
- ✅ Set up automatic SSL renewal (Let's Encrypt handles this)
- ✅ Regular backups of Docker volumes

---

## 📁 Repository Structure

```
odoo-vps-deployment/
├── README.md                    # Complete documentation
├── auto-deploy.sh              # Automated deployment script
├── docker-compose.http.yml      # HTTP configuration (development/testing)
├── docker-compose.https.yml     # HTTPS configuration (production)
├── .gitignore                   # Git ignore file
└── LICENSE                      # MIT License
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

---

## 📧 Support

If you encounter any issues or have questions, please open an issue in this repository.

---

**Document Version:** 1.1  
**Last Updated:** 23/12/2025  
**Tested Environment:** Debian VPS w/ Docker
