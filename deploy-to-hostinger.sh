#!/bin/bash

# Hostinger Deployment Script
# This script prepares your application for Hostinger deployment

echo "=========================================="
echo "CFAS Exam System - Hostinger Deployment"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if required tools are installed
command -v composer >/dev/null 2>&1 || { echo -e "${RED}Error: Composer is not installed${NC}" >&2; exit 1; }
command -v npm >/dev/null 2>&1 || { echo -e "${RED}Error: npm is not installed${NC}" >&2; exit 1; }

echo -e "${YELLOW}Step 1: Preparing Backend (Laravel)${NC}"
cd backend

# Install production dependencies
echo "Installing production dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction

# Copy environment file
if [ ! -f .env ]; then
    echo "Creating .env file from .env.hostinger..."
    cp .env.hostinger .env
    echo -e "${YELLOW}WARNING: Please update .env with your Hostinger database credentials!${NC}"
else
    echo ".env file already exists, skipping..."
fi

# Generate application key if not set
if ! grep -q "APP_KEY=base64:" .env; then
    echo "Generating application key..."
    php artisan key:generate --force
fi

# Clear and optimize
echo "Optimizing Laravel..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

cd ..

echo ""
echo -e "${YELLOW}Step 2: Building Frontend (Vue.js)${NC}"
cd frontend

# Install dependencies
echo "Installing frontend dependencies..."
npm install

# Copy production environment
if [ ! -f .env.production ]; then
    echo "Creating .env.production from .env.hostinger..."
    cp .env.hostinger .env.production
    echo -e "${YELLOW}WARNING: Please update .env.production with your domain!${NC}"
fi

# Build for production
echo "Building frontend for production..."
npm run build

# Copy .htaccess to dist
echo "Copying .htaccess to dist folder..."
cp ../frontend/dist.htaccess dist/.htaccess

cd ..

echo ""
echo -e "${YELLOW}Step 3: Preparing ML Service${NC}"

# Copy ML .htaccess
cp ml_model/.htaccess.hostinger ml_model/.htaccess

echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Preparation Complete!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Update backend/.env with your Hostinger database credentials"
echo "2. Update frontend/.env.production with your domain"
echo "3. Upload files to Hostinger:"
echo "   - backend/ → public_html/api/"
echo "   - frontend/dist/ → public_html/"
echo "   - ml_model/ → public_html/ml-api/"
echo "   - hostinger-root.htaccess → public_html/.htaccess"
echo ""
echo "4. SSH into Hostinger and run:"
echo "   cd public_html/api"
echo "   php artisan migrate --force"
echo "   php artisan config:cache"
echo "   php artisan route:cache"
echo "   chmod -R 755 storage bootstrap/cache"
echo ""
echo "5. Install Python dependencies:"
echo "   cd public_html/ml-api"
echo "   pip3 install --user -r requirements.txt"
echo ""
echo "See HOSTINGER_DEPLOYMENT_GUIDE.md for detailed instructions."
echo ""
