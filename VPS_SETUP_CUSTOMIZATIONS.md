# تطبیقات VPS برای Medical Promax

## 📋 تغییرات انجام شده

تمام setup scripts برای VPS شما (Ubuntu 22.04.5 LTS - 1 CPU, 1.9GB RAM) بهینه‌سازی شده‌اند.

### 🔧 تغییرات اصلی:

#### 1. **setup-vps.sh** - تنظیمات سیستم

- ✅ **Python**: از Python 3.10 موجود استفاده (به جای 3.11)
- ✅ **Node.js**: npm را از apt نصب می‌کند (چون Node v12 بدون npm است)
- ✅ **Redis**: غیرفعال (برای حفظ حافظه - می‌توانید بعداً نصب کنید)
- ✅ **Supervisor**: Gunicorn را از backend setup نصب می‌کند

#### 2. **setup-backend.sh** - Django Backend

```bash
✅ تغییرات:
- Python 3 عمومی (python3.11 → python3)
- نصب بسته‌های Python با --no-cache-dir (حفظ حافظه)
- Gunicorn workers: 4 → 2 (برای VPS کم‌حافظه)
- Cache backend: Redis → Django FileBasedCache
- max-requests: اضافه شده برای پایداری
```

**پیکربندی .env برای کم‌حافظه:**
```env
# استفاده از file-based caching
CACHE_BACKEND=django.core.cache.backends.filebased.FileBasedCache
CACHE_LOCATION=/var/www/medicalpromax/cache
```

#### 3. **setup-frontend.sh** - Next.js Frontend

```bash
✅ تغییرات:
- npm install با NODE_OPTIONS="--max-old-space-size=256"
- npm build با محدودیت حافظه (256MB)
- legacy-peer-deps فعال (برای compatibility)
- npm start → next start (مستقیم‌تر)
```

**متغیرهای محیط بهینه‌شده:**
```bash
NODE_OPTIONS="--max-old-space-size=256"
```

---

## 🚀 دستورات نهایی برای نصب

### مرحله 1: Clone Repository
```bash
cd /var/www
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git medicalpromaxproject
cd medicalpromaxproject
```

### مرحله 2: اجرای Setup Scripts (توالی صحیح)
```bash
# 1. تنظیمات سیستم (20 دقیقه)
sudo bash scripts/setup-vps.sh

# 2. تهیه‌کننده Database (5 دقیقه)
sudo bash scripts/init-database.sh

# 3. Backend Django (15 دقیقه)
sudo bash scripts/setup-backend.sh

# 4. Frontend Next.js (10-15 دقیقه - برای پردازندگی کند VPS)
sudo bash scripts/setup-frontend.sh

# 5. تنظیمات Nginx
sudo cp config/nginx-medicalpromax.conf /etc/nginx/sites-available/medicalpromax
sudo systemctl reload nginx

# 6. SSL Certificate
sudo certbot --nginx -d medicalpromax.ir
```

---

## ⚠️ نکات مهم برای VPS کم‌حافظه

### 1. **حداکثر حافظه رام**
```bash
# موجود: 100MB رام آزاد
# مورد نیاز: ~600MB برای تمام سرویس‌ها

# راه حل: Swap فایل ایجاد کنید
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# برای permanent سازی:
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 2. **پایش حافظه**
```bash
# پایش استفاده حافظه
free -h

# Swap status
swapon --show

# Process memory
ps aux --sort=-%mem | head -20
```

### 3. **بهینه‌سازی Gunicorn (2 workers)**
```bash
# برای 1 CPU: 2 workers مناسب است
# Formula: (2 × CPU cores) + 1 = (2 × 1) + 1 = 3
# اما برای کم‌حافظه: 2 کافی است
```

### 4. **پایش سرویس‌ها**
```bash
# Django Backend Status
sudo supervisorctl status medicalpromax-backend

# Frontend Status
sudo supervisorctl status medicalpromax-frontend

# Nginx Status
sudo systemctl status nginx

# MySQL Status
sudo systemctl status mysql

# Log files
tail -f /var/log/medicalpromax/backend-error.log
tail -f /var/log/medicalpromax/frontend-stdout.log
```

---

## 🔍 Troubleshooting

### خطای Memory (Out of Memory):
```bash
# اگر سرویس‌ها crash کنند:
sudo swapon --show  # بررسی swap
sudo systemctl restart supervisor  # restart supervisor
```

### Node.js Build Fail:
```bash
# اگر build قطع شود:
NODE_OPTIONS="--max-old-space-size=512" npm run build
# یا swap size را افزایش دهید
```

### Gunicorn Workers Stuck:
```bash
# restart backend
sudo supervisorctl restart medicalpromax-backend

# یا manual:
ps aux | grep gunicorn
kill -9 <pid>  # کافی نیست، supervisor restart کند
```

---

## 📊 مقارنه: Before vs After

| بخش | Original | Customized |
|------|----------|-----------|
| Python | 3.11 | 3.10 ✓ |
| Node.js | 20.x | 12.x ✓ |
| npm | Required | نصب شده ✓ |
| Redis | بلی | خیر (File Cache) ✓ |
| Gunicorn Workers | 4 | 2 ✓ |
| Node Memory Limit | Unlimited | 256MB ✓ |
| Frontend Server | npm start | next start ✓ |

---

## 📝 پس از نصب

### تست کنید:
```bash
# Test Backend
curl http://127.0.0.1:8000/health/

# Test Frontend
curl http://127.0.0.1:3000/

# Test Nginx
curl http://medicalpromax.ir/

# Test HTTPS
curl https://medicalpromax.ir/
```

### نگهداری منظم:
```bash
# Backup Database روزانه
mysqldump -u medicalpromax_user -p medicalpromax_db > /backups/db.sql

# پاک‌سازی cache
rm -rf /var/www/medicalpromax/cache/*

# Restart services
sudo supervisorctl restart all
```

---

## 🆘 نیاز به کمک؟

اگر مشکل داشتید:
1. فایل log را بررسی کنید
2. `free -h` را اجرا کنید
3. `sudo supervisorctl status` را بررسی کنید

**موارد مهم برای GitHub issue:**
- Error message کامل
- Output از `cat /root/vps-report-*`
- Log files relevant
