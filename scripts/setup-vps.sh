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
# Step 2: Python Setup
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 2: Python Installation"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check existing Python version
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
log_info "Current Python version: $PYTHON_VERSION"

# If Python 3.10 or higher exists, use it
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    log_warn "Using existing Python 3 version: $PYTHON_VERSION"
else
    log_error "Python 3 not found"
    exit 1
fi

# Ensure pip is installed and updated
sudo apt install -y python3-venv python3-dev python3-pip
sudo pip3 install --upgrade pip setuptools wheel

$PYTHON_CMD --version

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
# Step 4: Node.js & npm Setup
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 4: Node.js & npm Setup"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if npm is already installed
if command -v npm &> /dev/null; then
    log_warn "npm already installed"
    npm --version
else
    log_info "npm not found, installing npm via apt..."
    sudo apt install -y npm
    log_success "npm installed"
    npm --version
fi

# Update npm to latest version
log_info "Updating npm to latest version..."
sudo npm install -g npm@latest

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
# Step 6: Optional Redis Setup (Disabled for low-memory VPS)
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 6: Cache Service Setup"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# For low-memory VPS, Redis may not be necessary
# Using file-based caching or database caching instead
log_warn "⚠️  Redis not installed for low-memory VPS"
log_info "Using file-based Django caching instead"
log_info "If you have >1GB free RAM, you can install Redis manually:"
log_info "   sudo apt install -y redis-server"

################################################################################
# Step 7: Supervisor & Gunicorn
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 7: Supervisor Installation"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_info "Installing Supervisor..."
sudo apt install -y supervisor
sudo systemctl start supervisor
sudo systemctl enable supervisor
log_success "Supervisor installed"

log_info "Gunicorn will be installed via Python pip during backend setup"
log_success "Supervisor configured"

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

# Fix ownership
sudo chown -R www-data:www-data /var/www/medicalpromax/repo
sudo chmod -R 755 /var/www/medicalpromax/repo

log_success "Repository cloned"

# Store repository path for other scripts
echo "$REPO_DIR" | sudo tee /var/www/medicalpromax/.repo_path > /dev/null

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
