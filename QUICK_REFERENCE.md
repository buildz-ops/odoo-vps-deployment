# Quick Reference Guide

Essential commands and configurations for Odoo VPS deployment.

---

## 🚀 Quick Deploy Commands

```bash
# Initial HTTP deployment
cp docker-compose.http.yml docker-compose.yml
nano docker-compose.yml  # Change passwords
docker compose up -d

# Upgrade to HTTPS
docker compose down
cp docker-compose.https.yml docker-compose.yml
nano docker-compose.yml  # Change passwords
docker compose up -d
```

---

## 🔐 Default Credentials

### Nginx Proxy Manager (Port 81)
- **Email**: `admin@example.com`
- **Password**: `changeme`
- ⚠️ **Change immediately after first login**

### PostgreSQL
- **User**: `odoo`
- **Password**: `YOUR_SECURE_PASSWORD_HERE` (set in docker-compose.yml)
- **Database**: `postgres`

---

## 🐳 Docker Commands

```bash
# Container management
docker compose ps                    # Check status
docker compose up -d                 # Start services
docker compose down                  # Stop services
docker compose restart               # Restart all
docker compose restart odoo          # Restart Odoo only

# Logs
docker compose logs -f               # Follow all logs
docker compose logs -f odoo          # Follow Odoo logs
docker compose logs -f nginx-proxy   # Follow Nginx logs

# Shell access
docker exec -it odoo /bin/bash       # Enter Odoo container
docker exec -it odoo-vps-deployment-db-1 psql -U odoo -d postgres  # Access DB
```

---

## 🔥 Firewall (UFW)

```bash
# Setup
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# Management
sudo ufw status verbose              # Check status
sudo ufw disable                     # Disable firewall
sudo ufw reload                      # Reload rules
```

---

## 🌐 Nginx Proxy Host Configuration

| Setting | Value |
|---------|-------|
| Domain Names | `yourproject.duckdns.org` |
| Scheme | `http` |
| Forward Hostname/IP | `odoo` |
| Forward Port | `8069` |
| Block Common Exploits | ✅ |
| Websockets Support | ✅ |
| SSL Certificate | ✅ Request new |
| Force SSL | ✅ |

---

## 📁 Important Paths

### On Host System
```
~/odoo-vps/
├── docker-compose.yml        # Active configuration
├── addons/                   # Custom Odoo addons
├── nginx-data/               # Nginx Proxy Manager data
└── letsencrypt/              # SSL certificates
```

### Inside Odoo Container
```
/etc/odoo/odoo.conf           # Configuration
/var/lib/odoo                 # Filestore
/mnt/extra-addons             # Custom addons
/usr/lib/python3/dist-packages/odoo  # Source code
```

---

## 🔧 Common Fixes

### Reset Nginx Admin Password
```bash
docker exec -it odoo-vps-deployment-nginx-proxy-1 /bin/bash
cd /data
sqlite3 database.sqlite
UPDATE auth SET secret = '$2a$12$abcdefghijklmnopqrstuv' WHERE id = 1;
.quit
exit
docker compose restart nginx-proxy
# Default password is now: changeme
```

### Fix File Permissions
```bash
sudo chown -R $USER:$USER ~/odoo-vps
sudo chmod -R 755 ~/odoo-vps
```

### Rebuild Containers
```bash
docker compose down
docker compose up -d --force-recreate
```

### Clean Docker System
```bash
docker system prune -a          # Remove unused data
docker volume prune             # Remove unused volumes (⚠️ DANGEROUS)
```

---

## 🔍 Health Checks

```bash
# Check if services are responding
curl http://localhost:8069                    # Odoo (internal)
curl http://your-vps-ip:81                    # Nginx Admin
curl https://yourproject.duckdns.org          # Production URL

# Check DNS
nslookup yourproject.duckdns.org

# Check SSL certificate
echo | openssl s_client -connect yourproject.duckdns.org:443 -servername yourproject.duckdns.org 2>/dev/null | openssl x509 -noout -dates
```

---

## 📊 Monitoring

```bash
# Resource usage
docker stats                    # Real-time container stats
docker compose top              # Process list

# Disk usage
docker system df                # Docker disk usage
du -sh ~/odoo-vps/*            # Directory sizes
```

---

## 🔄 Backup & Restore

### Backup
```bash
# Backup volumes
docker run --rm -v odoo-db-data:/data -v $(pwd):/backup ubuntu tar czf /backup/odoo-db-backup.tar.gz /data
docker run --rm -v odoo-data:/data -v $(pwd):/backup ubuntu tar czf /backup/odoo-data-backup.tar.gz /data

# Backup configuration
cp docker-compose.yml docker-compose.yml.backup
```

### Restore
```bash
# Restore volumes
docker run --rm -v odoo-db-data:/data -v $(pwd):/backup ubuntu tar xzf /backup/odoo-db-backup.tar.gz -C /
docker run --rm -v odoo-data:/data -v $(pwd):/backup ubuntu tar xzf /backup/odoo-data-backup.tar.gz -C /
```

---

## 🆘 Emergency Commands

```bash
# Complete reset (⚠️ DESTROYS ALL DATA)
docker compose down -v
rm -rf nginx-data/ letsencrypt/ addons/
docker compose up -d

# Force stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)
```

---

**Last Updated:** December 2024
