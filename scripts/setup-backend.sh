#!/bin/bash

################################################################################
# Django Backend Setup Script for MedicalProMax
# Runs AFTER VPS system setup and MySQL initialization
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

BACKEND_DIR="/var/www/medicalpromax/backend"
REPO_DIR="/var/www/medicalpromax/repo"

echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "DJANGO BACKEND SETUP"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

################################################################################
# Step 1: Copy backend files
################################################################################
echo ""
log_info "STEP 1: Copy backend files from repository"

if [ ! -d "$REPO_DIR" ]; then
    log_error "Repository not found at $REPO_DIR"
    exit 1
fi

log_info "Creating Django project structure..."
mkdir -p "$BACKEND_DIR"
cp -r "$REPO_DIR"/backend/* "$BACKEND_DIR/" 2>/dev/null || true

log_success "Backend files copied"

################################################################################
# Step 2: Create Python virtual environment
################################################################################
echo ""
log_info "STEP 2: Create Python virtual environment"

if [ -d "$BACKEND_DIR/venv" ]; then
    log_warn "Virtual environment already exists"
else
    log_info "Creating venv..."
    cd "$BACKEND_DIR"
    python3.11 -m venv venv
    log_success "Virtual environment created"
fi

# Activate venv
source "$BACKEND_DIR/venv/bin/activate"
log_success "Virtual environment activated"

################################################################################
# Step 3: Install Python dependencies
################################################################################
echo ""
log_info "STEP 3: Install Python dependencies"

pip install --upgrade pip setuptools wheel
pip install Django==4.2.0
pip install djangorestframework==3.14.0
pip install django-cors-headers==4.0.0
pip install djangorestframework-simplejwt==5.2.2
pip install mysqlclient==2.2.0
pip install python-decouple==3.8
pip install gunicorn==20.1.0
pip install Pillow==10.0.0

log_success "Dependencies installed"

################################################################################
# Step 4: Create Django project structure
################################################################################
echo ""
log_info "STEP 4: Create Django project structure"

cd "$BACKEND_DIR"

# Create config directory if needed
mkdir -p config/settings
mkdir -p apps/{core,content,questions,exams,users,analytics}

log_success "Project structure created"

################################################################################
# Step 5: Environment configuration
################################################################################
echo ""
log_info "STEP 5: Create environment configuration"

cat > "$BACKEND_DIR/.env.production" << 'EOF'
# Database Configuration
DATABASE_ENGINE=django.db.backends.mysql
DATABASE_NAME=medicalpromax_db
DATABASE_USER=medicalpromax_user
DATABASE_PASSWORD=CHANGE_THIS_PASSWORD
DATABASE_HOST=localhost
DATABASE_PORT=3306

# Django Configuration
SECRET_KEY=GENERATE_WITH_django_core_management_utils_get_random_secret_key
DEBUG=False
ALLOWED_HOSTS=medicalpromax.ir,www.medicalpromax.ir,127.0.0.1

# CORS Configuration
CORS_ALLOWED_ORIGINS=https://medicalpromax.ir,https://www.medicalpromax.ir

# JWT Configuration
JWT_SECRET_KEY=ANOTHER_RANDOM_SECRET
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_LIFETIME=60
JWT_REFRESH_TOKEN_LIFETIME=7

# File Storage
MEDIA_ROOT=/var/www/medicalpromax/media
STATIC_ROOT=/var/www/medicalpromax/static
MEDIA_URL=/media/
STATIC_URL=/static/

# Redis Cache
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0

# Email Configuration
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# Logging
LOG_LEVEL=INFO
EOF

log_warn "⚠️  Edit .env.production file with your actual credentials"
log_info "Location: $BACKEND_DIR/.env.production"

################################################################################
# Step 6: Database migrations
################################################################################
echo ""
log_info "STEP 6: Run database migrations"

cd "$BACKEND_DIR"

python manage.py makemigrations
python manage.py migrate

log_success "Database migrations completed"

################################################################################
# Step 7: Create superuser
################################################################################
echo ""
log_info "STEP 7: Create Django superuser"

log_info "Enter superuser credentials:"
read -p "Email: " ADMIN_EMAIL
read -p "First Name: " ADMIN_FIRST
read -p "Last Name: " ADMIN_LAST
read -s -p "Password: " ADMIN_PASSWORD
echo ""

python manage.py shell << PYTHON
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(email='$ADMIN_EMAIL').exists():
    User.objects.create_superuser(
        email='$ADMIN_EMAIL',
        password='$ADMIN_PASSWORD',
        first_name='$ADMIN_FIRST',
        last_name='$ADMIN_LAST'
    )
    print("✅ Superuser created successfully")
else:
    print("⚠️  Superuser already exists")
PYTHON

################################################################################
# Step 8: Collect static files
################################################################################
echo ""
log_info "STEP 8: Collect static files"

cd "$BACKEND_DIR"
python manage.py collectstatic --noinput

log_success "Static files collected"

################################################################################
# Step 9: Create Supervisor configuration
################################################################################
echo ""
log_info "STEP 9: Create Supervisor configuration"

sudo tee /etc/supervisor/conf.d/medicalpromax-backend.conf > /dev/null << EOF
[program:medicalpromax-backend]
command=$BACKEND_DIR/venv/bin/gunicorn \
    --workers 4 \
    --worker-class sync \
    --bind 127.0.0.1:8000 \
    --timeout 120 \
    --access-logfile /var/log/medicalpromax/backend-access.log \
    --error-logfile /var/log/medicalpromax/backend-error.log \
    config.wsgi:application

directory=$BACKEND_DIR
user=www-data
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true

environment=DJANGO_SETTINGS_MODULE="config.settings.production",PYTHONUNBUFFERED=1

stdout_logfile=/var/log/medicalpromax/backend-stdout.log
stderr_logfile=/var/log/medicalpromax/backend-stderr.log
EOF

log_success "Supervisor configuration created"

################################################################################
# Summary
################################################################################
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "✅ DJANGO BACKEND SETUP COMPLETE!"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
log_info "📋 Next Steps:"
echo "   1. Update .env.production with actual credentials"
echo ""
echo "   2. Reload Supervisor:"
echo "      sudo supervisorctl reread"
echo "      sudo supervisorctl update"
echo "      sudo supervisorctl start medicalpromax-backend"
echo ""
echo "   3. Check backend status:"
echo "      sudo supervisorctl status medicalpromax-backend"
echo ""
echo "   4. View logs:"
echo "      tail -f /var/log/medicalpromax/backend-access.log"
echo ""

log_success "Backend setup complete!"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
