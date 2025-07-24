# 인프라 다이어그램 사용 가이드

이 프로젝트에는 두 가지 형식의 인프라 다이어그램이 포함되어 있습니다:

## 1. Mermaid 다이어그램 (infrastructure-diagram.md)

Mermaid 다이어그램은 GitHub에서 직접 렌더링되어 볼 수 있습니다. 이 다이어그램은 다음과 같은 내용을 포함하고 있습니다:
- 전체 아키텍처 다이어그램
- EKS 클러스터 구성 요소
- 네트워킹 구성
- 스토리지 구성
- IAM 및 보안 구성
- 모듈 의존성 다이어그램

## 2. Draw.io 다이어그램 (infrastructure-diagram.drawio)

Draw.io 다이어그램은 더 상세하고 시각적인 표현을 제공합니다. 이 다이어그램을 사용하려면:

1. [Draw.io 웹사이트](https://app.diagrams.net/)에 접속합니다.
2. "Open Existing Diagram"을 선택합니다.
3. "infrastructure-diagram.drawio" 파일을 업로드하거나, GitHub에서 직접 열 수 있습니다.

또는 Draw.io 데스크톱 앱을 사용하여 파일을 열 수도 있습니다.

### Draw.io 다이어그램 내용

Draw.io 다이어그램은 다음과 같은 AWS 리소스를 시각적으로 표현합니다:
- AWS 클라우드 환경
- VPC 구성
- 가용영역 및 서브넷 구성
- 인터넷 게이트웨이 및 NAT 게이트웨이
- EKS 클러스터 및 노드 그룹
- 애드온 구성 요소
- 스토리지 리소스 (EBS, EFS)
- 로드 밸런서 (ALB, NLB)
- Route53 호스트 존

### 다이어그램 수정

인프라 변경 시 다이어그램도 함께 업데이트하는 것이 좋습니다:

1. Draw.io에서 다이어그램을 수정합니다.
2. 수정된 파일을 저장하고 Git 저장소에 커밋합니다.
3. Mermaid 다이어그램도 필요에 따라 업데이트합니다.