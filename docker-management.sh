#!/bin/bash

# Docker Security and Management Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Docker Finance App Management Script ===${NC}"

# Function to scan Docker images for vulnerabilities
scan_images() {
    echo -e "${YELLOW}Scanning Docker images for vulnerabilities...${NC}"
    
    # Install Trivy if not present
    if ! command -v trivy &> /dev/null; then
        echo "Installing Trivy scanner..."
        sudo apt-get update
        sudo apt-get install wget apt-transport-https gnupg lsb-release -y
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
        echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
        sudo apt-get update
        sudo apt-get install trivy -y
    fi
    
    # Scan images
    echo "Scanning application image..."
    trivy image finance_backend:latest
    
    echo "Scanning MySQL image..."
    trivy image mysql:8.0
    
    echo "Scanning Redis image..."
    trivy image redis:7-alpine
    
    echo "Scanning Nginx image..."
    trivy image nginx:alpine
}

# Function to build all environments
build_all() {
    echo -e "${YELLOW}Building all environments...${NC}"
    
    # Build production
    echo "Building production environment..."
    docker-compose -f docker-compose.yml build --no-cache
    
    # Build staging
    echo "Building staging environment..."
    docker-compose -f docker-compose.staging.yml build --no-cache
    
    echo -e "${GREEN}All environments built successfully!${NC}"
}

# Function to deploy staging
deploy_staging() {
    echo -e "${YELLOW}Deploying to staging environment...${NC}"
    docker-compose -f docker-compose.staging.yml --env-file .env.dev up -d
    echo -e "${GREEN}Staging environment deployed on port 5001${NC}"
}

# Function to deploy production
deploy_production() {
    echo -e "${YELLOW}Deploying to production environment...${NC}"
    docker-compose --env-file .env.prod up -d
    echo -e "${GREEN}Production environment deployed on port 80${NC}"
}

# Function to run tests
run_tests() {
    echo -e "${YELLOW}Running tests in staging environment...${NC}"
    docker-compose -f docker-compose.staging.yml --profile testing run --rm test_runner
}

# Function to check health
check_health() {
    echo -e "${YELLOW}Checking container health...${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    echo -e "\n${YELLOW}Health checks:${NC}"
    curl -s http://localhost/health && echo -e " ${GREEN}✓ Nginx healthy${NC}" || echo -e " ${RED}✗ Nginx unhealthy${NC}"
    curl -s http://localhost/api/summary > /dev/null && echo -e " ${GREEN}✓ Backend healthy${NC}" || echo -e " ${RED}✗ Backend unhealthy${NC}"
}

# Function to view logs
view_logs() {
    echo -e "${YELLOW}Recent application logs:${NC}"
    docker-compose logs --tail=50 backend
}

# Function to backup database
backup_db() {
    echo -e "${YELLOW}Creating database backup...${NC}"
    docker exec finance_mysql mysqldump -u root -p$(grep MYSQL_ROOT_PASSWORD .env.prod | cut -d '=' -f2) finance_db > backup_$(date +%Y%m%d_%H%M%S).sql
    echo -e "${GREEN}Database backup created${NC}"
}

# Function to clean up
cleanup() {
    echo -e "${YELLOW}Cleaning up Docker resources...${NC}"
    docker system prune -f
    docker volume prune -f
    echo -e "${GREEN}Cleanup completed${NC}"
}

# Function to monitor resources
monitor() {
    echo -e "${YELLOW}Container resource usage:${NC}"
    docker stats --no-stream
}

# Function to show network info
network_info() {
    echo -e "${YELLOW}Docker networks:${NC}"
    docker network ls
    echo -e "\n${YELLOW}Finance network details:${NC}"
    docker network inspect finance_network 2>/dev/null || echo "Finance network not found"
}

# Function to show volumes
volume_info() {
    echo -e "${YELLOW}Docker volumes:${NC}"
    docker volume ls
    echo -e "\n${YELLOW}Volume usage:${NC}"
    docker system df
}

# Main menu
case "$1" in
    "scan")
        scan_images
        ;;
    "build")
        build_all
        ;;
    "staging")
        deploy_staging
        ;;
    "production")
        deploy_production
        ;;
    "test")
        run_tests
        ;;
    "health")
        check_health
        ;;
    "logs")
        view_logs
        ;;
    "backup")
        backup_db
        ;;
    "cleanup")
        cleanup
        ;;
    "monitor")
        monitor
        ;;
    "network")
        network_info
        ;;
    "volumes")
        volume_info
        ;;
    *)
        echo "Usage: $0 {scan|build|staging|production|test|health|logs|backup|cleanup|monitor|network|volumes}"
        echo ""
        echo "Commands:"
        echo "  scan       - Scan Docker images for security vulnerabilities"
        echo "  build      - Build all Docker images"
        echo "  staging    - Deploy to staging environment"
        echo "  production - Deploy to production environment"
        echo "  test       - Run tests in staging environment"
        echo "  health     - Check container health status"
        echo "  logs       - View application logs"
        echo "  backup     - Backup database"
        echo "  cleanup    - Clean up Docker resources"
        echo "  monitor    - Monitor container resource usage"
        echo "  network    - Show network information"
        echo "  volumes    - Show volume information"
        exit 1
        ;;
esac
