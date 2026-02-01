#!/bin/bash

################################################################################
# Next.js Frontend Setup Script for MedicalProMax
# Runs AFTER VPS system setup
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

FRONTEND_DIR="/var/www/medicalpromax/frontend"
REPO_DIR="/var/www/medicalpromax/repo"

echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "NEXT.JS FRONTEND SETUP"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

################################################################################
# Step 1: Copy frontend files
################################################################################
echo ""
log_info "STEP 1: Copy frontend files from repository"

if [ ! -d "$REPO_DIR" ]; then
    log_error "Repository not found at $REPO_DIR"
    exit 1
fi

log_info "Copying frontend files..."
mkdir -p "$FRONTEND_DIR"
cp -r "$REPO_DIR"/frontend/* "$FRONTEND_DIR/" 2>/dev/null || true

log_success "Frontend files copied"

################################################################################
# Step 2: Install Node dependencies
################################################################################
echo ""
log_info "STEP 2: Install Node.js dependencies"

cd "$FRONTEND_DIR"

log_info "Running npm install..."
npm install

log_success "Dependencies installed"

################################################################################
# Step 3: Environment configuration
################################################################################
echo ""
log_info "STEP 3: Create environment configuration"

cat > "$FRONTEND_DIR/.env.production" << 'EOF'
# API Configuration
NEXT_PUBLIC_API_BASE_URL=https://medicalpromax.ir/api
NEXT_PUBLIC_SITE_URL=https://medicalpromax.ir

# Application Configuration
NEXT_PUBLIC_APP_NAME=MedicalProMax
NEXT_PUBLIC_APP_VERSION=1.0.0

# Analytics (optional)
# NEXT_PUBLIC_GA_ID=

# Feature Flags
NEXT_PUBLIC_ENABLE_ANALYTICS=true
EOF

log_warn "⚠️  .env.production created. Update if needed."

################################################################################
# Step 4: Build Next.js project
################################################################################
echo ""
log_info "STEP 4: Build Next.js project"

cd "$FRONTEND_DIR"

log_info "Building project..."
npm run build

log_success "Build completed"

################################################################################
# Step 5: Create Supervisor configuration
################################################################################
echo ""
log_info "STEP 5: Create Supervisor configuration"

sudo tee /etc/supervisor/conf.d/medicalpromax-frontend.conf > /dev/null << EOF
[program:medicalpromax-frontend]
command=npm start
directory=$FRONTEND_DIR
user=www-data
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
environment=NODE_ENV="production"
stdout_logfile=/var/log/medicalpromax/frontend-stdout.log
stderr_logfile=/var/log/medicalpromax/frontend-stderr.log
EOF

log_success "Supervisor configuration created"

################################################################################
# Summary
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "✅ NEXT.JS FRONTEND SETUP COMPLETE!"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
log_info "📋 Next Steps:"
echo "   1. Reload Supervisor:"
echo "      sudo supervisorctl reread"
echo "      sudo supervisorctl update"
echo "      sudo supervisorctl start medicalpromax-frontend"
echo ""
echo "   2. Check frontend status:"
echo "      sudo supervisorctl status medicalpromax-frontend"
echo ""
echo "   3. View logs:"
echo "      tail -f /var/log/medicalpromax/frontend-stdout.log"
echo ""

log_success "Frontend setup complete!"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
