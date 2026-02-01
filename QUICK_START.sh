#!/bin/bash
# 🚀 MedicalProMax - Quick Start Command Guide
# This file contains all commands needed to deploy the platform

################################################################################
# SECTION 1: VPS CONNECTION (STEP 1)
################################################################################

# SSH into your VPS
ssh -i /path/to/your/private_key.pem username@YOUR_VPS_IP

# If using password authentication instead:
ssh username@YOUR_VPS_IP
# Then enter password when prompted

# Verify VPS connection
whoami
uname -a
df -h
free -h

################################################################################
# SECTION 2: CLONE REPOSITORY (STEP 2)
################################################################################

# Navigate to home directory
cd ~

# Clone the MedicalProMax repository
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
cd medicalpromaxproject

################################################################################
# SECTION 3: RUN SETUP SCRIPTS (STEPS 3-7)
################################################################################

# STEP 3: System Environment Setup (20 minutes)
# Installs Python, MySQL, Node.js, Nginx, Redis, Supervisor, Certbot
echo "Running VPS system setup..."
sudo bash scripts/setup-vps.sh

# When prompted, enter your GitHub repository URL:
# https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git

################################################################################
# STEP 4: Initialize MySQL Database (5 minutes)
################################################################################

echo "Initializing MySQL database..."
sudo bash scripts/init-database.sh

# When prompted, enter:
# - MySQL Root Password (from your VPS)
# - medicalpromax_db (database name)
# - medicalpromax_user (database user)
# - STRONG_PASSWORD (save this in .env file later!)

################################################################################
# STEP 5: Setup Django Backend (15 minutes)
################################################################################

echo "Setting up Django backend..."
sudo bash scripts/setup-backend.sh

# When prompted, enter Django superuser credentials:
# - Email: admin@medicalpromax.ir
# - First Name: Admin
# - Last Name: User
# - Password: Strong password

# After setup, update environment variables:
sudo nano /var/www/medicalpromax/backend/.env.production

# Update these fields:
# DATABASE_PASSWORD=<from_step_4>
# SECRET_KEY=<generate_random>
# EMAIL_HOST_USER=your-email@gmail.com
# EMAIL_HOST_PASSWORD=app-password

# Start backend service
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start medicalpromax-backend

# Verify backend
sudo supervisorctl status medicalpromax-backend
curl http://localhost:8000/api/specialties/

################################################################################
# STEP 6: Setup Next.js Frontend (10 minutes)
################################################################################

echo "Setting up Next.js frontend..."
sudo bash scripts/setup-frontend.sh

# Update environment if needed:
sudo nano /var/www/medicalpromax/frontend/.env.production

# Start frontend service
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start medicalpromax-frontend

# Verify frontend
sudo supervisorctl status medicalpromax-frontend
curl http://localhost:3000/

################################################################################
# STEP 7: Configure Nginx & SSL (10 minutes)
################################################################################

# Copy Nginx configuration
sudo cp /var/www/medicalpromax/repo/config/nginx-medicalpromax.conf \
    /etc/nginx/sites-available/medicalpromax

# Enable site
sudo ln -s /etc/nginx/sites-available/medicalpromax \
    /etc/nginx/sites-enabled/medicalpromax

# Disable default site
sudo rm /etc/nginx/sites-enabled/default 2>/dev/null || true

# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Request SSL certificate (requires domain DNS to be active)
sudo certbot --nginx -d medicalpromax.ir -d www.medicalpromax.ir

# Follow prompts:
# 1. Enter email
# 2. Accept terms (A)
# 3. Choose redirect option (2 - Redirect HTTP to HTTPS)

# Verify SSL certificate
sudo certbot certificates

# Test auto-renewal
sudo certbot renew --dry-run

################################################################################
# SECTION 4: VERIFY DEPLOYMENT
################################################################################

# Check all services
echo "Checking service status..."
sudo supervisorctl status

# Check Nginx
sudo systemctl status nginx

# Check MySQL
sudo systemctl status mysql

# Check Redis
sudo systemctl status redis-server

# Check ports
sudo netstat -tulpn | grep -E ':(80|443|8000|3000|6379|3306)'

################################################################################
# SECTION 5: TEST THE PLATFORM
################################################################################

# Test backend API
echo "Testing backend API..."
curl -X GET https://medicalpromax.ir/api/specialties/

# Register new user
echo "Testing user registration..."
curl -X POST https://medicalpromax.ir/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@medicalpromax.ir",
    "password": "Test123!@",
    "first_name": "علی",
    "last_name": "محمدی"
  }'

# Login user
echo "Testing login..."
curl -X POST https://medicalpromax.ir/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@medicalpromax.ir",
    "password": "Test123!@"
  }'

# Test frontend
echo "Testing frontend..."
curl -I https://medicalpromax.ir/
# Should return 200 OK

# Visit in browser
echo "Opening platform in browser..."
echo "https://medicalpromax.ir"

################################################################################
# SECTION 6: MONITORING & MAINTENANCE
################################################################################

# View backend logs
tail -f /var/log/medicalpromax/backend-access.log

# View frontend logs
tail -f /var/log/medicalpromax/frontend-stdout.log

# View Nginx logs
tail -f /var/log/nginx/medicalpromax-access.log

# System resources
htop

# Disk usage
df -h

# Restart services
sudo supervisorctl restart medicalpromax-backend
sudo supervisorctl restart medicalpromax-frontend
sudo systemctl reload nginx

# Backup database
mysqldump -u medicalpromax_user -p medicalpromax_db | \
  gzip > /var/www/medicalpromax/backups/backup_$(date +%Y%m%d_%H%M%S).sql.gz

################################################################################
# SECTION 7: UPDATES & DEPLOYMENT
################################################################################

# Pull latest code from GitHub
cd /var/www/medicalpromax/repo
git pull origin main

# Update backend
cd /var/www/medicalpromax/backend
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
sudo supervisorctl restart medicalpromax-backend

# Update frontend
cd /var/www/medicalpromax/frontend
npm install
npm run build
sudo supervisorctl restart medicalpromax-frontend

# Reload Nginx
sudo systemctl reload nginx

################################################################################
# SECTION 8: TROUBLESHOOTING COMMANDS
################################################################################

# Test backend connectivity
curl -v http://localhost:8000/

# Test frontend connectivity
curl -v http://localhost:3000/

# Check Python installation
python3.11 --version

# Check virtual environment
source /var/www/medicalpromax/backend/venv/bin/activate
pip list

# Database connection test
mysql -u medicalpromax_user -p medicalpromax_db -e "SELECT 1;"

# Check Django migrations
cd /var/www/medicalpromax/backend
source venv/bin/activate
python manage.py showmigrations

# Create Django admin superuser
cd /var/www/medicalpromax/backend
source venv/bin/activate
python manage.py createsuperuser

# Run Django tests
python manage.py test

# Restart all services at once
sudo supervisorctl restart all && sudo systemctl reload nginx

# Full system reboot (if needed)
sudo reboot

################################################################################
# QUICK REFERENCE: Most Used Commands
################################################################################

# SSH into VPS
ssh -i key.pem user@IP

# Check service status
sudo supervisorctl status

# View logs
tail -f /var/log/medicalpromax/backend-access.log
tail -f /var/log/medicalpromax/frontend-stdout.log

# Restart services
sudo supervisorctl restart medicalpromax-backend
sudo supervisorctl restart medicalpromax-frontend

# Pull and update code
cd /var/www/medicalpromax/repo && git pull origin main

# Rebuild backend
cd /var/www/medicalpromax/backend && \
  source venv/bin/activate && \
  pip install -r requirements.txt && \
  python manage.py migrate && \
  sudo supervisorctl restart medicalpromax-backend

# Rebuild frontend
cd /var/www/medicalpromax/frontend && \
  npm install && npm run build && \
  sudo supervisorctl restart medicalpromax-frontend

################################################################################
# EXPECTED OUTCOMES
################################################################################

# After successful deployment, you should see:
# ✓ https://medicalpromax.ir loads in browser
# ✓ Persian/RTL layout with specialty cards
# ✓ API responses at https://medicalpromax.ir/api/specialties/
# ✓ Green SSL lock 🔒 in browser
# ✓ All services running in supervisorctl status
# ✓ No errors in logs

################################################################################
# SUPPORT & DOCUMENTATION
################################################################################

# Full VPS Setup Guide
cat VPS_SETUP_GUIDE.md

# Deployment Checklist
cat DEPLOYMENT_CHECKLIST.md

# API Testing Guide
cat api_testing_guide.md

# Project README
cat README_PROJECT.md

# View Nginx config
cat /etc/nginx/sites-available/medicalpromax

# View Supervisor status
sudo supervisorctl status

# View system logs
sudo journalctl -xe

################################################################################

echo "✅ MedicalProMax deployment complete!"
echo "🌐 Visit: https://medicalpromax.ir"
echo "📊 Admin panel: https://medicalpromax.ir/admin"
echo "📝 API docs: https://medicalpromax.ir/api/"

################################################################################
