#!/bin/bash

################################################################################
# MedicalProMax VPS Setup Script
# OS: Ubuntu 22.04 LTS or 24.04 LTS
# This script automates all infrastructure setup on the VPS
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

################################################################################
# Step 1: System Update & Security
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 1: System Update & Security Setup"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_info "Updating system packages..."
sudo apt update
sudo apt upgrade -y
log_success "System updated"

log_info "Installing build essentials..."
sudo apt install -y build-essential curl wget git zip unzip htop net-tools
log_success "Build essentials installed"

################################################################################
# Step 2: Python 3.11 Setup
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 2: Python 3.11 Installation"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v python3.11 &> /dev/null; then
    log_info "Installing Python 3.11..."
    sudo apt install -y python3.11 python3.11-venv python3.11-dev python3-pip
    log_success "Python 3.11 installed"
else
    log_warn "Python 3.11 already installed"
fi

python3.11 --version

################################################################################
# Step 3: MySQL 8.0 Setup
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 3: MySQL 8.0 Installation"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v mysql &> /dev/null; then
    log_info "Installing MySQL 8.0..."
    sudo apt install -y mysql-server libmysqlclient-dev
    
    # Start MySQL service
    sudo systemctl start mysql
    sudo systemctl enable mysql
    
    log_success "MySQL 8.0 installed and started"
else
    log_warn "MySQL already installed"
fi

mysql --version

################################################################################
# Step 4: Node.js 20.x Setup
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 4: Node.js 20.x Installation"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v node &> /dev/null; then
    log_info "Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    log_success "Node.js 20.x installed"
else
    log_warn "Node.js already installed"
fi

node --version
npm --version

################################################################################
# Step 5: Nginx Setup
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 5: Nginx Installation"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v nginx &> /dev/null; then
    log_info "Installing Nginx..."
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    log_success "Nginx installed and started"
else
    log_warn "Nginx already installed"
fi

nginx -v

################################################################################
# Step 6: Redis Setup
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 6: Redis Installation"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v redis-server &> /dev/null; then
    log_info "Installing Redis..."
    sudo apt install -y redis-server
    sudo systemctl start redis-server
    sudo systemctl enable redis-server
    log_success "Redis installed and started"
else
    log_warn "Redis already installed"
fi

redis-server --version

################################################################################
# Step 7: Supervisor & Gunicorn
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 7: Supervisor & Gunicorn Installation"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_info "Installing Supervisor..."
sudo apt install -y supervisor
sudo systemctl start supervisor
sudo systemctl enable supervisor
log_success "Supervisor installed"

log_info "Installing Gunicorn via pip..."
sudo pip3 install gunicorn
log_success "Gunicorn installed"

################################################################################
# Step 8: SSL/TLS with Certbot
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 8: Certbot (Let's Encrypt) Installation"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_info "Installing Certbot..."
sudo apt install -y certbot python3-certbot-nginx
log_success "Certbot installed"

log_warn "⚠️  SSL certificate generation requires domain DNS to be active"
log_warn "You can request certificate later using: sudo certbot --nginx -d medicalpromax.ir"

################################################################################
# Step 9: Firewall Setup
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 9: Firewall Configuration (UFW)"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_info "Configuring firewall rules..."
sudo apt install -y ufw

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP & HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow custom SSH port (uncomment if you use custom port)
# sudo ufw allow 2222/tcp

# Enable firewall
echo "y" | sudo ufw enable

log_success "Firewall configured"
sudo ufw status

################################################################################
# Step 10: Create Application Directories
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 10: Create Application Directories"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_info "Creating application directories..."
sudo mkdir -p /var/www/medicalpromax/backend
sudo mkdir -p /var/www/medicalpromax/frontend
sudo mkdir -p /var/www/medicalpromax/media
sudo mkdir -p /var/www/medicalpromax/static
sudo mkdir -p /var/www/medicalpromax/backups
sudo mkdir -p /var/log/medicalpromax

# Create www-data user if needed
if ! id "www-data" &>/dev/null; then
    sudo useradd -r -s /bin/bash www-data
fi

# Set permissions
sudo chown -R www-data:www-data /var/www/medicalpromax
sudo chown -R www-data:www-data /var/log/medicalpromax
sudo chmod -R 755 /var/www/medicalpromax

log_success "Application directories created"

################################################################################
# Step 11: Clone Repository
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 11: Clone Repository"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_info "Enter your GitHub repository URL:"
log_info "Example: https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git"
read -p "Repository URL: " REPO_URL

if [ -z "$REPO_URL" ]; then
    log_error "Repository URL cannot be empty"
    exit 1
fi

log_info "Cloning repository..."
sudo git clone "$REPO_URL" /var/www/medicalpromax/repo
sudo chown -R www-data:www-data /var/www/medicalpromax/repo

log_success "Repository cloned"

################################################################################
# Summary
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "✅ VPS SETUP COMPLETE!"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
log_info "📋 Next Steps:"
echo "   1. Setup MySQL database:"
echo "      sudo mysql < /var/www/medicalpromax/repo/init_database.sql"
echo ""
echo "   2. Setup Django backend:"
echo "      cd /var/www/medicalpromax/backend && bash setup-backend.sh"
echo ""
echo "   3. Setup Next.js frontend:"
echo "      cd /var/www/medicalpromax/frontend && bash setup-frontend.sh"
echo ""
echo "   4. Configure Nginx"
echo ""
echo "   5. Request SSL certificate:"
echo "      sudo certbot --nginx -d medicalpromax.ir -d www.medicalpromax.ir"
echo ""

log_success "Setup script completed successfully!"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
