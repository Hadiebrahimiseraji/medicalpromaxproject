#!/bin/bash

################################################################################
# Create Swap File for Low-Memory VPS
# برای VPS‌های کم‌حافظه
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

# Check if running as root
if [ "$EUID" -ne 0 ]; then
   log_error "This script must be run with sudo"
   exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Create Swap File for Low-Memory VPS                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Show current memory status
log_info "Current memory status:"
free -h
echo ""

# Check if swap already exists
if swapon --show | grep -q "/swapfile"; then
    log_warn "Swap file already exists"
    swapon --show
    exit 0
fi

# Ask for swap size
read -p "Enter swap file size (e.g., 2G, 4G) [default: 2G]: " SWAP_SIZE
SWAP_SIZE=${SWAP_SIZE:-2G}

log_info "Creating $SWAP_SIZE swap file..."
echo ""

# Create swap file
log_info "Step 1: Creating swap file..."
fallocate -l $SWAP_SIZE /swapfile

if [ -f /swapfile ]; then
    log_success "Swap file created"
else
    log_error "Failed to create swap file"
    exit 1
fi

log_info "Step 2: Setting permissions..."
chmod 600 /swapfile
ls -lh /swapfile
log_success "Permissions set"

log_info "Step 3: Setting up swap..."
mkswap /swapfile
log_success "Swap setup complete"

log_info "Step 4: Enabling swap..."
swapon /swapfile
log_success "Swap enabled"

log_info "Step 5: Making swap permanent..."
if ! grep -q '/swapfile none swap sw 0 0' /etc/fstab; then
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    log_success "Swap added to fstab"
else
    log_warn "Swap already in fstab"
fi

log_info "Step 6: Optimizing swap settings..."

# Set swappiness (30 is good for servers)
echo "vm.swappiness = 30" | tee -a /etc/sysctl.conf > /dev/null
sysctl -p > /dev/null

# Set cache pressure
echo "vm.vfs_cache_pressure = 50" | tee -a /etc/sysctl.conf > /dev/null
sysctl -p > /dev/null

log_success "Swap settings optimized"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
log_success "✅ Swap file setup complete!"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

log_info "New memory status:"
free -h

log_info "Swap details:"
swapon --show

echo ""
log_info "You can now run the setup scripts without memory issues"
