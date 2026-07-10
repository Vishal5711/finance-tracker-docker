#!/bin/bash

# Docker Image Size Comparison Script

echo "=== Docker Image Size Analysis ==="

# Build single-stage (traditional) image
echo "Building single-stage image..."
cat > Dockerfile.single << 'EOF'
FROM python:3.9-slim

# Install ALL dependencies in one stage
RUN apt-get update && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    pkg-config \
    default-mysql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 5000
CMD ["python", "app.py"]
EOF

docker build -f Dockerfile.single -t finance-single-stage .

# Build multi-stage image
echo "Building multi-stage image..."
docker build -f Dockerfile.prod -t finance-multi-stage .

# Show size comparison
echo ""
echo "=== SIZE COMPARISON ==="
echo "Single-stage image:"
docker images finance-single-stage --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

echo ""
echo "Multi-stage image:"
docker images finance-multi-stage --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Show detailed layers
echo ""
echo "=== LAYER ANALYSIS ==="
echo "Single-stage layers:"
docker history finance-single-stage --no-trunc

echo ""
echo "Multi-stage layers:"
docker history finance-multi-stage --no-trunc

# Cleanup
rm Dockerfile.single
