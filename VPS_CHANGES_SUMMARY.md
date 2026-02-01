# خلاصه تطبیقات برای VPS کم‌منابع

## 🎯 مشخصات VPS شما
- **OS**: Ubuntu 22.04.5 LTS
- **CPU**: 1 Core
- **RAM**: 1.9 GB (پیشنهاد: Swap 2GB اضافه کنید)
- **Disk**: 25 GB
- **Node**: v12.22.9 (بدون npm)
- **Python**: 3.10.12
- **MySQL**: 10.6.23-MariaDB

---

## ✅ تغییرات انجام شده

### 1️⃣ `scripts/setup-vps.sh`
```diff
- Python 3.11 → Python 3.10 ✓
- Node.js 20.x → Node.js 12.x + npm نصب ✓
- Redis نصب → Redis غیرفعال ✓
- Gunicorn workers 4 → 2 ✓
```

### 2️⃣ `scripts/setup-backend.sh`
```diff
- python3.11 -m venv → python3 -m venv ✓
- pip install (یکجا) → pip install یکی یکی + --no-cache-dir ✓
- Cache: Redis → Django FileBasedCache ✓
- Gunicorn workers: 4 → 2 ✓
- max-requests اضافه شد ✓
```

### 3️⃣ `scripts/setup-frontend.sh`
```diff
- npm install → npm install + NODE_OPTIONS="--max-old-space-size=256" ✓
- npm run build → npm run build + NODE_OPTIONS حافظه محدود ✓
- npm start → next start (مستقیم) ✓
```

### 4️⃣ فایل‌های جدید
- ✅ `VPS_SETUP_CUSTOMIZATIONS.md` - راهنمای کامل تطبیقات
- ✅ `VPS_QUICK_START.sh` - اسکریپت خودکار برای کل پروسه

---

## 🚀 نحوه استفاده

### روش 1: اسکریپت خودکار (توصیه شده)
```bash
cd /var/www
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
cd medicalpromaxproject

# با permissions
sudo bash VPS_QUICK_START.sh
```

### روش 2: دستی (مرحله به مرحله)
```bash
cd /var/www/medicalpromaxproject

# 1. VPS Setup
sudo bash scripts/setup-vps.sh

# 2. Database
sudo bash scripts/init-database.sh

# 3. Backend
sudo bash scripts/setup-backend.sh

# 4. Frontend
sudo bash scripts/setup-frontend.sh

# 5. Nginx
sudo cp config/nginx-medicalpromax.conf /etc/nginx/sites-available/
sudo systemctl reload nginx

# 6. SSL
sudo certbot --nginx -d medicalpromax.ir
```

---

## ⚡ بهینه‌سازی‌های کلیدی

### حافظه (Memory)
```bash
# Swap File (برای جبران کمی RAM)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# نتیجه: 1.9GB + 2GB Swap = 3.9GB موثر
```

### Django Backend
```python
# Cache: File-based (بدون Redis)
CACHE_BACKEND = 'django.core.cache.backends.filebased.FileBasedCache'
CACHE_LOCATION = '/var/www/medicalpromax/cache'

# Gunicorn: 2 workers (برای 1 CPU)
# Formula: (2 × cores) + 1 = 3, اما 2 کافی برای کم‌حافظه
```

### Next.js Frontend
```bash
# Node.js Memory Limit
NODE_OPTIONS="--max-old-space-size=256"

# npm config
npm config set legacy-peer-deps true
npm config set prefer-offline true
```

---

## 🔍 پایش و بررسی

```bash
# وضعیت تمام سرویس‌ها
sudo supervisorctl status

# استفاده حافظه
free -h && swapon --show

# استفاده CPU
top -b -n 1 | head -20

# Disk usage
df -h

# Service logs
tail -f /var/log/medicalpromax/backend-error.log
tail -f /var/log/medicalpromax/frontend-stdout.log
```

---

## ⚠️ مشکلات احتمالی و راه حل

| مشکل | علت | راه حل |
|------|------|---------|
| Out of Memory | کمی RAM | `swapon --show` و بزرگ‌تر کنید |
| Node.js Build Fail | حافظه کافی نیست | `NODE_OPTIONS="--max-old-space-size=512"` |
| Gunicorn Crash | حافظه غیر کافی | workers را از 2 به 1 کاهش دهید |
| npm install Stuck | network timeout | `npm config set registry https://registry.npmjs.org/` |

---

## 📊 مقایسه نسخه‌ها

| پارامتر | Original | Customized |
|---------|----------|-----------|
| Python Version | 3.11 | 3.10 |
| Node.js Version | 20.x | 12.x |
| npm | ✓ Required | ✓ نصب شده |
| Redis | ✓ | ✗ |
| Gunicorn Workers | 4 | 2 |
| Max Node Heap | Unlimited | 256MB |
| Cache System | Redis | FileSystem |
| Estimated RAM | ~1.8GB | ~900MB |

---

## 📝 شرایط ضمانتی

✅ **تضمین شده برای:**
- Ubuntu 22.04 LTS
- 1 CPU Core
- 1.9 GB RAM + 2GB Swap

⚠️ **توصیه‌ها:**
- برای production بهتر است 2GB+ RAM داشته باشید
- Redis را فقط اگر RAM < 500MB نیاز نیست
- Regular backups ضروری است

---

## 🎓 منابع و مستندات

- [Django FileBasedCache](https://docs.djangoproject.com/en/4.2/topics/cache/#filesystem-caching)
- [Gunicorn Workers](https://docs.gunicorn.org/en/stable/settings.html#workers)
- [Next.js Production](https://nextjs.org/docs/deployment)
- [Node.js Memory Limits](https://nodejs.org/en/docs/guides/nodejs-performance/)

---

## ✉️ پشتیبانی

اگر مشکل پیدا کردید:
1. Log files را بررسی کنید
2. `free -h` را اجرا کنید
3. GitHub issue ایجاد کنید با:
   - Error message کامل
   - Output logs
   - System info

---

**آخرین به‌روزرسانی:** 1 فوریه 2025
**تطبیق شده برای:** srv8795291092 (185.19.201.115)
