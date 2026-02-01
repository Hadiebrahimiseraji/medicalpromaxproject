# VPS CONNECTION & SETUP GUIDE
# MedicalProMax Platform

## 📋 Prerequisites

Before starting, you need:

1. **VPS Server Details**
   - Server IP Address
   - SSH Username (usually `root` or `ubuntu`)
   - SSH Port (usually 22)
   - SSH Private Key OR Password

2. **GitHub Repository**
   - https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
   - Personal Access Token (for private repos)

3. **Domain Name**
   - medicalpromax.ir
   - DNS pointing to VPS IP

4. **MySQL Credentials** (you'll create these)
   - Username: medicalpromax_user
   - Password: (set during setup)

---

## 🔌 STEP 1: Connect to VPS via SSH

### Option A: Using SSH Key (Recommended)

```bash
# Basic connection
ssh -i /path/to/your/private_key.pem username@YOUR_VPS_IP

# Example with custom SSH port (if changed)
ssh -i /path/to/your/private_key.pem -p 2222 username@YOUR_VPS_IP

# Verify connection
whoami
uname -a
```

### Option B: Using SSH Password

```bash
ssh username@YOUR_VPS_IP
# Then enter password when prompted
```

### Testing VPS Access

```bash
# Check current user
whoami

# Check OS version
cat /etc/os-release

# Check available storage
df -h

# Check RAM
free -h

# Expected output: Ubuntu 22.04 LTS or 24.04 LTS
```

---

## 🚀 STEP 2: Download Setup Scripts to VPS

Once connected to VPS:

```bash
# Create directory for project
mkdir -p ~/medicalpromax-setup
cd ~/medicalpromax-setup

# Download VPS setup script from your local machine
# Option A: Using Git (if repo is cloned)
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
cd medicalpromaxproject/scripts

# Option B: Download individual scripts
wget https://raw.githubusercontent.com/Hadiebrahimiseraji/medicalpromaxproject/main/scripts/setup-vps.sh
wget https://raw.githubusercontent.com/Hadiebrahimiseraji/medicalpromaxproject/main/scripts/setup-backend.sh
wget https://raw.githubusercontent.com/Hadiebrahimiseraji/medicalpromaxproject/main/scripts/setup-frontend.sh

# Make scripts executable
chmod +x setup-vps.sh setup-backend.sh setup-frontend.sh
```

---

## ⚙️ STEP 3: Run VPS System Setup (15-20 minutes)

```bash
cd ~/medicalpromax-setup/scripts

# Run main VPS setup
sudo bash setup-vps.sh

# This will:
# ✓ Update system packages
# ✓ Install Python 3.11
# ✓ Install MySQL 8.0
# ✓ Install Node.js 20
# ✓ Install Nginx
# ✓ Install Redis
# ✓ Install Supervisor
# ✓ Setup Firewall
# ✓ Create application directories
# ✓ Clone your GitHub repository
```

**After setup-vps.sh completes:**
- All dependencies are installed
- Repository is cloned to `/var/www/medicalpromax/repo`
- Application directories are created
- Firewall is configured

---

## 🗄️ STEP 4: Initialize MySQL Database

```bash
# Connect to MySQL
sudo mysql -u root -p

# OR (if no root password set)
sudo mysql
```

**Inside MySQL prompt:**

```sql
-- Create database
CREATE DATABASE medicalpromax_db 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

-- Create user
CREATE USER 'medicalpromax_user'@'localhost' 
    IDENTIFIED BY 'YOUR_STRONG_PASSWORD_HERE';

-- Grant privileges
GRANT ALL PRIVILEGES ON medicalpromax_db.* 
    TO 'medicalpromax_user'@'localhost';

-- Apply changes
FLUSH PRIVILEGES;

-- Exit MySQL
EXIT;
```

**Verify database creation:**

```bash
mysql -u medicalpromax_user -p -e "SHOW DATABASES;"
# Enter password when prompted
# Should show medicalpromax_db in the list
```

---

## 🐍 STEP 5: Setup Django Backend (10 minutes)

```bash
cd ~/medicalpromax-setup/scripts
sudo bash setup-backend.sh

# This will:
# ✓ Create Python virtual environment
# ✓ Install Django dependencies
# ✓ Create .env.production file
# ✓ Run database migrations
# ✓ Create Django superuser (interactive)
# ✓ Collect static files
# ✓ Create Supervisor configuration
```

**After setup-backend.sh completes:**
- Edit environment variables:

```bash
sudo nano /var/www/medicalpromax/backend/.env.production
```

**Update these fields:**
```
DATABASE_PASSWORD=YOUR_STRONG_PASSWORD_HERE  # Use password from MySQL setup
SECRET_KEY=generate_random_secret_here
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
```

**Start Django backend:**

```bash
# Reload Supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start medicalpromax-backend

# Verify status
sudo supervisorctl status medicalpromax-backend

# View logs
tail -f /var/log/medicalpromax/backend-access.log
```

**Test backend:**

```bash
curl -X GET http://localhost:8000/api/specialties/
# Should return JSON with specialties
```

---

## ⚛️ STEP 6: Setup Next.js Frontend (5 minutes)

```bash
cd ~/medicalpromax-setup/scripts
sudo bash setup-frontend.sh

# This will:
# ✓ Copy frontend files
# ✓ Install npm dependencies
# ✓ Create .env.production file
# ✓ Build Next.js project
# ✓ Create Supervisor configuration
```

**After setup-frontend.sh completes:**
- Edit environment variables if needed:

```bash
sudo nano /var/www/medicalpromax/frontend/.env.production
```

**Start Next.js frontend:**

```bash
# Reload Supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start medicalpromax-frontend

# Verify status
sudo supervisorctl status medicalpromax-frontend

# View logs
tail -f /var/log/medicalpromax/frontend-stdout.log
```

**Test frontend:**

```bash
curl -X GET http://localhost:3000/
# Should return HTML (Next.js page)
```

---

## 🌐 STEP 7: Configure Nginx as Reverse Proxy

```bash
# Copy Nginx configuration
sudo cp ~/medicalpromax-setup/config/nginx-medicalpromax.conf \
    /etc/nginx/sites-available/medicalpromax

# Enable site
sudo ln -s /etc/nginx/sites-available/medicalpromax \
    /etc/nginx/sites-enabled/medicalpromax

# Disable default site (optional)
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t
# Should output: syntax is ok, test is successful

# Reload Nginx
sudo systemctl reload nginx

# Verify services
sudo systemctl status nginx
```

**Test through Nginx:**

```bash
# Test from another terminal
curl -H "Host: medicalpromax.ir" http://localhost

# Should show Next.js frontend or Nginx error (which is ok)
```

---

## 🔐 STEP 8: Setup SSL/TLS Certificate (Let's Encrypt)

```bash
# Ensure domain DNS points to VPS IP first!
# This can take 15-30 minutes to propagate

# Request SSL certificate
sudo certbot --nginx -d medicalpromax.ir -d www.medicalpromax.ir

# Follow the interactive prompts:
# 1. Enter email address
# 2. Accept terms
# 3. Choose redirect option (recommend: redirect HTTP to HTTPS)

# Verify certificate
sudo certbot certificates

# Test auto-renewal
sudo certbot renew --dry-run

# Certificate will auto-renew every 90 days
```

---

## ✅ STEP 9: Verify Complete Setup

```bash
# Check all services are running
echo "=== Nginx Status ==="
sudo systemctl status nginx

echo -e "\n=== Supervisor Status ==="
sudo supervisorctl status

echo -e "\n=== MySQL Status ==="
sudo systemctl status mysql

echo -e "\n=== Redis Status ==="
sudo systemctl status redis-server

echo -e "\n=== Port Status ==="
sudo netstat -tulpn | grep -E ':(80|443|8000|3000|6379|3306)'
```

**Expected output:**
- Nginx: running on 80, 443
- Backend: running on 8000
- Frontend: running on 3000
- MySQL: running on 3306
- Redis: running on 6379

---

## 🧪 STEP 10: Test Complete Platform

### Test Backend API

```bash
# List specialties
curl -X GET https://medicalpromax.ir/api/specialties/

# Test authentication
curl -X POST https://medicalpromax.ir/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@medicalpromax.ir",
    "password": "Test123!@",
    "first_name": "علی",
    "last_name": "محمدی"
  }'

# Login
curl -X POST https://medicalpromax.ir/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@medicalpromax.ir",
    "password": "Test123!@"
  }'
```

### Test Frontend

```bash
# Open in browser
# https://medicalpromax.ir

# Should show:
# ✓ Persian/RTL layout
# ✓ Specialty selection cards
# ✓ Responsive design
# ✓ No console errors
```

---

## 📊 Monitoring & Maintenance

### Monitor Services

```bash
# Real-time system monitoring
htop

# View Supervisor logs
sudo tail -f /var/log/medicalpromax/backend-access.log
sudo tail -f /var/log/medicalpromax/frontend-stdout.log
sudo tail -f /var/log/nginx/medicalpromax-access.log
sudo tail -f /var/log/nginx/medicalpromax-error.log

# MySQL query log
sudo tail -f /var/log/mysql/error.log
```

### Restart Services

```bash
# Restart backend
sudo supervisorctl restart medicalpromax-backend

# Restart frontend
sudo supervisorctl restart medicalpromax-frontend

# Restart Nginx
sudo systemctl restart nginx

# Restart all services
sudo supervisorctl restart all
```

### Database Backup

```bash
# Create backup
mysqldump -u medicalpromax_user -p medicalpromax_db | \
  gzip > /var/www/medicalpromax/backups/backup_$(date +%Y%m%d_%H%M%S).sql.gz

# List backups
ls -lah /var/www/medicalpromax/backups/

# Restore from backup
gunzip < backup_file.sql.gz | mysql -u medicalpromax_user -p medicalpromax_db
```

---

## 🐛 Troubleshooting

### Backend not starting

```bash
# Check logs
tail -100 /var/log/medicalpromax/backend-error.log

# Verify Python venv
/var/www/medicalpromax/backend/venv/bin/python --version

# Test migration
cd /var/www/medicalpromax/backend
source venv/bin/activate
python manage.py migrate
```

### Frontend not building

```bash
# Check Node version
node --version  # Should be v20.x+

# Rebuild frontend
cd /var/www/medicalpromax/frontend
npm run build

# Check build errors
tail -100 /var/log/medicalpromax/frontend-stdout.log
```

### Nginx 502 Bad Gateway

```bash
# Check if backend is running
curl http://localhost:8000/api/specialties/

# Check Nginx error log
tail -50 /var/log/nginx/medicalpromax-error.log

# Verify proxy configuration
sudo nginx -T | grep -A 10 "location /api"
```

### DNS/Domain not resolving

```bash
# Check DNS resolution
nslookup medicalpromax.ir
dig medicalpromax.ir

# Should show VPS IP address

# Verify domain points to VPS
curl -I -H "Host: medicalpromax.ir" http://YOUR_VPS_IP
```

---

## 📝 Quick Reference Commands

```bash
# SSH into VPS
ssh -i your_key.pem user@VPS_IP

# Check what's running
ps aux | grep -E 'gunicorn|node|nginx'

# View system resources
top
free -h
df -h

# View all logs
journalctl -xe

# Restart all services
sudo supervisorctl restart all && sudo systemctl reload nginx

# Pull latest code from GitHub
cd /var/www/medicalpromax/repo
git pull origin main

# Rebuild backend (if models changed)
cd /var/www/medicalpromax/backend
source venv/bin/activate
python manage.py migrate
sudo supervisorctl restart medicalpromax-backend

# Rebuild frontend
cd /var/www/medicalpromax/frontend
npm install && npm run build
sudo supervisorctl restart medicalpromax-frontend
```

---

## 🎯 Deployment Checklist

- [ ] VPS accessible via SSH
- [ ] System dependencies installed
- [ ] MySQL database created and user set
- [ ] Django backend running on port 8000
- [ ] Next.js frontend running on port 3000
- [ ] Nginx configured and running
- [ ] SSL certificate obtained and working
- [ ] Domain DNS pointing to VPS
- [ ] Backend API endpoints responding
- [ ] Frontend loads in browser
- [ ] Authentication working
- [ ] Database backups configured
- [ ] Monitoring and logs setup
- [ ] Security hardening completed

---

## 🚀 Production Optimization

```bash
# Enable HTTP/2
# Already configured in Nginx config

# Setup automatic backups
sudo crontab -e
# Add: 0 2 * * * /var/www/medicalpromax/scripts/backup-db.sh

# Monitor disk space
watch -n 60 'df -h'

# Setup log rotation
sudo nano /etc/logrotate.d/medicalpromax
```

---

**You're all set! 🎉**

Your MedicalProMax platform is now running on your VPS with:
- ✅ Django REST API backend
- ✅ Next.js React frontend  
- ✅ MySQL database
- ✅ Nginx reverse proxy
- ✅ SSL/TLS encryption
- ✅ Process management with Supervisor
- ✅ Automatic service restart

For questions or issues, check the logs and troubleshooting section above!
