# 스크립트 사용법

이 디렉토리에는 Terraform 배포 및 삭제를 자동화하는 스크립트가 포함되어 있습니다.

- **deploy.sh**: 현재 dev 환경으로 이동하여 `terraform init` 및 `terraform apply`를 실행합니다.
- **destroy.sh**: 현재 dev 환경으로 이동하여 `terraform destroy`를 실행합니다.

사용 예:
```bash
bash deploy.sh
bash destroy.sh
