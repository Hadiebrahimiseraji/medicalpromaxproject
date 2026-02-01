# 🎯 خلاصه تطبیقات - Medical Promax VPS

**تاریخ**: 1 فوریه 2025  
**برای**: srv8795291092 (185.19.201.115)  
**سیستم عامل**: Ubuntu 22.04.5 LTS  
**منابع**: 1 CPU - 1.9GB RAM - 25GB Disk

---

## ✅ کاری که انجام شد

### 1. 📝 4 فایل اسکریپت اصلی تطبیق یافت

#### `scripts/setup-vps.sh`
- ✅ Python 3.10 (بجای 3.11)
- ✅ npm نصب اضافی (Node v12 بدون npm بود)
- ✅ Redis غیرفعال (حفظ حافظه)
- ✅ فقط Supervisor (Gunicorn بعداً)

#### `scripts/setup-backend.sh`
- ✅ Python 3 عمومی (نه 3.11)
- ✅ نصب بسته‌ها یکی یکی + `--no-cache-dir`
- ✅ Cache: FileBasedCache (بجای Redis)
- ✅ Gunicorn: 2 workers (بجای 4)

#### `scripts/setup-frontend.sh`
- ✅ npm install با محدودیت حافظه (256MB)
- ✅ npm build بهینه‌شده
- ✅ Next.js direct start (بدون npm start)

#### `scripts/init-database.sh`
- ✅ بدون تغییر (متوافق)

---

### 2. 📄 7 فایل جدید ایجاد شد

| فایل | نوع | هدف |
|------|------|------|
| `VPS_QUICK_START.sh` | اسکریپت | نصب خودکار کل سیستم |
| `scripts/setup-swap.sh` | اسکریپت | ایجاد Swap فایل |
| `scripts/verify-installation.sh` | اسکریپت | تأیید پس از نصب |
| `VPS_INSTALLATION_GUIDE_FA.md` | مستندات | راهنمای کامل فارسی |
| `VPS_SETUP_CUSTOMIZATIONS.md` | مستندات | جزئیات تطبیقات |
| `VPS_CHANGES_SUMMARY.md` | مستندات | خلاصه تغییرات |
| `CUSTOMIZATION_COMPLETE.md` | مستندات | لیست کامل تغییرات |

---

## 🚀 نحوه استفاده (سریع)

### گزینه 1: نصب خودکار (توصیه شده - 60 دقیقه)
```bash
# 1. SSH به VPS
ssh root@185.19.201.115

# 2. Clone و Setup
cd /var/www
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
cd medicalpromaxproject

# 3. اجرای اسکریپت خودکار
sudo bash VPS_QUICK_START.sh
```

### گزینه 2: مرحله به مرحله (فهم بهتر)
```bash
cd /var/www/medicalpromaxproject

# ایجاد Swap (اختیاری اما بسیار توصیه شده)
sudo bash scripts/setup-swap.sh

# اجرای setup scripts
sudo bash scripts/setup-vps.sh          # 20 دقیقه
sudo bash scripts/init-database.sh      # 5 دقیقه
sudo bash scripts/setup-backend.sh      # 15 دقیقه
sudo bash scripts/setup-frontend.sh     # 15 دقیقه (پردازندگی کند)

# پایان: Nginx و SSL
sudo cp config/nginx-medicalpromax.conf /etc/nginx/sites-available/
sudo systemctl reload nginx
sudo certbot --nginx -d medicalpromax.ir
```

---

## 🔍 بررسی نصب

```bash
# بررسی تمام سرویس‌ها
sudo bash scripts/verify-installation.sh

# یا دستی:
sudo supervisorctl status
curl http://127.0.0.1:8000/
curl http://127.0.0.1:3000/
free -h
```

---

## 📊 مقایسه تطبیقات

| مورد | Original | تطبیق شده | دلیل |
|------|---------|-----------|------|
| Python | 3.11 ❌ | 3.10 ✅ | موجود در VPS |
| Node.js | 20.x ❌ | 12.x ✅ | موجود در VPS |
| npm | ❌ | نصب شود ✅ | موجود نیست |
| Redis | بلی ❌ | خیر ✅ | حفظ 50MB RAM |
| Workers | 4 ❌ | 2 ✅ | 1 CPU فقط |
| Cache | Redis ❌ | File ✅ | بدون Redis |
| Node Heap | ∞ ❌ | 256MB ✅ | محدودیت RAM |

---

## ⚡ بهینه‌سازی‌های کلیدی

### 1. Swap File (هسته)
```bash
fallocate -l 2G /swapfile
swapon /swapfile
# نتیجه: 1.9GB + 2GB = 3.9GB موثر
```

### 2. Django (Backend)
```python
# Cache: FileBasedCache (نه Redis)
CACHE_BACKEND = 'django.core.cache.backends.filebased.FileBasedCache'

# Gunicorn: 2 workers (نه 4)
# Memory per worker: ~200MB
```

### 3. Next.js (Frontend)
```bash
# Node memory limit
NODE_OPTIONS="--max-old-space-size=256"

# npm optimization
npm config set legacy-peer-deps true
```

---

## ⚠️ نکات مهم

### حافظه (Critical)
```bash
# موجود: 100MB رام آزاد
# با Swap: تقریبی 3.9GB موثر
# استفاده کل: ~900MB
```

### زمان نصب
```
setup-vps.sh:        20 دقیقه
init-database.sh:    5 دقیقه
setup-backend.sh:    15 دقیقه
setup-frontend.sh:   15 دقیقه (پردازندگی کند روی 1 CPU)
---
Total:               ~55 دقیقه
```

### سرویس‌ها
```bash
# اجرای:
sudo supervisorctl status

# نتیجه مورد انتظار:
medicalpromax-backend   RUNNING
medicalpromax-frontend  RUNNING
nginx                   ACTIVE
mysql                   ACTIVE
```

---

## 📁 فایل‌های مرجع

### سریع
- 📄 `VPS_CHANGES_SUMMARY.md` - خلاصه 2 صفحه
- 📄 `CUSTOMIZATION_COMPLETE.md` - لیست کامل

### تفصیلی
- 📄 `VPS_INSTALLATION_GUIDE_FA.md` - راهنمای کامل فارسی
- 📄 `VPS_SETUP_CUSTOMIZATIONS.md` - جزئیات فنی

### کد
- 🔧 `VPS_QUICK_START.sh` - نصب خودکار
- 🔧 `scripts/verify-installation.sh` - تأیید
- 🔧 `scripts/setup-swap.sh` - Swap فایل

---

## 🆘 مشکلات شایع

### خطای "Out of Memory"
```bash
# حل:
sudo bash scripts/setup-swap.sh
# و یا افزایش swap size
```

### npm build fail
```bash
# حل:
NODE_OPTIONS="--max-old-space-size=512" npm run build
```

### Gunicorn crash
```bash
# حل: workers را کاهش دهید
sudo nano /etc/supervisor/conf.d/medicalpromax-backend.conf
# --workers 2 → --workers 1
```

---

## ✅ Checklist نهایی

- [ ] Repository cloned
- [ ] Swap file created: `swapon --show`
- [ ] VPS_QUICK_START.sh اجرا شد (یا هر 4 script)
- [ ] `sudo supervisorctl status` - همه RUNNING
- [ ] `curl http://127.0.0.1:8000/` - پاسخ 200
- [ ] `curl http://127.0.0.1:3000/` - پاسخ 200
- [ ] Nginx config: `/etc/nginx/sites-available/medicalpromax`
- [ ] SSL certificate: `sudo certbot --nginx -d medicalpromax.ir`
- [ ] `free -h` - حافظه کافی
- [ ] `tail -f /var/log/medicalpromax/*.log` - no errors

---

## 🎓 یادگیری بیشتر

### مستندات رسمی
- [Django FileBasedCache](https://docs.djangoproject.com/en/4.2/topics/cache/#filesystem-caching)
- [Gunicorn Best Practices](https://docs.gunicorn.org/)
- [Next.js Deployment](https://nextjs.org/docs/deployment)

### دستورات مفید
```bash
# Monitor
watch -n 1 'free -h && ps aux --sort=-%mem | head'

# Logs real-time
multitail -l "sudo tail -f /var/log/medicalpromax/*.log"

# Restart
sudo supervisorctl restart all

# Status
sudo systemctl status nginx mysql
```

---

## 📞 پشتیبانی

اگر مشکل پیدا کردید:

1. **Log files را بررسی کنید**:
   ```bash
   tail -f /var/log/medicalpromax/backend-error.log
   tail -f /var/log/medicalpromax/frontend-stdout.log
   ```

2. **منابع را چک کنید**:
   ```bash
   free -h
   swapon --show
   df -h /var/www
   ```

3. **صرحت‌نامه ایجاد کنید** با:
   - Full error message
   - Output logs
   - VPS specs

---

## 🎉 نتیجه

✅ **تمام تطبیقات انجام شد**

- ✅ 4 اسکریپت اصلی سازگار شد
- ✅ 7 فایل جدید ایجاد شد
- ✅ مستندات کامل فارسی
- ✅ نصب خودکار
- ✅ تأیید پس از نصب

**آماده برای نصب** 🚀

---

**آخرین به‌روزرسانی**: 1 فوریه 2025  
**Repository**: https://github.com/Hadiebrahimiseraji/medicalpromaxproject  
**Branch**: main
