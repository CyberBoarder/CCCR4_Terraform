# AWS EKS Terraform 프로젝트

AWS Well-Architected Framework를 따르는 EKS 클러스터를 Terraform으로 배포하는 코드입니다.
<img width="1082" height="951" alt="test drawio" src="https://github.com/user-attachments/assets/c24c9360-5189-4d7b-9997-6eb6629e2475" />

## 프로젝트 구조

```
eks-terraform/
├── environments/           # 환경별 변수 파일
│   └── prod.tfvars         # 프로덕션 환경 설정
├── modules/                # 모듈 디렉토리
│   ├── addons/             # 애드온 모듈
│   │   ├── aws-lb-controller/  # AWS Load Balancer Controller
│   │   ├── ebs-csi-driver/     # EBS CSI Driver
│   │   ├── efs-csi-driver/     # EFS CSI Driver (신규)
│   │   ├── external-dns/       # External DNS
│   │   └── route53/            # Route53 (신규)
│   ├── eks/                # EKS 클러스터 모듈
│   └── vpc/                # VPC 모듈
├── .gitignore              # Git 제외 파일 설정
├── main.tf                 # 메인 Terraform 파일
├── outputs.tf              # 출력 정의
├── variables.tf            # 변수 정의
└── versions.tf             # Terraform 및 Provider 버전 정의
```

## 주요 파일 설명

### 루트 디렉토리 파일

- **main.tf**: 모든 모듈을 조합하여 전체 인프라를 정의합니다.
- **variables.tf**: 프로젝트에서 사용되는 모든 변수를 정의합니다.
- **outputs.tf**: 배포 후 출력되는 값들을 정의합니다.
- **.gitignore**: Git에서 제외할 파일 및 디렉토리를 정의합니다.

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

#### Route53 모듈 (`modules/addons/route53/`) - 신규
- **main.tf**: Route53 호스트 존 및 DNS 레코드를 정의합니다.
- **variables.tf**: 모듈에서 사용되는 변수를 정의합니다.
- **outputs.tf**: 호스트 존 ID와 네임서버 정보를 출력합니다.

#### EFS CSI Driver 모듈 (`modules/addons/efs-csi-driver/`) - 신규
- **main.tf**: EFS 파일 시스템, 마운트 타겟, CSI 드라이버 배포 및 IAM 역할을 정의합니다.
- **variables.tf**: 모듈에서 사용되는 변수를 정의합니다.
- **outputs.tf**: IAM 역할 ARN, 파일 시스템 ID, 스토리지 클래스 이름을 출력합니다.

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

- **운영 우수성**: 모듈화된 구조로 유지보수 용이, Route53을 통한 DNS 관리 자동화
- **보안**: IRSA 활성화, 클러스터 로깅, 적절한 보안 그룹 설정
- **안정성**: 다중 AZ 구성, 자동 확장 노드 그룹, EFS를 통한 영구 스토리지 제공
- **성능 효율성**: 워크로드에 맞는 인스턴스 타입 선택, 다양한 스토리지 옵션(EBS, EFS) 제공
- **비용 최적화**: 필요에 따른 노드 그룹 구성, 자동 확장 설정, 적절한 스토리지 클래스 선택

## 새로 추가된 기능

### 1. Route53 호스트 존 관리

Route53 모듈은 다음 기능을 제공합니다:
- 호스트 존 생성 및 관리
- API 서버용 DNS 레코드 자동 생성
- 애플리케이션용 와일드카드 DNS 레코드 자동 생성

현재는 테스트 도메인(example.com)을 사용하며, 추후 실제 도메인으로 변경할 수 있습니다.

### 2. EFS CSI Driver

EFS CSI Driver 모듈은 다음 기능을 제공합니다:
- EFS 파일 시스템 자동 생성
- 모든 서브넷에 마운트 타겟 자동 생성
- 필요한 보안 그룹 구성
- EFS CSI Driver 배포 및 구성
- EFS 스토리지 클래스 자동 생성

EFS는 다음과 같은 용도에 적합합니다:
- 영구 저장이 필요한 데이터
- 다중 파드에서 동시 접근해야 하는 데이터
- 워크플로우 공유 데이터
- CI/CD 파이프라인 아티팩트

## 주의사항 및 문제 해결

### Git 저장소 관리

- `.terraform` 디렉토리와 `.terraform.lock.hcl` 파일은 `.gitignore`에 추가되어 Git에서 제외됩니다.
- 이는 대용량 프로바이더 바이너리 파일(특히 AWS 프로바이더는 700MB 이상)이 GitHub의 파일 크기 제한(100MB)을 초과하기 때문입니다.
- 팀원들은 각자 `terraform init`을 실행하여 필요한 프로바이더와 모듈을 로컬에 설치해야 합니다.

### 발생 가능한 문제와 해결 방법

1. **대용량 파일 푸시 오류**:
   - 문제: `.terraform` 디렉토리의 대용량 파일이 Git에 추가되어 푸시 실패
   - 해결: `.gitignore` 파일에 `.terraform/` 및 관련 파일 추가, `git filter-branch` 명령으로 히스토리에서 제거

2. **Terraform 초기화 오류**:
   - 문제: 모듈 또는 프로바이더 다운로드 실패
   - 해결: 네트워크 연결 확인, AWS 자격 증명 확인, Terraform 버전 확인

3. **EKS 클러스터 생성 실패**:
   - 문제: IAM 권한 부족 또는 서비스 할당량 초과
   - 해결: 필요한 IAM 권한 확인, AWS 서비스 할당량 증가 요청

4. **애드온 배포 실패**:
   - 문제: OIDC 프로바이더 설정 오류 또는 IAM 역할 권한 부족
   - 해결: OIDC 프로바이더 설정 확인, IAM 역할 정책 검토

- 프로덕션 환경에 배포하기 전에 항상 `terraform plan`으로 변경 사항을 확인하세요.
- 클러스터 업그레이드는 신중하게 계획하고 실행해야 합니다.
- IAM 역할과 권한은 최소 권한 원칙을 따라야 합니다.
- Route53 호스트 존을 사용하려면 도메인을 소유하고 있어야 합니다.
- EFS 사용 시 적절한 백업 전략을 계획하세요.