#!/bin/bash
# destroy.sh: 특정 환경 (예: dev) 리소스 삭제 자동화 스크립트

cd "$(dirname "$0")/../env/dev" || exit

echo "Terraform destroy in dev environment..."
terraform destroy -auto-approve
