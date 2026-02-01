#!/bin/bash

################################################################################
# Medical Promax - VPS Customized Quick Start
# تطبیق‌شده برای: Ubuntu 22.04 LTS - 1 CPU - 1.9GB RAM
# زمان نصب: ~60 دقیقه
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   Medical Promax - VPS Setup (Customized for 1GB RAM VPS)     ║"
echo "║   https://github.com/Hadiebrahimiseraji/medicalpromaxproject  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
   log_error "This script must be run with sudo or as root"
   exit 1
fi

# Step 1: Check prerequisites
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 1: Checking prerequisites..."
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check internet connection
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    log_error "No internet connection detected"
    exit 1
fi
log_success "Internet connection OK"

# Check disk space
DISK_FREE=$(df / | awk 'NR==2 {print $4}')
if [ "$DISK_FREE" -lt 5242880 ]; then  # 5GB
    log_error "Less than 5GB disk space available"
    exit 1
fi
log_success "Disk space OK ($(numfmt --to=iec $DISK_FREE))"

# Check memory
RAM_TOTAL=$(free -b | awk 'NR==2 {print $2}')
RAM_FREE=$(free -b | awk 'NR==2 {print $7}')
log_info "RAM: $(numfmt --to=iec $RAM_TOTAL) Total, $(numfmt --to=iec $RAM_FREE) Free"

if [ "$RAM_FREE" -lt 104857600 ]; then  # 100MB
    log_warn "Less than 100MB RAM available - creating swap file"
    
    if [ ! -f /swapfile ]; then
        log_info "Creating 2GB swap file (this may take a minute)..."
        fallocate -l 2G /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
        log_success "Swap file created"
    fi
fi

# Step 2: Repository setup
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 2: Repository Setup"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REPO_DIR="/var/www/medicalpromax"

if [ ! -d "$REPO_DIR" ]; then
    log_info "Cloning repository..."
    mkdir -p /var/www
    
    read -p "GitHub Repository URL (press Enter for default): " REPO_URL
    REPO_URL=${REPO_URL:-"https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git"}
    
    git clone "$REPO_URL" "$REPO_DIR"
    log_success "Repository cloned to $REPO_DIR"
else
    log_warn "Repository already exists at $REPO_DIR"
    read -p "Update existing repository? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$REPO_DIR"
        git pull origin main
        log_success "Repository updated"
    fi
fi

cd "$REPO_DIR"

# Step 3: Run setup scripts in sequence
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 3: Running Setup Scripts (This will take ~60 minutes)"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 3.1: VPS Setup
log_info "3.1: VPS System Setup (~20 minutes)..."
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo bash "$REPO_DIR/scripts/setup-vps.sh" 2>&1 | tee /tmp/setup-vps.log
    log_success "VPS setup completed"
else
    log_warn "Skipped VPS setup"
fi

echo ""

# 3.2: Database Setup
log_info "3.2: Database Initialization (~5 minutes)..."
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo bash "$REPO_DIR/scripts/init-database.sh" 2>&1 | tee /tmp/init-database.log
    log_success "Database setup completed"
else
    log_warn "Skipped database setup"
fi

echo ""

# 3.3: Backend Setup
log_info "3.3: Django Backend Setup (~15 minutes)..."
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo bash "$REPO_DIR/scripts/setup-backend.sh" 2>&1 | tee /tmp/setup-backend.log
    log_success "Backend setup completed"
else
    log_warn "Skipped backend setup"
fi

echo ""

# 3.4: Frontend Setup
log_info "3.4: Frontend Setup (~15 minutes - Node.js build is slow on 1CPU)..."
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo bash "$REPO_DIR/scripts/setup-frontend.sh" 2>&1 | tee /tmp/setup-frontend.log
    log_success "Frontend setup completed"
else
    log_warn "Skipped frontend setup"
fi

# Step 4: Post-Setup Configuration
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 4: Post-Setup Configuration"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 4.1: Nginx Configuration
log_info "Configuring Nginx..."
if [ -f "$REPO_DIR/config/nginx-medicalpromax.conf" ]; then
    sudo cp "$REPO_DIR/config/nginx-medicalpromax.conf" /etc/nginx/sites-available/medicalpromax
    
    if [ -L /etc/nginx/sites-enabled/medicalpromax ]; then
        log_warn "Nginx site already enabled"
    else
        sudo ln -s /etc/nginx/sites-available/medicalpromax /etc/nginx/sites-enabled/
        log_success "Nginx site enabled"
    fi
    
    sudo nginx -t && sudo systemctl reload nginx
    log_success "Nginx configured and reloaded"
else
    log_warn "Nginx config not found"
fi

# Step 5: SSL/TLS Setup
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 5: SSL/TLS Certificate (Optional)"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Setup SSL with Let's Encrypt? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your domain (e.g., medicalpromax.ir): " DOMAIN
    if [ -n "$DOMAIN" ]; then
        sudo certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN"
        log_success "SSL certificate configured"
    fi
fi

# Final Summary
echo ""
log_success "════════════════════════════════════════════════════════════════"
log_success "✅ INSTALLATION COMPLETE!"
log_success "════════════════════════════════════════════════════════════════"
echo ""

log_info "📋 Your Setup:"
echo "   Repository: $REPO_DIR"
echo "   Backend: /var/www/medicalpromax/backend"
echo "   Frontend: /var/www/medicalpromax/frontend"
echo "   Config: $REPO_DIR/config/"
echo ""

log_info "🔍 Verify Services:"
echo "   sudo supervisorctl status"
echo ""

log_info "📊 View Logs:"
echo "   Backend:  tail -f /var/log/medicalpromax/backend-error.log"
echo "   Frontend: tail -f /var/log/medicalpromax/frontend-stdout.log"
echo "   Nginx:    tail -f /var/log/nginx/error.log"
echo ""

log_info "🚀 Start/Stop Services:"
echo "   sudo supervisorctl restart all"
echo "   sudo supervisorctl stop medicalpromax-backend"
echo "   sudo systemctl restart nginx"
echo ""

log_warn "⚠️  Important Notes:"
echo "   1. Edit .env files with your actual credentials"
echo "   2. Update Nginx config with your domain"
echo "   3. Generate Django SECRET_KEY and JWT secrets"
echo "   4. Configure SMTP email settings"
echo "   5. Monitor memory usage: free -h && swapon --show"
echo ""

# Save setup logs
mkdir -p "$REPO_DIR/setup-logs"
cp /tmp/setup-*.log "$REPO_DIR/setup-logs/" 2>/dev/null || true
log_info "Setup logs saved to: $REPO_DIR/setup-logs/"
echo ""

log_success "Setup completed at $(date)"
log_success "════════════════════════════════════════════════════════════════"
