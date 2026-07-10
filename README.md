# Personal Finance Tracker - Complete Docker Implementation

A comprehensive 3-tier web application demonstrating advanced Docker features including multi-stage builds, compose orchestration, volumes, networks, security scanning, and monitoring.

## 🏗️ **Architecture Overview**

### **3-Tier Architecture**
- **Tier 1 (Presentation)**: Nginx reverse proxy + HTML/CSS/JS frontend
- **Tier 2 (Application)**: Flask API with business logic
- **Tier 3 (Data)**: MySQL database with Redis caching

### **Docker Features Implemented**
- ✅ Multi-stage Dockerfiles (production optimization)
- ✅ Docker Compose orchestration
- ✅ Named volumes for data persistence
- ✅ Custom networks with IP management
- ✅ Health checks and monitoring
- ✅ Security scanning with Trivy
- ✅ Environment-specific configurations
- ✅ Staging and production environments

## 🚀 **Quick Start**

### **Development Environment**
```bash
# Clone and navigate to project
cd finance-tracker

# Start development environment
docker-compose -f docker-compose.staging.yml --env-file .env.dev up -d

# Access: http://localhost:5001
```

### **Production Environment**
```bash
# Build and deploy production
chmod +x docker-management.sh
./docker-management.sh build
./docker-management.sh production

# Access: http://localhost
```

## 🛠️ **Docker Management Script**

The `docker-management.sh` script provides comprehensive Docker operations:

```bash
# Security scanning
./docker-management.sh scan

# Build all environments
./docker-management.sh build

# Deploy staging
./docker-management.sh staging

# Deploy production
./docker-management.sh production

# Run tests
./docker-management.sh test

# Check health
./docker-management.sh health

# View logs
./docker-management.sh logs

# Monitor resources
./docker-management.sh monitor

# Network information
./docker-management.sh network

# Volume information
./docker-management.sh volumes

# Cleanup resources
./docker-management.sh cleanup

# Database backup
./docker-management.sh backup
```

## 🐳 **Docker Components**

### **Multi-Stage Builds**
- `Dockerfile.prod`: Production-optimized multi-stage build
- `Dockerfile.dev`: Development build with debugging tools

### **Docker Compose Files**
- `docker-compose.yml`: Production environment
- `docker-compose.staging.yml`: Staging environment

### **Networks**
- `finance_network`: Main application network (172.20.0.0/16)
- `monitoring_network`: Isolated monitoring network

### **Volumes**
- `mysql_data`: Database persistence
- `redis_data`: Cache persistence
- `app_logs`: Application logs

## 🔒 **Security Features**

### **Image Security**
- Non-root user execution
- Multi-stage builds (reduced attack surface)
- Security scanning with Trivy
- Minimal base images

### **Network Security**
- Isolated networks
- Rate limiting in Nginx
- Security headers

### **Environment Security**
- Environment-specific secrets
- Encrypted communications ready

## 📊 **Monitoring & Observability**

### **Health Checks**
- MySQL: `mysqladmin ping`
- Redis: `redis-cli ping`
- Backend: `/api/summary` endpoint
- Nginx: Custom health endpoint

### **Monitoring Stack**
- **Prometheus**: Metrics collection (port 9090)
- **Grafana**: Visualization dashboard (port 3000)
- **Built-in Docker stats**: Resource monitoring

## 🗄️ **Volumes & Data Persistence**

### **Named Volumes**
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect mysql_data

# Backup volume
docker run --rm -v mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql_backup.tar.gz /data
```

## 🌐 **Networks**

### **Custom Networks**
```bash
# Inspect networks
docker network ls
docker network inspect finance_network

# Container communication
docker exec finance_backend ping mysql
```

## 🔧 **Environment Management**

### **Environment Files**
- `.env.prod`: Production configuration
- `.env.dev`: Development configuration

### **Environment Variables**
- Database credentials
- Flask configuration
- Redis settings
- Security keys

## 🧪 **Testing**

### **Run Tests in Staging**
```bash
# Run all tests
docker-compose -f docker-compose.staging.yml --profile testing run --rm test_runner

# Interactive testing
docker-compose -f docker-compose.staging.yml exec backend_staging python -m pytest
```

## 📈 **Scaling & Performance**

### **Horizontal Scaling**
```bash
# Scale backend services
docker-compose up -d --scale backend=3
```

### **Resource Limits**
```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
```

## 🔍 **Troubleshooting**

### **Common Commands**
```bash
# View container logs
docker-compose logs -f backend

# Execute into container
docker-compose exec backend bash

# Check container status
docker-compose ps

# Restart services
docker-compose restart backend
```

### **Health Checks**
```bash
# Manual health check
curl http://localhost/api/summary
curl http://localhost/health
```

## 📋 **Port Mapping**

| Service | Port | Description |
|---------|------|-------------|
| Nginx | 80 | Production web server |
| Backend | 5000 | Flask application |
| Backend Staging | 5001 | Staging Flask app |
| MySQL | 3306 | Production database |
| MySQL Staging | 3307 | Staging database |
| Redis | 6379 | Cache server |
| Prometheus | 9090 | Metrics server |
| Grafana | 3000 | Monitoring dashboard |

## 🚦 **CI/CD Integration**

### **GitHub Actions Example**
```yaml
- name: Build and test
  run: |
    docker-compose -f docker-compose.staging.yml build
    docker-compose -f docker-compose.staging.yml --profile testing run test_runner

- name: Security scan
  run: |
    ./docker-management.sh scan
```

## 📚 **Learning Objectives Covered**

- [x] Docker containerization
- [x] Multi-stage builds for optimization
- [x] Docker Compose orchestration
- [x] Volume management and persistence
- [x] Network isolation and communication
- [x] Security scanning and best practices
- [x] Environment separation (dev/staging/prod)
- [x] Health monitoring and logging
- [x] Scaling and load balancing
- [x] CI/CD integration patterns

This implementation provides a complete Docker learning experience with real-world best practices!
