# 🚀 Medical Promax - VPS Installation Guide (Customized)

> تطبیق‌شده برای VPS کم‌منابع: Ubuntu 22.04 - 1 CPU - 1.9GB RAM

---

## 📋 فهرست مطالب

1. [شروع سریع](#شروع-سریع)
2. [پیش‌نیازها](#پیش‌نیازها)
3. [تغییرات اصلی](#تغییرات-اصلی)
4. [راهنمای نصب](#راهنمای-نصب)
5. [بررسی و پایش](#بررسی-و-پایش)
6. [بعد از نصب](#بعد-از-نصب)

---

## ⚡ شروع سریع

### خط 1 (اسکریپت خودکار):
```bash
# 1. Connect to VPS
ssh root@185.19.201.115

# 2. Download and run
cd /var/www
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
cd medicalpromaxproject

# 3. Create swap file first (highly recommended)
sudo bash scripts/setup-swap.sh

# 4. Run complete setup
sudo bash VPS_QUICK_START.sh
```

### خط 2 (دستی):
```bash
# Run each script manually
sudo bash scripts/setup-vps.sh
sudo bash scripts/init-database.sh
sudo bash scripts/setup-backend.sh
sudo bash scripts/setup-frontend.sh
```

---

## 📦 پیش‌نیازها

### سیستم موجود (✓ تایید شده):
- ✅ Ubuntu 22.04.5 LTS
- ✅ Python 3.10.12
- ✅ Node.js v12.22.9
- ✅ Nginx 1.18
- ✅ MySQL 10.6 (MariaDB)
- ✅ Git 2.34.1

### پیش‌نیازهای نصب:
```bash
# تمام بسته‌های الزامی توسط setup-vps.sh نصب می‌شود
# اما می‌توانید قبلاً چک کنید:

python3 --version
node --version
git --version
```

### توصیه‌های بهتر (optional):
```bash
# اگر npm نصب نشده:
sudo apt install npm

# اگر redis نیاز است:
sudo apt install redis-server
```

---

## 🔧 تغییرات اصلی

### مقایسه Setup Scripts:

| سرویس | Original | Customized | دلیل |
|-------|----------|-----------|------|
| **Python** | 3.11 | 3.10 ✓ | موجود در سیستم |
| **Node.js** | 20.x | 12.x ✓ | موجود در سیستم |
| **npm** | فرض شده | نصب شود ✓ | موجود نیست |
| **Redis** | بلی | خیر ✓ | کم‌حافظه |
| **Gunicorn Workers** | 4 | 2 ✓ | 1 CPU فقط |
| **Node Heap** | Unlimited | 256MB ✓ | محدودیت حافظه |

### فایل‌های جدید:
```
✓ VPS_SETUP_CUSTOMIZATIONS.md  - مستندات تفصیلی
✓ VPS_CHANGES_SUMMARY.md       - خلاصه تغییرات
✓ VPS_QUICK_START.sh           - اسکریپت خودکار
✓ scripts/setup-swap.sh        - ایجاد Swap file
```

---

## 🛠️ راهنمای نصب

### مرحله 0: آماده‌سازی (اختیاری اما توصیه شده)

```bash
# SSH به VPS
ssh root@185.19.201.115

# بررسی منابع موجود
free -h
df -h
cat /root/vps-report-*.txt

# ایجاد Swap (2GB) - برای کم‌حافظه
sudo bash /var/www/medicalpromaxproject/scripts/setup-swap.sh
```

### مرحله 1: Clone Repository

```bash
mkdir -p /var/www
cd /var/www

# Clone
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
cd medicalpromaxproject
```

### مرحله 2: اسکریپت اصلی (یکی از دو روش)

#### روش A: خودکار (توصیه شده)
```bash
sudo bash VPS_QUICK_START.sh

# Script will:
# ✓ Check prerequisites
# ✓ Create swap if needed
# ✓ Run setup-vps.sh
# ✓ Run init-database.sh
# ✓ Run setup-backend.sh
# ✓ Run setup-frontend.sh
# ✓ Configure Nginx
# ✓ Optional: Setup SSL
```

#### روش B: دستی (برای آموزش)
```bash
# 1. VPS System Setup (~20 min)
sudo bash scripts/setup-vps.sh

# 2. Database Init (~5 min)
sudo bash scripts/init-database.sh

# 3. Django Backend (~15 min)
sudo bash scripts/setup-backend.sh

# 4. Next.js Frontend (~15 min)
# ⚠️ Takes longer on 1 CPU, be patient!
sudo bash scripts/setup-frontend.sh

# 5. Nginx Config
sudo cp config/nginx-medicalpromax.conf /etc/nginx/sites-available/medicalpromax
sudo systemctl reload nginx

# 6. SSL Certificate
sudo certbot --nginx -d medicalpromax.ir
```

---

## 📊 بررسی و پایش

### حالت سرویس‌ها:
```bash
# وضعیت کلی
sudo supervisorctl status

# وضعیت اختصاصی
sudo supervisorctl status medicalpromax-backend
sudo supervisorctl status medicalpromax-frontend

# Nginx
sudo systemctl status nginx

# MySQL
sudo systemctl status mysql
```

### مانیتورینگ منابع:
```bash
# حافظه
free -h
swapon --show

# CPU
top -b -n 1 | head -20

# Disk
df -h /var/www

# Processes
ps aux --sort=-%mem | head
```

### Log Files:
```bash
# Backend Django
tail -f /var/log/medicalpromax/backend-error.log
tail -f /var/log/medicalpromax/backend-access.log

# Frontend Next.js
tail -f /var/log/medicalpromax/frontend-stdout.log
tail -f /var/log/medicalpromax/frontend-stderr.log

# Nginx
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log

# System
journalctl -u supervisor -f
```

### Test API:
```bash
# Backend API
curl -v http://127.0.0.1:8000/admin/
curl -v http://127.0.0.1:8000/api/

# Frontend
curl -v http://127.0.0.1:3000/

# Nginx (via domain)
curl -v http://medicalpromax.ir/
```

---

## 📝 بعد از نصب

### 1. ⚙️ تنظیمات الزامی

```bash
# Backend: .env file
sudo nano /var/www/medicalpromax/backend/.env.production

# محتوا را به‌روزرسانی کنید:
DATABASE_PASSWORD=your_password_here
SECRET_KEY=generate_new_key_here  # django-insecure-...
JWT_SECRET_KEY=another_random_key_here
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=app-password-here
```

### 2. 🔑 تولید Secret Keys

```bash
# Django SECRET_KEY
python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# JWT SECRET_KEY (هر رشته‌ای تصادفی)
openssl rand -hex 32
```

### 3. 📧 تنظیم Email

برای Gmail:
```
EMAIL_BACKEND = django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST = smtp.gmail.com
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = your-email@gmail.com
EMAIL_HOST_PASSWORD = your-app-password (not regular password)
```

### 4. 🔒 تنظیم HTTPS

```bash
# SSL Certificate
sudo certbot --nginx -d medicalpromax.ir -d www.medicalpromax.ir

# Renew automatically
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Test renewal
sudo certbot renew --dry-run
```

### 5. 🔄 Restart Services

```bash
# بعد از ویرایش فایل‌ها
sudo supervisorctl restart medicalpromax-backend
sudo supervisorctl restart medicalpromax-frontend

# یا همه
sudo supervisorctl restart all
```

---

## ⚠️ مشکلات شایع و حل‌های سریع

### ❌ "Out of Memory" Error

```bash
# بررسی
free -h
swapon --show

# حل:
sudo bash /var/www/medicalpromaxproject/scripts/setup-swap.sh

# یا دستی
sudo swapoff /swapfile
sudo rm /swapfile
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

### ❌ "npm install" Stuck/Timeout

```bash
# npm cache clear
npm cache clean --force

# retry with registry
npm config set registry https://registry.npmjs.org/
npm install --prefer-offline

# یا with memory limit
NODE_OPTIONS="--max-old-space-size=512" npm install
```

### ❌ "Node.js Build" Fails

```bash
# Increase memory
NODE_OPTIONS="--max-old-space-size=512" npm run build

# یا افزایش swap
sudo bash /var/www/medicalpromaxproject/scripts/setup-swap.sh
```

### ❌ "Gunicorn Workers" Crashed

```bash
# بررسی
sudo supervisorctl status
tail -f /var/log/medicalpromax/backend-error.log

# restart
sudo supervisorctl restart medicalpromax-backend

# اگر همچنان fail شود:
# کاهش workers از 2 به 1
sudo nano /etc/supervisor/conf.d/medicalpromax-backend.conf
# --workers 2 → --workers 1
sudo supervisorctl reread && sudo supervisorctl update
```

### ❌ "Port Already in Use"

```bash
# پیدا کردن process
lsof -i :8000
lsof -i :3000
lsof -i :80

# Kill
kill -9 <PID>

# یا restart supervisor
sudo systemctl restart supervisor
```

---

## 📚 منابع مفید

- [مستندات Django](https://docs.djangoproject.com/)
- [مستندات Next.js](https://nextjs.org/docs/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Supervisor Documentation](http://supervisord.org/)
- [Let's Encrypt](https://letsencrypt.org/)

---

## 🆘 نیاز کمک؟

اگر مشکل پیدا کردید:

1. **Log Files را بررسی کنید:**
   ```bash
   tail -f /var/log/medicalpromax/*.log
   ```

2. **منابع را چک کنید:**
   ```bash
   free -h && df -h && top -b -n 1
   ```

3. **GitHub Issue ایجاد کنید** با:
   - Error message کامل
   - Log files
   - Output از setup-swap.sh
   - VPS specifications

---

## ✅ Checklist نهایی

- [ ] Repository cloned
- [ ] Swap file created (if needed)
- [ ] setup-vps.sh اجرا شده
- [ ] Database initialized
- [ ] Backend setup complete
- [ ] Frontend setup complete
- [ ] Nginx configured
- [ ] SSL certificate active
- [ ] All services running (supervisorctl status)
- [ ] API responding (curl http://127.0.0.1:8000/)
- [ ] Frontend accessible (curl http://127.0.0.1:3000/)

---

**نسخه:** 1.0 (فوریه 2025)  
**تطبیق شده برای:** srv8795291092 (185.19.201.115)  
**OS:** Ubuntu 22.04.5 LTS - 1 CPU - 1.9GB RAM  
**مشخصات:** Node v12, Python 3.10, MySQL 10.6, Nginx 1.18
