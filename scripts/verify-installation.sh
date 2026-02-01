#!/bin/bash

################################################################################
# Medical Promax - Post-Installation Verification
# بررسی کامل پس از نصب
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[•]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║    Medical Promax - Post-Installation Verification            ║"
echo "║    بررسی پس از نصب                                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

# Function to check service
check_service() {
    local service=$1
    local name=$2
    
    if systemctl is-active --quiet $service 2>/dev/null || \
       sudo supervisorctl status $service &>/dev/null; then
        log_success "$name is running"
        ((PASSED++))
    else
        log_error "$name is NOT running"
        ((FAILED++))
    fi
}

# Function to check port
check_port() {
    local port=$1
    local name=$2
    
    if netstat -tuln 2>/dev/null | grep -q ":$port " || \
       ss -tuln 2>/dev/null | grep -q ":$port "; then
        log_success "$name is listening on port $port"
        ((PASSED++))
    else
        log_error "$name is NOT listening on port $port"
        ((FAILED++))
    fi
}

# Function to check file
check_file() {
    local file=$1
    local name=$2
    
    if [ -f "$file" ]; then
        log_success "$name exists"
        ((PASSED++))
    else
        log_error "$name NOT found at $file"
        ((FAILED++))
    fi
}

# Function to test endpoint
test_endpoint() {
    local url=$1
    local name=$2
    
    if curl -s -m 5 "$url" > /dev/null 2>&1; then
        log_success "$name responding"
        ((PASSED++))
    else
        log_warn "$name NOT responding (might be normal if server not running)"
        ((WARNINGS++))
    fi
}

# ============================================================================
# 1. System Checks
# ============================================================================
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "1. SYSTEM CHECKS"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    log_success "Python: $PYTHON_VERSION"
    ((PASSED++))
else
    log_error "Python not found"
    ((FAILED++))
fi

# Node
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    log_success "Node.js: $NODE_VERSION"
    ((PASSED++))
else
    log_error "Node.js not found"
    ((FAILED++))
fi

# npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    log_success "npm: $NPM_VERSION"
    ((PASSED++))
else
    log_error "npm not found"
    ((FAILED++))
fi

# Git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    log_success "Git: $GIT_VERSION"
    ((PASSED++))
else
    log_error "Git not found"
    ((FAILED++))
fi

# Nginx
if command -v nginx &> /dev/null; then
    NGINX_VERSION=$(nginx -v 2>&1 | awk -F/ '{print $2}')
    log_success "Nginx: $NGINX_VERSION"
    ((PASSED++))
else
    log_error "Nginx not found"
    ((FAILED++))
fi

# MySQL
if command -v mysql &> /dev/null; then
    log_success "MySQL/MariaDB installed"
    ((PASSED++))
else
    log_error "MySQL/MariaDB not found"
    ((FAILED++))
fi

# ============================================================================
# 2. Service Status
# ============================================================================
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "2. SERVICE STATUS"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_service nginx "Nginx" || true
check_service mysql "MySQL" || true
check_service supervisor "Supervisor" || true

if command -v supervisorctl &> /dev/null; then
    log_info "Supervisor services:"
    sudo supervisorctl status | while read line; do
        echo "  $line"
    done
fi

# ============================================================================
# 3. Port Checks
# ============================================================================
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "3. PORT CHECKS"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_port 80 "HTTP (80)" || true
check_port 443 "HTTPS (443)" || true
check_port 8000 "Django API (8000)" || true
check_port 3000 "Next.js Frontend (3000)" || true
check_port 3306 "MySQL (3306)" || true

# ============================================================================
# 4. Directory & File Checks
# ============================================================================
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "4. DIRECTORIES & FILES"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DIRS=(
    "/var/www/medicalpromax/backend"
    "/var/www/medicalpromax/frontend"
    "/var/www/medicalpromax/repo"
    "/var/log/medicalpromax"
)

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        log_success "Directory exists: $dir"
        ((PASSED++))
    else
        log_warn "Directory missing: $dir"
        ((WARNINGS++))
    fi
done

FILES=(
    "/var/www/medicalpromax/backend/.env.production"
    "/var/www/medicalpromax/frontend/.env.production"
    "/etc/nginx/sites-available/medicalpromax"
    "/etc/supervisor/conf.d/medicalpromax-backend.conf"
    "/etc/supervisor/conf.d/medicalpromax-frontend.conf"
)

for file in "${FILES[@]}"; do
    check_file "$file" "$(basename $file)"
done

# ============================================================================
# 5. Connectivity Tests
# ============================================================================
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "5. CONNECTIVITY TESTS"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_endpoint "http://127.0.0.1:8000/" "Django Backend" || true
test_endpoint "http://127.0.0.1:3000/" "Next.js Frontend" || true
test_endpoint "http://127.0.0.1/" "Nginx" || true

# ============================================================================
# 6. Resource Check
# ============================================================================
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "6. SYSTEM RESOURCES"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Memory
log_info "Memory Usage:"
free -h | awk 'NR==2 {print "  Total: " $2 ", Used: " $3 ", Free: " $4}' || true
swapon --show 2>/dev/null | tail -1 | awk '{print "  Swap: " $3}' || log_warn "  No swap configured"

# Disk
log_info "Disk Usage:"
df -h /var/www | tail -1 | awk '{print "  /var/www: " $5 " used, " $4 " available"}' || true
df -h / | tail -1 | awk '{print "  /: " $5 " used, " $4 " available"}' || true

# CPU Load
log_info "CPU Load:"
uptime | awk -F'load average:' '{print "  " $2}' || true

# ============================================================================
# 7. Permission Checks
# ============================================================================
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "7. PERMISSION CHECKS"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "/var/www/medicalpromax" ]; then
    OWNER=$(ls -ld /var/www/medicalpromax | awk '{print $3":"$4}')
    log_info "Backend owner: $OWNER"
    
    if [ "$OWNER" = "www-data:www-data" ] || [ "$OWNER" = "root:root" ]; then
        log_success "Permissions correct"
        ((PASSED++))
    else
        log_warn "Permissions might need adjustment"
        ((WARNINGS++))
    fi
fi

# ============================================================================
# 8. Log File Checks
# ============================================================================
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "8. LOG FILES"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

LOG_FILES=(
    "/var/log/medicalpromax/backend-error.log"
    "/var/log/medicalpromax/frontend-stdout.log"
    "/var/log/nginx/error.log"
)

for log in "${LOG_FILES[@]}"; do
    if [ -f "$log" ]; then
        RECENT=$(tail -1 "$log" 2>/dev/null)
        if [ $? -eq 0 ]; then
            log_success "Log file: $(basename $log)"
            ((PASSED++))
        else
            log_warn "Cannot read log: $(basename $log)"
            ((WARNINGS++))
        fi
    else
        log_warn "Log file not found: $(basename $log)"
        ((WARNINGS++))
    fi
done

# ============================================================================
# 9. SSL Certificate Check
# ============================================================================
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "9. SSL CERTIFICATE"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "/etc/letsencrypt/live" ]; then
    CERTS=$(ls /etc/letsencrypt/live/ 2>/dev/null | wc -l)
    if [ "$CERTS" -gt 0 ]; then
        log_success "SSL certificates found"
        ls /etc/letsencrypt/live/
        ((PASSED++))
    else
        log_warn "No SSL certificates found"
        log_info "Run: sudo certbot --nginx -d medicalpromax.ir"
        ((WARNINGS++))
    fi
else
    log_warn "Let's Encrypt directory not found"
    ((WARNINGS++))
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
log_success "VERIFICATION COMPLETE"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

log_info "Results:"
echo "  ✓ Passed:   $PASSED"
echo "  ✗ Failed:   $FAILED"
echo "  ! Warnings: $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        log_success "Everything looks good! ✅"
    else
        log_warn "Setup mostly complete, but check warnings above ⚠️"
    fi
else
    log_error "Setup has issues, please check failed items above ❌"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_info "📊 Quick Commands:"
echo ""
echo "View services:"
echo "  sudo supervisorctl status"
echo ""
echo "View logs:"
echo "  tail -f /var/log/medicalpromax/backend-error.log"
echo "  tail -f /var/log/medicalpromax/frontend-stdout.log"
echo ""
echo "Restart services:"
echo "  sudo supervisorctl restart all"
echo ""
echo "Check resources:"
echo "  free -h && df -h && uptime"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
