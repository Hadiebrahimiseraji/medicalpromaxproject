# 🚀 MedicalProMax Deployment Checklist & Status

## 📋 Complete Setup Checklist

This document tracks all deployment steps for the MedicalProMax platform.

---

## ✅ PHASE 1: PRE-DEPLOYMENT (Complete)

- [x] **Repository Setup**
  - [x] GitHub repository created
  - [x] Project structure organized
  - [x] All files committed

- [x] **Documentation**
  - [x] VPS Setup Guide created
  - [x] API Testing Guide available
  - [x] README and specifications documented

- [x] **Setup Scripts**
  - [x] `setup-vps.sh` - System dependencies
  - [x] `setup-backend.sh` - Django configuration
  - [x] `setup-frontend.sh` - Next.js configuration
  - [x] `init-database.sh` - Database initialization

- [x] **Configuration Files**
  - [x] Nginx configuration (`nginx-medicalpromax.conf`)
  - [x] Supervisor configs (backend & frontend)
  - [x] Environment templates (.env.production)

---

## 📡 PHASE 2: VPS DEPLOYMENT (Ready to Execute)

### Step 1: Initial VPS Connection

**Status**: ⏳ AWAITING YOUR VPS DETAILS

**To Begin:**
```bash
# You need to provide:
1. VPS IP Address: ___________________
2. SSH Username: ___________________
3. SSH Port: ___________________
4. SSH Key or Password: ___________________
5. Domain: medicalpromax.ir (confirm)
6. OS Version: Ubuntu 22.04 or 24.04 (confirm)
```

**Once you provide details, execute:**
```bash
# Connect to VPS
ssh -i /path/to/key.pem username@YOUR_VPS_IP

# Download and run setup
curl -O https://raw.githubusercontent.com/Hadiebrahimiseraji/medicalpromaxproject/main/scripts/setup-vps.sh
sudo bash setup-vps.sh
```

---

### Step 2: System Environment

**Status**: ⏳ PENDING EXECUTION

**What gets installed:**
- [x] Python 3.11 + venv
- [x] MySQL 8.0
- [x] Node.js 20.x
- [x] Nginx
- [x] Redis
- [x] Supervisor
- [x] Git
- [x] Certbot (SSL/TLS)
- [x] UFW Firewall

**Estimated time**: 15-20 minutes

**Verification after completion:**
```bash
# Test each component
python3.11 --version
mysql --version
node --version
npm --version
nginx -v
redis-server --version
supervisord --version
```

---

### Step 3: MySQL Database

**Status**: ⏳ PENDING EXECUTION

**What happens:**
- Creates `medicalpromax_db` database
- Creates `medicalpromax_user` with full privileges
- Initializes all 17 tables
- Seeds initial data (specialties, exam levels, subspecialties)
- Sets up indexes and constraints

**Execute:**
```bash
sudo bash /path/to/init-database.sh

# Provide:
- MySQL Root Password
- Database User Password (save this!)
```

**Verification:**
```bash
# List all tables
mysql -u medicalpromax_user -p medicalpromax_db -e "SHOW TABLES;"

# Expected: 17 tables
# ✓ specialties
# ✓ exam_levels
# ✓ subspecialties
# ✓ courses
# ✓ chapters
# ✓ topics
# ✓ questions
# ✓ question_options
# ✓ question_explanations
# ✓ exam_types_classification
# ✓ exams
# ✓ exam_questions
# ✓ users
# ✓ user_exam_attempts
# ✓ user_answers
# ✓ user_study_progress
# ✓ user_topic_question_attempts
```

---

### Step 4: Django Backend

**Status**: ⏳ PENDING EXECUTION

**What happens:**
- Creates Python virtual environment
- Installs Django 4.2+ and dependencies
- Runs database migrations
- Collects static files
- Creates superuser (interactive)
- Configures Gunicorn + Supervisor

**Execute:**
```bash
sudo bash /var/www/medicalpromax/scripts/setup-backend.sh

# Provide when prompted:
- Django Superuser Email
- Superuser First Name
- Superuser Last Name
- Superuser Password
```

**Update environment variables:**
```bash
sudo nano /var/www/medicalpromax/backend/.env.production

# Update:
DATABASE_PASSWORD=<from_step_3>
SECRET_KEY=<generate_new>
EMAIL_HOST_USER=<your_email>
EMAIL_HOST_PASSWORD=<app_password>
```

**Start backend:**
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start medicalpromax-backend

# Verify
sudo supervisorctl status medicalpromax-backend
```

**Test backend:**
```bash
curl http://localhost:8000/api/specialties/
# Should return JSON: [{"id": 1, "slug": "medicine", ...}]
```

---

### Step 5: Next.js Frontend

**Status**: ⏳ PENDING EXECUTION

**What happens:**
- Copies frontend code to `/var/www/medicalpromax/frontend`
- Installs npm dependencies
- Builds optimized production bundle
- Configures Supervisor to manage process

**Execute:**
```bash
sudo bash /var/www/medicalpromax/scripts/setup-frontend.sh
# Automated, no input needed

# Start frontend
sudo supervisorctl restart medicalpromax-frontend
sudo supervisorctl status medicalpromax-frontend
```

**Test frontend:**
```bash
curl http://localhost:3000/
# Should return HTML (Next.js page)
```

---

### Step 6: Nginx Configuration

**Status**: ⏳ PENDING EXECUTION

**What happens:**
- Configures Nginx as reverse proxy
- Routes `/api` to Django backend (port 8000)
- Routes `/` to Next.js frontend (port 3000)
- Serves static files from `/static`
- Serves media files from `/media`
- Sets security headers

**Execute:**
```bash
# Copy Nginx config
sudo cp /var/www/medicalpromax/repo/config/nginx-medicalpromax.conf \
    /etc/nginx/sites-available/medicalpromax

# Enable site
sudo ln -s /etc/nginx/sites-available/medicalpromax \
    /etc/nginx/sites-enabled/medicalpromax

# Disable default
sudo rm /etc/nginx/sites-enabled/default 2>/dev/null || true

# Test configuration
sudo nginx -t
# Expected: syntax is ok, test is successful

# Reload Nginx
sudo systemctl reload nginx
```

**Test Nginx:**
```bash
# From another machine
curl -H "Host: medicalpromax.ir" http://YOUR_VPS_IP

# Or locally
curl http://localhost
```

---

### Step 7: DNS & Domain Configuration

**Status**: ⏳ PENDING EXECUTION

**What needs to be done:**
1. Point `medicalpromax.ir` DNS to VPS IP
2. Use Cloudflare for DNS management (recommended)

**Cloudflare Setup:**
```
1. Login to Cloudflare
2. Add domain: medicalpromax.ir
3. Update nameservers at domain registrar
4. Add DNS record:
   Type: A
   Name: medicalpromax.ir
   Content: YOUR_VPS_IP
   Proxy: DNS only (or Proxied)
5. Wait for DNS propagation (15-30 minutes)
```

**Verify DNS:**
```bash
nslookup medicalpromax.ir
dig medicalpromax.ir

# Should resolve to YOUR_VPS_IP
```

---

### Step 8: SSL/TLS Certificate (Let's Encrypt)

**Status**: ⏳ PENDING EXECUTION

**Prerequisites:**
- Domain DNS must be pointing to VPS (Step 7 complete)
- Nginx must be running
- Port 443 must be accessible

**Execute:**
```bash
sudo certbot --nginx -d medicalpromax.ir -d www.medicalpromax.ir

# Follow prompts:
1. Enter email address
2. Accept terms
3. Choose auto-redirect: Yes (redirect HTTP to HTTPS)
```

**Verification:**
```bash
# Check certificate
sudo certbot certificates

# Test auto-renewal
sudo certbot renew --dry-run

# Visit in browser
https://medicalpromax.ir
# Should show green lock 🔒
```

**Auto-renewal:**
```bash
# Already set by Certbot, runs daily
sudo systemctl start certbot.timer
sudo systemctl enable certbot.timer
```

---

## 🧪 PHASE 3: TESTING & VERIFICATION

### API Testing

**Status**: ⏳ PENDING DEPLOYMENT

**Test endpoints:**

```bash
# 1. Register new user
curl -X POST https://medicalpromax.ir/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@medicalpromax.ir",
    "password": "Test123!@",
    "first_name": "علی",
    "last_name": "محمدی"
  }'

# Expected: 201 Created with tokens

# 2. Login
curl -X POST https://medicalpromax.ir/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@medicalpromax.ir",
    "password": "Test123!@"
  }'

# Expected: 200 OK with access token

# 3. List specialties
curl https://medicalpromax.ir/api/specialties/

# Expected: JSON array of specialties

# 4. List exam levels
curl https://medicalpromax.ir/api/specialties/medicine/levels/

# Expected: JSON with specialty and levels
```

### Frontend Testing

**Status**: ⏳ PENDING DEPLOYMENT

**Test in browser:**

```
1. Visit https://medicalpromax.ir
   ✓ Should see Persian/RTL layout
   ✓ Should see 3 specialty cards (پزشکی, دندانپزشکی, داروسازی)
   ✓ Should be responsive (mobile + desktop)
   ✓ No console errors

2. Click on specialty (e.g., پزشکی)
   ✓ Should navigate to exam levels page
   ✓ Should show exam level options

3. Click on exam level
   ✓ Should show dashboard with 2 options:
     - Exams (سوالات آزمون)
     - Study Mode (مطالعه)

4. Click on "Exams"
   ✓ Should list available exams (if any)

5. Click on "Study Mode"
   ✓ Should show courses/chapters/topics

6. Click on topic
   ✓ Should show topic summary + 15 questions
   ✓ Should be able to answer questions
   ✓ Should see correct/incorrect feedback

7. Test authentication
   ✓ Register new account
   ✓ Login with account
   ✓ Should see user dashboard
   ✓ Should track progress
```

### Performance Testing

**Status**: ⏳ PENDING DEPLOYMENT

```bash
# Backend response time
time curl https://medicalpromax.ir/api/specialties/

# Frontend page load
# Open browser DevTools → Network tab
# Expected: Load time < 3 seconds

# Database query performance
# SSH into VPS
# Check slow query log
sudo tail -100 /var/log/mysql/slow.log
```

---

## 📊 PHASE 4: MONITORING & MAINTENANCE

### Service Status Commands

**Status**: ⏳ READY AFTER DEPLOYMENT

```bash
# Check all services
sudo supervisorctl status

# View specific logs
tail -f /var/log/medicalpromax/backend-access.log
tail -f /var/log/medicalpromax/frontend-stdout.log
tail -f /var/log/nginx/medicalpromax-access.log

# System resources
htop

# Disk space
df -h

# MySQL status
sudo systemctl status mysql
```

### Backup & Recovery

**Status**: ⏳ READY AFTER DEPLOYMENT

```bash
# Backup database
mysqldump -u medicalpromax_user -p medicalpromax_db | \
  gzip > /var/www/medicalpromax/backups/backup_$(date +%Y%m%d).sql.gz

# List backups
ls -lah /var/www/medicalpromax/backups/

# Restore backup
gunzip < backup_file.sql.gz | \
  mysql -u medicalpromax_user -p medicalpromax_db

# Setup daily backups
sudo crontab -e
# Add: 0 2 * * * /var/www/medicalpromax/scripts/backup-db.sh
```

### Updates & Deployment

**Status**: ⏳ READY AFTER DEPLOYMENT

```bash
# Pull latest code
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
```

---

## 🎯 Deployment Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| System Setup | 20 min | ⏳ Pending |
| Database Init | 5 min | ⏳ Pending |
| Backend Setup | 15 min | ⏳ Pending |
| Frontend Setup | 10 min | ⏳ Pending |
| Nginx Config | 5 min | ⏳ Pending |
| DNS Setup | 30 min | ⏳ Pending |
| SSL Setup | 5 min | ⏳ Pending |
| Testing | 20 min | ⏳ Pending |
| **TOTAL** | **110 min** | ⏳ Pending |

---

## 📝 Configuration Checklist

- [ ] VPS IP and SSH credentials ready
- [ ] Domain medicalpromax.ir purchased
- [ ] GitHub repository accessible
- [ ] MySQL root password saved
- [ ] Database user password saved
- [ ] Django SECRET_KEY generated
- [ ] Email credentials configured
- [ ] Nginx configuration reviewed
- [ ] SSL certificate ready (Let's Encrypt)
- [ ] Firewall rules configured
- [ ] Backup strategy in place
- [ ] Monitoring alerts setup
- [ ] Team access configured

---

## 🆘 Troubleshooting Reference

### Backend not starting
```bash
sudo supervisorctl start medicalpromax-backend
sudo supervisorctl tail -f medicalpromax-backend stderr
```

### Frontend not loading
```bash
sudo supervisorctl tail -f medicalpromax-frontend stdout
```

### Database connection error
```bash
# Test connection
mysql -u medicalpromax_user -p -h localhost medicalpromax_db

# Check credentials in .env
cat /var/www/medicalpromax/backend/.env.production | grep DATABASE
```

### Nginx 502 Bad Gateway
```bash
# Check if backend is running
curl http://localhost:8000/
curl http://localhost:3000/

# Check Nginx config
sudo nginx -t
```

### SSL certificate issues
```bash
# Check certificate status
sudo certbot certificates

# Renew manually
sudo certbot renew --force-renewal

# Check renewal logs
sudo journalctl -u certbot -n 50
```

---

## 📞 Next Steps

1. **Provide VPS Details** - Reply with your VPS information
2. **Execute Setup Scripts** - Follow VPS_SETUP_GUIDE.md
3. **Configure Domain** - Point DNS to VPS IP
4. **Request SSL** - Certbot will auto-install certificate
5. **Test Platform** - Verify all endpoints working
6. **Launch** - Platform live! 🎉

---

**Ready to deploy? Let's build! 🚀**

*Document Version: 1.0*
*Last Updated: February 2026*
