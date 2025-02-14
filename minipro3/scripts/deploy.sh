#!/bin/bash
# deploy.sh: 특정 환경 (예: dev) 배포 자동화 스크립트

# 현재 스크립트의 디렉토리 기준으로 환경 디렉토리로 이동
cd "$(dirname "$0")/../env/dev" || exit

echo "Terraform init in dev environment..."
terraform init

echo "Terraform apply in dev environment..."
terraform apply -auto-approve
