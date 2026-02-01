# 🎯 Medical Promax - VPS Customization Complete

> **تطبیق برای VPS کم‌منابع شما انجام شد** ✅

---

## 📌 سریع ترین شروع (30 ثانیه)

```bash
cd /var/www
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
cd medicalpromaxproject
sudo bash VPS_QUICK_START.sh
```

**تمام شود!** 🚀 (زمان: ~60 دقیقه)

---

## 📋 چه تغییر داده شد؟

### ✅ 4 اسکریپت اصلی تطبیق یافت
- `scripts/setup-vps.sh` - Python 3.10 + npm + بدون Redis
- `scripts/setup-backend.sh` - 2 workers + FileCache + optimize pip
- `scripts/setup-frontend.sh` - Node memory limit + npm config
- `scripts/init-database.sh` - بدون تغییر (OK)

### ✅ 7 فایل جدید ایجاد شد
1. **اسکریپت‌ها**:
   - `VPS_QUICK_START.sh` - نصب خودکار کل سیستم
   - `scripts/setup-swap.sh` - ایجاد Swap (الزامی برای 1.9GB)
   - `scripts/verify-installation.sh` - تأیید پس از نصب

2. **مستندات**:
   - `README_CUSTOMIZATION_FA.md` - این فایل (خلاصه فارسی)
   - `VPS_INSTALLATION_GUIDE_FA.md` - راهنمای کامل (فارسی)
   - `VPS_SETUP_CUSTOMIZATIONS.md` - جزئیات تطبیقات
   - `VPS_CHANGES_SUMMARY.md` - مقایسه‌ها و جزئیات
   - `CUSTOMIZATION_COMPLETE.md` - لیست تکنیکال کامل

---

## 🚀 دو روش نصب

### روش 1: خودکار (توصیه شده)
```bash
sudo bash VPS_QUICK_START.sh
# Script خود بخود:
# ✓ Swap ایجاد می‌کند
# ✓ تمام 4 setup script را اجرا می‌کند
# ✓ Nginx configure می‌کند
# ✓ SSL setup می‌کند (optional)
```

### روش 2: دستی (فهم بهتر)
```bash
# 1. ایجاد Swap (اختیاری اما توصیه شده)
sudo bash scripts/setup-swap.sh

# 2. نصب ترتیبی
sudo bash scripts/setup-vps.sh
sudo bash scripts/init-database.sh
sudo bash scripts/setup-backend.sh
sudo bash scripts/setup-frontend.sh

# 3. Nginx و SSL
sudo cp config/nginx-medicalpromax.conf /etc/nginx/sites-available/
sudo systemctl reload nginx
sudo certbot --nginx -d medicalpromax.ir
```

---

## 🔍 بعد از نصب

### تأیید شده
```bash
sudo bash scripts/verify-installation.sh
```

### دستی
```bash
# وضعیت سرویس‌ها
sudo supervisorctl status

# API test
curl http://127.0.0.1:8000/
curl http://127.0.0.1:3000/

# منابع
free -h
df -h /var/www

# Logs
tail -f /var/log/medicalpromax/backend-error.log
```

---

## 📊 مقایسه (Original vs Customized)

| مورد | Original | Customized | دلیل |
|------|---------|-----------|------|
| **Python** | 3.11 ❌ | 3.10 ✅ | موجود در VPS |
| **Node.js** | 20.x ❌ | 12.x ✅ | موجود در VPS |
| **npm** | - ❌ | نصب ✅ | نیاز |
| **Redis** | بلی ❌ | خیر ✅ | کم حافظه |
| **Gunicorn Workers** | 4 ❌ | 2 ✅ | 1 CPU |
| **Node Heap** | ∞ ❌ | 256MB ✅ | RAM limit |
| **Django Cache** | Redis ❌ | FileCache ✅ | بدون Redis |

---

## ⚡ بهینه‌سازی‌های اصلی

### 1. Swap File (هسته) 🔥
```bash
# VPS شما: 100MB RAM آزاد
# Swap: +2GB فایل
# نتیجه: 1.9GB + 2GB = 3.9GB موثر
```

### 2. Django Backend
```
Cache: FileBasedCache (بدون Redis)
Workers: 2 (برای 1 CPU)
Memory per worker: ~200MB
```

### 3. Next.js Frontend
```
Node memory: 256MB limit
npm config: legacy-peer-deps
```

---

## 📁 فایل‌های کلیدی

### نصب
- 🔧 `VPS_QUICK_START.sh` ← **اینجا شروع کنید**
- 🔧 `scripts/setup-swap.sh`
- 🔧 `scripts/verify-installation.sh`

### مستندات (فارسی)
- 📄 `README_CUSTOMIZATION_FA.md` ← **این فایل (خلاصه)**
- 📄 `VPS_INSTALLATION_GUIDE_FA.md` ← **راهنمای کامل**
- 📄 `VPS_SETUP_CUSTOMIZATIONS.md`

### مستندات (انگلیسی)
- 📄 `VPS_CHANGES_SUMMARY.md`
- 📄 `CUSTOMIZATION_COMPLETE.md`

---

## ⚠️ نکات مهم

### حافظه (Most Important)
```
VPS شما: 1.9 GB RAM
موجود: 100 MB آزاد
مورد نیاز: +2 GB Swap

دستور Swap:
sudo bash scripts/setup-swap.sh
```

### زمان نصب
```
کل: ~60 دقیقه
- VPS setup: 20 دقیقه
- Database: 5 دقیقه
- Backend: 15 دقیقه
- Frontend: 20 دقیقه (پردازندگی کند روی 1 CPU)
```

### هیچ مشکل نباید باشد
- ✅ Setup scripts compatible
- ✅ Automatic swap creation
- ✅ Memory optimization
- ✅ Low CPU handling

---

## 🚨 اگر مشکل پیدا کردید

### "Out of Memory"
```bash
# حل: Swap بزرگ‌تر
sudo bash scripts/setup-swap.sh
# یا دستی:
fallocate -l 4G /swapfile
swapon /swapfile
```

### "npm install" Timeout
```bash
NODE_OPTIONS="--max-old-space-size=512" npm install
```

### "Gunicorn Crash"
```bash
# workers کاهش دهید: 2 → 1
sudo nano /etc/supervisor/conf.d/medicalpromax-backend.conf
```

---

## 📚 راهنمای کامل

برای جزئیات بیشتر:

- **فارسی**: `VPS_INSTALLATION_GUIDE_FA.md`
- **انگلیسی**: مستندات در GitHub

---

## ✅ Checklist

قبل از نصب:
- [ ] SSH به VPS
- [ ] Disk space کافی: `df -h`
- [ ] Internet connection
- [ ] Root access

بعد از نصب:
- [ ] `supervisorctl status` - همه RUNNING
- [ ] Ports: 8000, 3000, 80, 443 active
- [ ] SSL certificate active
- [ ] Logs clean: no errors

---

## 🎯 نتیجه

✅ **تمام تطبیقات برای VPS شما انجام شد**

**شما آماده نصب هستید!** 🚀

```bash
cd /var/www
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
cd medicalpromaxproject
sudo bash VPS_QUICK_START.sh
```

---

**Created**: February 1, 2025  
**For**: srv8795291092 (185.19.201.115)  
**OS**: Ubuntu 22.04.5 LTS - 1 CPU - 1.9GB RAM  
**Status**: ✅ Ready for deployment
