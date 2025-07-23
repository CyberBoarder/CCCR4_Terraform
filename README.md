# AWS EKS Terraform 프로젝트

AWS Well-Architected Framework를 따르는 EKS 클러스터를 Terraform으로 배포하는 코드입니다.

## 프로젝트 구조

```
eks-terraform/
├── environments/           # 환경별 변수 파일
│   └── prod.tfvars         # 프로덕션 환경 설정
├── modules/                # 모듈 디렉토리
│   ├── addons/             # 애드온 모듈
│   │   ├── aws-lb-controller/  # AWS Load Balancer Controller
│   │   ├── ebs-csi-driver/     # EBS CSI Driver
│   │   └── external-dns/       # External DNS
│   ├── eks/                # EKS 클러스터 모듈
│   └── vpc/                # VPC 모듈
├── main.tf                 # 메인 Terraform 파일
├── outputs.tf              # 출력 정의
└── variables.tf            # 변수 정의
```

## 주요 파일 설명

### 루트 디렉토리 파일

- **main.tf**: 모든 모듈을 조합하여 전체 인프라를 정의합니다.
- **variables.tf**: 프로젝트에서 사용되는 모든 변수를 정의합니다.
- **outputs.tf**: 배포 후 출력되는 값들을 정의합니다.

### 모듈 파일

#### VPC 모듈 (`modules/vpc/`)
- **main.tf**: AWS VPC, 서브넷, NAT 게이트웨이 등을 정의합니다.
- **variables.tf**: VPC 모듈에서 사용되는 변수를 정의합니다.
- **outputs.tf**: VPC ID, 서브넷 ID 등을 출력합니다.

#### EKS 모듈 (`modules/eks/`)
- **main.tf**: EKS 클러스터, 노드 그룹, 보안 그룹 등을 정의합니다.
- **variables.tf**: EKS 모듈에서 사용되는 변수를 정의합니다.
- **outputs.tf**: 클러스터 엔드포인트, OIDC 발급자 URL 등을 출력합니다.

#### AWS Load Balancer Controller 모듈 (`modules/addons/aws-lb-controller/`)
- **main.tf**: AWS Load Balancer Controller 배포 및 IAM 역할을 정의합니다.
- **variables.tf**: 모듈에서 사용되는 변수를 정의합니다.
- **outputs.tf**: IAM 역할 ARN을 출력합니다.

#### EBS CSI Driver 모듈 (`modules/addons/ebs-csi-driver/`)
- **main.tf**: EBS CSI Driver 배포, IAM 역할, 스토리지 클래스를 정의합니다.
- **variables.tf**: 모듈에서 사용되는 변수를 정의합니다.
- **outputs.tf**: IAM 역할 ARN과 스토리지 클래스 이름을 출력합니다.

#### External DNS 모듈 (`modules/addons/external-dns/`)
- **main.tf**: External DNS 배포 및 IAM 역할을 정의합니다.
- **variables.tf**: 모듈에서 사용되는 변수를 정의합니다.
- **outputs.tf**: IAM 역할 ARN을 출력합니다.

## 배포 방법

### 사전 요구사항

- Terraform v1.0.0 이상
- AWS CLI 구성 완료
- kubectl 설치 (선택사항)

### 배포 단계

1. **Terraform 초기화**:
   ```bash
   cd eks-terraform
   terraform init
   ```

2. **배포 계획 확인**:
   ```bash
   terraform plan -var-file=environments/prod.tfvars
   ```

3. **인프라 배포**:
   ```bash
   terraform apply -var-file=environments/prod.tfvars
   ```

4. **kubeconfig 설정** (선택사항):
   ```bash
   aws eks update-kubeconfig --region ap-northeast-2 --name prod-eks
   ```

## 유지보수 및 확장 가이드

### 노드 그룹 수정

`environments/prod.tfvars` 파일에서 노드 그룹 설정을 수정할 수 있습니다:

```hcl
node_groups = {
  application = {
    instance_types = ["c5.2xlarge"]
    min_size       = 3
    max_size       = 10
    desired_size   = 3
    # 다른 설정 추가
  }
}
```

### 새로운 애드온 추가

1. `modules/addons/` 디렉토리에 새 모듈 디렉토리 생성
2. `main.tf`, `variables.tf`, `outputs.tf` 파일 작성
3. 루트 `main.tf` 파일에 모듈 추가:

```hcl
module "new_addon" {
  source = "./modules/addons/new-addon"
  
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  
  depends_on = [module.eks]
}
```

### 새로운 환경 추가

`environments/` 디렉토리에 새 환경 변수 파일(예: `dev.tfvars`)을 생성하고 환경별 설정을 정의합니다.

## 인스턴스 사이즈 선택 기준

- **관리용 노드 그룹**: `m5.large` - 기본 관리 작업에 적합한 범용 인스턴스
- **애플리케이션 노드 그룹**: `c5.2xlarge` - 컴퓨팅 집약적 워크로드에 최적화된 인스턴스
- **모니터링 노드 그룹**: `r5.xlarge` - 메모리 집약적 워크로드에 최적화된 인스턴스

## AWS Well-Architected Framework 준수 사항

- **운영 우수성**: 모듈화된 구조로 유지보수 용이
- **보안**: IRSA 활성화, 클러스터 로깅, 적절한 보안 그룹 설정
- **안정성**: 다중 AZ 구성, 자동 확장 노드 그룹
- **성능 효율성**: 워크로드에 맞는 인스턴스 타입 선택
- **비용 최적화**: 필요에 따른 노드 그룹 구성, 자동 확장 설정

## 주의사항

- 프로덕션 환경에 배포하기 전에 항상 `terraform plan`으로 변경 사항을 확인하세요.
- 클러스터 업그레이드는 신중하게 계획하고 실행해야 합니다.
- IAM 역할과 권한은 최소 권한 원칙을 따라야 합니다.