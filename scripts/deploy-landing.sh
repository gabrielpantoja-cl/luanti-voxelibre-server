#!/bin/bash
# ===== VEGAN WETLANDS LANDING PAGE DEPLOYMENT SCRIPT =====
# This script deploys the landing page to the VPS nginx server

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ===== CONFIGURATION =====
VPS_HOST="167.172.251.27"
VPS_USER="gabriel"
VPS_PATH="/home/gabriel/vps-do/nginx/www/luanti-landing"
LOCAL_PATH="server/landing-page"
NGINX_CONTAINER="nginx-proxy"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ===== FUNCTIONS =====
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    log_info "Checking deployment requirements..."
    
    # Check if landing page directory exists
    if [[ ! -d "$LOCAL_PATH" ]]; then
        log_error "Landing page directory not found: $LOCAL_PATH"
        exit 1
    fi
    
    # Check if index.html exists
    if [[ ! -f "$LOCAL_PATH/index.html" ]]; then
        log_error "index.html not found in $LOCAL_PATH"
        exit 1
    fi
    
    # Check SSH connectivity
    if ! ssh -o ConnectTimeout=10 "$VPS_USER@$VPS_HOST" "echo 'SSH connection successful'" > /dev/null 2>&1; then
        log_error "Cannot connect to VPS via SSH. Check your SSH keys and network connection."
        exit 1
    fi
    
    log_success "All requirements check passed"
}

create_backup() {
    log_info "Creating backup of existing landing page..."
    
    BACKUP_NAME="landing-page-backup-$(date +%Y%m%d-%H%M%S)"
    
    ssh "$VPS_USER@$VPS_HOST" "
        if [[ -d '$VPS_PATH' ]]; then
            cp -r '$VPS_PATH' '/tmp/$BACKUP_NAME'
            echo 'Backup created: /tmp/$BACKUP_NAME'
        else
            echo 'No existing landing page to backup'
        fi
    " || {
        log_warning "Backup creation failed, but continuing deployment"
    }
}

prepare_vps_directory() {
    log_info "Preparing VPS directory structure..."
    
    ssh "$VPS_USER@$VPS_HOST" "
        # Create directory if it doesn't exist
        mkdir -p '$VPS_PATH'
        
        # Create nginx www directory if it doesn't exist
        mkdir -p '/home/gabriel/vps-do/nginx/www'
        
        # Set proper permissions
        chmod 755 '$VPS_PATH'
        
        echo 'VPS directory structure prepared'
    " || {
        log_error "Failed to prepare VPS directory"
        exit 1
    }
}

deploy_files() {
    log_info "Deploying landing page files to VPS..."
    
    # Use rsync for efficient file transfer
    rsync -avz --delete \
        --exclude='*.md' \
        --exclude='.git*' \
        --exclude='node_modules/' \
        --exclude='.DS_Store' \
        "$LOCAL_PATH/" "$VPS_USER@$VPS_HOST:$VPS_PATH/" || {
        log_error "File deployment failed"
        exit 1
    }
    
    log_success "Files deployed successfully"
}

update_nginx_config() {
    log_info "Updating nginx configuration..."
    
    # Check if luanti-landing.conf already exists
    CONFIG_EXISTS=$(ssh "$VPS_USER@$VPS_HOST" "
        if [[ -f '/home/gabriel/vps-do/nginx/conf.d/luanti-landing.conf' ]]; then
            echo 'exists'
        else
            echo 'missing'
        fi
    ")
    
    if [[ "$CONFIG_EXISTS" == "missing" ]]; then
        log_warning "nginx configuration file missing. Creating it..."
        
        ssh "$VPS_USER@$VPS_HOST" "
            cat > /home/gabriel/vps-do/nginx/conf.d/luanti-landing.conf << 'EOF'
# Vegan Wetlands Landing Page Configuration
server {
    listen 80;
    server_name luanti.gabrielpantoja.cl;
    
    root /var/www/luanti-landing;
    index index.html;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection \"1; mode=block\";
    add_header Referrer-Policy \"strict-origin-when-cross-origin\";
    
    # Main location
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control \"public, immutable\";
        access_log off;
    }
    
    # Favicon
    location = /favicon.ico {
        access_log off;
        log_not_found off;
    }
    
    # Robots.txt
    location = /robots.txt {
        access_log off;
        log_not_found off;
    }
    
    # Deny access to hidden files
    location ~ /\\. {
        deny all;
    }
}
EOF
            echo 'nginx configuration created'
        " || {
            log_error "Failed to create nginx configuration"
            exit 1
        }
    else
        log_info "nginx configuration already exists"
    fi
}

update_docker_compose() {
    log_info "Updating docker-compose.yml to include landing page volume..."
    
    # Check if the volume mapping is already present
    VOLUME_EXISTS=$(ssh "$VPS_USER@$VPS_HOST" "
        cd /home/gabriel/vps-do
        if grep -q 'luanti-landing' docker-compose.yml; then
            echo 'exists'
        else
            echo 'missing'
        fi
    ")
    
    if [[ "$VOLUME_EXISTS" == "missing" ]]; then
        log_warning "Adding landing page volume to docker-compose.yml..."
        
        ssh "$VPS_USER@$VPS_HOST" "
            cd /home/gabriel/vps-do
            
            # Create backup of docker-compose.yml
            cp docker-compose.yml docker-compose.yml.backup-\$(date +%Y%m%d-%H%M%S)
            
            # Add volume mapping to nginx-proxy service
            sed -i '/nginx-proxy:/,/^[[:space:]]*[^[:space:]]/ {
                /volumes:/a\\
      - ./nginx/www/luanti-landing:/var/www/luanti-landing:ro
            }' docker-compose.yml
            
            echo 'docker-compose.yml updated with landing page volume'
        " || {
            log_warning "Failed to automatically update docker-compose.yml. Manual update required."
            log_info "Please manually add this line to the nginx-proxy volumes section:"
            log_info "      - ./nginx/www/luanti-landing:/var/www/luanti-landing:ro"
        }
    else
        log_info "Landing page volume already configured in docker-compose.yml"
    fi
}

reload_nginx() {
    log_info "Reloading nginx configuration..."
    
    # Test nginx configuration first
    ssh "$VPS_USER@$VPS_HOST" "
        cd /home/gabriel/vps-do
        docker-compose exec $NGINX_CONTAINER nginx -t
    " || {
        log_error "nginx configuration test failed"
        exit 1
    }
    
    # Reload nginx
    ssh "$VPS_USER@$VPS_HOST" "
        cd /home/gabriel/vps-do
        docker-compose exec $NGINX_CONTAINER nginx -s reload
    " || {
        log_error "nginx reload failed"
        exit 1
    }
    
    log_success "nginx reloaded successfully"
}

restart_docker_services() {
    log_info "Restarting Docker services to apply volume changes..."
    
    ssh "$VPS_USER@$VPS_HOST" "
        cd /home/gabriel/vps-do
        docker-compose up -d --force-recreate $NGINX_CONTAINER
    " || {
        log_error "Failed to restart Docker services"
        exit 1
    }
    
    log_success "Docker services restarted"
}

verify_deployment() {
    log_info "Verifying deployment..."
    
    # Wait for nginx to start
    sleep 5
    
    # Test HTTP response
    RESPONSE=$(ssh "$VPS_USER@$VPS_HOST" "
        curl -s -o /dev/null -w '%{http_code}' http://localhost/ -H 'Host: luanti.gabrielpantoja.cl'
    " 2>/dev/null || echo "000")
    
    if [[ "$RESPONSE" == "200" ]]; then
        log_success "Landing page is responding correctly (HTTP $RESPONSE)"
    else
        log_warning "Landing page returned HTTP $RESPONSE - check manually"
    fi
    
    # Check if files are in place
    FILE_COUNT=$(ssh "$VPS_USER@$VPS_HOST" "
        find '$VPS_PATH' -name '*.html' -o -name '*.css' -o -name '*.js' | wc -l
    ")
    
    if [[ "$FILE_COUNT" -gt 0 ]]; then
        log_success "Deployed files found: $FILE_COUNT files"
    else
        log_error "No deployed files found in $VPS_PATH"
        exit 1
    fi
}

show_deployment_info() {
    log_success "🌱 Vegan Wetlands Landing Page Deployment Complete!"
    echo
    echo -e "${BLUE}📊 Deployment Summary:${NC}"
    echo -e "  • Landing Page URL: ${GREEN}https://luanti.gabrielpantoja.cl${NC}"
    echo -e "  • Server Address: ${GREEN}luanti.gabrielpantoja.cl:30000${NC}"
    echo -e "  • Files Location: ${YELLOW}$VPS_PATH${NC}"
    echo -e "  • nginx Config: ${YELLOW}/home/gabriel/vps-do/nginx/conf.d/luanti-landing.conf${NC}"
    echo
    echo -e "${BLUE}🎮 Next Steps:${NC}"
    echo -e "  1. Test the landing page: ${GREEN}curl -I https://luanti.gabrielpantoja.cl${NC}"
    echo -e "  2. Test game connection: Connect Luanti client to ${GREEN}luanti.gabrielpantoja.cl${NC}"
    echo -e "  3. Monitor logs: ${YELLOW}ssh $VPS_USER@$VPS_HOST 'cd /home/gabriel/vps-do && docker-compose logs -f nginx-proxy'${NC}"
    echo
}

# ===== MAIN EXECUTION =====
main() {
    log_info "🚀 Starting Vegan Wetlands Landing Page Deployment"
    echo
    
    check_requirements
    create_backup
    prepare_vps_directory
    deploy_files
    update_nginx_config
    update_docker_compose
    restart_docker_services
    verify_deployment
    show_deployment_info
    
    log_success "🎉 Deployment completed successfully!"
}

# ===== SCRIPT OPTIONS =====
case "${1:-deploy}" in
    "deploy")
        main
        ;;
    "verify")
        log_info "Running verification only..."
        verify_deployment
        ;;
    "backup")
        log_info "Creating backup only..."
        create_backup
        ;;
    "help")
        echo "Vegan Wetlands Landing Page Deployment Script"
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  deploy  - Full deployment (default)"
        echo "  verify  - Verify existing deployment"
        echo "  backup  - Create backup only"
        echo "  help    - Show this help"
        ;;
    *)
        log_error "Unknown command: $1"
        log_info "Run '$0 help' for usage information"
        exit 1
        ;;
esac