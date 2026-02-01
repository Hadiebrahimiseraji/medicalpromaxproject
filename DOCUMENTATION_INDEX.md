# 📚 MedicalProMax Documentation Index

**Complete reference guide for the MedicalProMax platform**

*Version: 1.0.0 | Updated: February 2026*

---

## 🎯 Quick Navigation

### 🚀 **Getting Started**
Start here if you're new to the project:

1. **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Overview of what's been built
   - Project statistics
   - Complete feature list
   - Tech stack summary
   - Deployment timeline

2. **[README_PROJECT.md](README_PROJECT.md)** - Detailed project documentation
   - Architecture explanation
   - Technology stack details
   - Feature overview
   - Development guide

---

### 🌐 **VPS Deployment**
Everything you need to deploy to production:

1. **[VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md)** - Step-by-step deployment guide (20 pages)
   - Prerequisites checklist
   - SSH connection guide
   - Each deployment step explained
   - Verification procedures
   - Troubleshooting guide
   - Monitoring commands
   - Database backup procedures

2. **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** - Track deployment progress
   - Phase-by-phase breakdown
   - Status of each component
   - Timeline estimates
   - Configuration checklist
   - Testing procedures

3. **[QUICK_START.sh](QUICK_START.sh)** - Command reference
   - All deployment commands
   - Configuration commands
   - Monitoring commands
   - Troubleshooting commands
   - Updates & maintenance

4. **[ARCHITECTURE_VISUAL.md](ARCHITECTURE_VISUAL.md)** - Visual diagrams
   - Platform architecture
   - Request/response flows
   - Service interactions
   - Directory structure
   - Deployment flow

---

### 💻 **Development & APIs**

1. **[api_testing_guide.md](api_testing_guide.md)** - Complete API documentation
   - 25+ API endpoints
   - cURL examples
   - Postman collection examples
   - Request/response formats
   - Error handling
   - Authentication flows

2. **[django_models.py](django_models.py)** - Django ORM models
   - Complete model definitions
   - Relationships and constraints
   - Field configurations

3. **[core_serializers.py](core_serializers.py)** - DRF serializers
   - Input validation
   - Data transformation
   - Nested serializers

4. **[core_views.py](core_views.py)** - API views and viewsets
   - ViewSet implementations
   - Filtering and pagination
   - Permission classes

5. **[auth_views.py](auth_views.py)** - Authentication endpoints
   - Registration
   - Login/Logout
   - Token refresh
   - User profile

---

### 🎨 **Frontend Components**

1. **[exam_interface.tsx](exam_interface.tsx)** - Main exam taking interface
   - Question display
   - Timer management
   - Answer submission
   - Navigation between questions

2. **[exam_components.tsx](exam_components.tsx)** - Reusable exam components
   - Question card component
   - Options display
   - Results panel
   - Score visualization

---

### 📋 **Database & Configuration**

1. **[init_database.sql](init_database.sql)** - Database schema
   - All 17 table definitions
   - Indexes and constraints
   - Full-text search setup

2. **[config/nginx-medicalpromax.conf](config/nginx-medicalpromax.conf)** - Nginx configuration
   - Reverse proxy setup
   - SSL/TLS configuration
   - Static file serving
   - Security headers
   - CORS configuration

---

### 📝 **Specifications & Planning**

1. **[detailed_spec_v1.md](detailed_spec_v1.md)** - Detailed technical specification
   - Requirements breakdown
   - API specifications
   - Database schema details
   - UI/UX specifications

2. **[implementation_summary.md](implementation_summary.md)** - Implementation overview
   - What's been built
   - Architecture decisions
   - Code organization
   - Best practices

3. **[github_setup.md](github_setup.md)** - GitHub configuration
   - Repository setup
   - Branch strategy
   - CI/CD configuration
   - Deployment automation

---

### 🛠️ **Setup Scripts**

Located in `/scripts/` directory:

1. **[scripts/setup-vps.sh](scripts/setup-vps.sh)** - System environment setup
   - 20-minute automated setup
   - Installs all dependencies
   - Configures firewall
   - Clones repository

2. **[scripts/init-database.sh](scripts/init-database.sh)** - Database initialization
   - Creates MySQL database
   - Sets up user account
   - Loads schema
   - Seeds initial data

3. **[scripts/setup-backend.sh](scripts/setup-backend.sh)** - Django backend setup
   - Virtual environment creation
   - Dependency installation
   - Configuration files
   - Migrations and static files
   - Supervisor setup

4. **[scripts/setup-frontend.sh](scripts/setup-frontend.sh)** - Next.js frontend setup
   - npm dependencies
   - Production build
   - Supervisor configuration

---

## 📊 Document Map

```
Documentation/
├── Getting Started
│   ├── PROJECT_SUMMARY.md              ← START HERE
│   ├── README_PROJECT.md
│   └── README.md
│
├── Deployment & Infrastructure
│   ├── VPS_SETUP_GUIDE.md              ← DEPLOY HERE
│   ├── DEPLOYMENT_CHECKLIST.md
│   ├── ARCHITECTURE_VISUAL.md
│   ├── QUICK_START.sh
│   └── config/nginx-medicalpromax.conf
│
├── Backend Development
│   ├── django_models.py
│   ├── core_serializers.py
│   ├── core_views.py
│   ├── auth_views.py
│   ├── exam_views.py
│   └── exam_models.py
│
├── Frontend Development
│   ├── exam_interface.tsx
│   ├── exam_components.tsx
│   └── (React/TypeScript files)
│
├── Database & API
│   ├── api_testing_guide.md
│   ├── init_database.sql
│   └── user_models.py
│
└── Specifications
    ├── detailed_spec_v1.md
    ├── implementation_summary.md
    └── github_setup.md
```

---

## 🎯 Common Tasks

### "I want to deploy to VPS"
→ Read: [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md)
→ Use: [QUICK_START.sh](QUICK_START.sh)
→ Follow: [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)

### "I want to understand the architecture"
→ Read: [ARCHITECTURE_VISUAL.md](ARCHITECTURE_VISUAL.md)
→ Review: [README_PROJECT.md](README_PROJECT.md)
→ Check: Platform diagrams in this document

### "I want to test the APIs"
→ Read: [api_testing_guide.md](api_testing_guide.md)
→ Use: cURL examples or Postman
→ Reference: Request/response formats

### "I want to modify the database"
→ Edit: [init_database.sql](init_database.sql)
→ Create: Django migration (`python manage.py makemigrations`)
→ Run: Migration (`python manage.py migrate`)

### "I want to add a new feature"
→ Follow: Development guide in [README_PROJECT.md](README_PROJECT.md)
→ Reference: [detailed_spec_v1.md](detailed_spec_v1.md)
→ Update: Model → Serializer → ViewSet → Frontend

### "I want to troubleshoot an issue"
→ Check: Logs in `/var/log/medicalpromax/`
→ Reference: [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md#-troubleshooting)
→ Use: Commands in [QUICK_START.sh](QUICK_START.sh#-section-8-troubleshooting-commands)

---

## 📚 Document Details

| Document | Pages | Purpose | Key Info |
|----------|-------|---------|----------|
| PROJECT_SUMMARY.md | 5 | Overview | What's built, statistics |
| README_PROJECT.md | 8 | Reference | Architecture, features |
| VPS_SETUP_GUIDE.md | 20 | Deployment | Step-by-step setup |
| DEPLOYMENT_CHECKLIST.md | 10 | Tracking | Progress checklist |
| QUICK_START.sh | 8 | Commands | All deployment commands |
| ARCHITECTURE_VISUAL.md | 8 | Diagrams | ASCII architecture |
| api_testing_guide.md | 15 | API Reference | 40+ endpoint examples |
| detailed_spec_v1.md | 12 | Specification | Technical requirements |
| init_database.sql | 8 | Database | Schema + seed data |

**Total Documentation: ~100 pages**

---

## 🔗 External Resources

### Official Documentation
- [Django 4.2 Docs](https://docs.djangoproject.com/en/4.2/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Next.js 14 Docs](https://nextjs.org/docs)
- [React 18 Docs](https://react.dev)
- [MySQL 8.0 Docs](https://dev.mysql.com/doc/refman/8.0/en/)
- [Nginx Docs](https://nginx.org/en/docs/)
- [Let's Encrypt](https://letsencrypt.org/)

### Tools
- [GitHub](https://github.com/Hadiebrahimiseraji/medicalpromaxproject)
- [Postman](https://www.postman.com/)
- [cURL](https://curl.se/)
- [MySQL Workbench](https://www.mysql.com/products/workbench/)

---

## 🚀 Deployment Quick Links

**First time deploying?**
1. Read [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) (5 min)
2. Read [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md) (30 min)
3. Follow steps 1-8 in guide (60 min)
4. Verify using [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) (10 min)

**Troubleshooting?**
- Check [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md#-troubleshooting)
- Run commands from [QUICK_START.sh](QUICK_START.sh)
- Check logs in `/var/log/medicalpromax/`

**Need to update code?**
- Pull latest: `git pull origin main`
- Rebuild backend: `scripts/setup-backend.sh`
- Rebuild frontend: `scripts/setup-frontend.sh`

---

## 📞 Support Resources

| Need | Resource |
|------|----------|
| Project Overview | [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) |
| Deployment Help | [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md) |
| API Documentation | [api_testing_guide.md](api_testing_guide.md) |
| Architecture Info | [ARCHITECTURE_VISUAL.md](ARCHITECTURE_VISUAL.md) |
| Troubleshooting | [VPS_SETUP_GUIDE.md - Troubleshooting](VPS_SETUP_GUIDE.md#-troubleshooting) |
| Commands Reference | [QUICK_START.sh](QUICK_START.sh) |
| Database Schema | [init_database.sql](init_database.sql) |
| GitHub Repository | [medicalpromaxproject](https://github.com/Hadiebrahimiseraji/medicalpromaxproject) |

---

## ✅ Pre-Deployment Checklist

Before you begin deployment:

- [ ] Read [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
- [ ] Read [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md)
- [ ] Gather VPS connection details
- [ ] Prepare domain name (medicalpromax.ir)
- [ ] Have email credentials ready
- [ ] Generate Django SECRET_KEY
- [ ] Create database password
- [ ] Setup GitHub access token
- [ ] Review [ARCHITECTURE_VISUAL.md](ARCHITECTURE_VISUAL.md)

---

## 🎓 Learning Path

### For Project Managers
1. [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - What's been built
2. [ARCHITECTURE_VISUAL.md](ARCHITECTURE_VISUAL.md) - How it works
3. [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Deployment status

### For DevOps Engineers
1. [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md) - Infrastructure setup
2. [config/nginx-medicalpromax.conf](config/nginx-medicalpromax.conf) - Web server config
3. [QUICK_START.sh](QUICK_START.sh) - Operational commands

### For Backend Developers
1. [README_PROJECT.md](README_PROJECT.md) - Architecture
2. [django_models.py](django_models.py) - Data models
3. [api_testing_guide.md](api_testing_guide.md) - API endpoints
4. [detailed_spec_v1.md](detailed_spec_v1.md) - Specifications

### For Frontend Developers
1. [README_PROJECT.md](README_PROJECT.md#-frontend-structure) - Frontend structure
2. [exam_interface.tsx](exam_interface.tsx) - Main components
3. [ARCHITECTURE_VISUAL.md](ARCHITECTURE_VISUAL.md) - Request flows

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Feb 2026 | Initial complete platform release |

---

## 📝 Notes

- All scripts are tested and production-ready
- Documentation is comprehensive and up-to-date
- Total setup time: ~70 minutes (excluding DNS/SSL propagation)
- All credentials should be kept secure
- Regular backups are recommended (scripts provided)
- Monitor logs regularly for issues

---

## 🎉 You're Ready!

All documentation is complete. Choose your next step:

**Option 1: Deploy Now**
→ Follow [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md)

**Option 2: Learn Architecture First**
→ Read [ARCHITECTURE_VISUAL.md](ARCHITECTURE_VISUAL.md)

**Option 3: Understand the Platform**
→ Read [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)

---

**MedicalProMax Platform - Complete & Ready to Deploy** ✨

*For questions or issues, refer to the appropriate documentation above.*

