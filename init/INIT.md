# Project-Docs Init — cloud-agent

> 이 문서는 에이전트(Claude, Gemini 등)가 프로젝트 문서를 세팅할 때 따르는 부트스트랩 체크리스트이다.
> 순서대로 실행하며, 각 Phase 완료 후 다음으로 넘어간다.

- **프로젝트명**: cloud-agent
- **브랜치**: cloud-agent

---

## Phase 1: 프로젝트 탐색 (Discovery)

프로젝트 루트를 스캔하여 아래 정보를 수집한다.

### 1-1. 프로젝트 메타데이터

| 항목 | 탐지 방법 | 폴백 |
|------|-----------|------|
| 프로젝트 설명 | README.md 첫 줄, package.json의 description | 사용자에게 질문 |

### 1-2. 서브 프로젝트 식별

루트 하위 디렉토리를 순회하며 아래 마커 파일로 서브 프로젝트를 식별한다.

| 마커 파일 | 판정 |
|-----------|------|
| package.json | Node.js 계열 |
| build.gradle / build.gradle.kts | JVM (Kotlin/Java) |
| pom.xml | JVM (Maven) |
| requirements.txt / pyproject.toml / setup.py | Python |
| Cargo.toml | Rust |
| go.mod | Go |
| *.csproj / *.sln | .NET |
| Dockerfile | 컨테이너 (보조 판정) |

**출력 형식:**
```
[발견] 서브 프로젝트 N개
  1. {폴더명} — {언어/프레임워크} ({마커 파일})
  2. {폴더명} — {언어/프레임워크} ({마커 파일})
```

### 1-3. 기술 스택 상세 파악

각 서브 프로젝트에서 추가 탐지한다.

| 대상 | 탐지 소스 |
|------|-----------|
| 프레임워크 | dependencies (package.json, build.gradle 등) |
| 언어 버전 | .nvmrc, .python-version, .java-version, .tool-versions |
| 패키지 매니저 | lock 파일 (package-lock.json, yarn.lock, pnpm-lock.yaml 등) |
| 린터/포맷터 | .eslintrc, .prettierrc, ruff.toml, ktlint 설정 등 |
| 테스트 프레임워크 | jest.config, pytest.ini, build.gradle의 test 블록 등 |

### 1-4. 인프라 탐지 (선택)

| 마커 | 판정 |
|------|------|
| docker-compose.yml | 로컬 개발 환경 정의 있음 |
| k8s/, helm/ | Kubernetes 배포 |
| .github/workflows/ | GitHub Actions CI/CD |
| Jenkinsfile | Jenkins CI/CD |
| terraform/, .tf | IaC (Terraform) |

### 1-5. Discovery 결과 확인

수집한 정보를 사용자에게 요약 출력하고 확인받는다.

```
=== Project Discovery 결과 ===

프로젝트명: cloud-agent
서브 프로젝트: {N}개
  - {sub1}: {stack}
  - {sub2}: {stack}
인프라: {infra 요약}

이 정보가 맞습니까? 수정할 부분이 있으면 알려주세요.
```

---

## Phase 2: 문서 생성

Discovery 결과를 기반으로 project-docs/ 하위 문서를 자동 생성한다.

### 2-1. architecture/overview.md
Discovery 데이터로 구성 요소, 데이터 레이어, 인프라 섹션을 채운다.

### 2-2. conventions/code-style.md
탐지된 언어별로 해당 섹션만 추가한다. 공통(Naming, Git Convention)은 유지.

### 2-3. setup/getting-started.md
탐지된 런타임/도구 버전, 패키지 매니저 명령어, 실행 명령어를 채운다.

### 2-4. todo/README.md
owner 분배 기준을 사용자에게 질문하여 설정한다.
- "에이전트에게 위임할 작업 유형을 알려주세요 (예: CRUD, 테스트, 보일러플레이트 등)"
- 답변 없으면 기본값 사용 (init/defaults/owner-template.md 참조)

---

## Phase 3: 검증

- [ ] 생성된 문서 목록을 사용자에게 출력
- [ ] "검토 후 수정할 부분을 알려주세요" 안내
- [ ] 수정 요청 반영 후 커밋

### 최종 커밋

```bash
git add .
git commit -m "docs: Discovery 완료 (cloud-agent)"
```

---

## 이 INIT을 실행하는 방법

에이전트에게 아래와 같이 지시한다:

```
project-docs/init/INIT.md를 읽고 순서대로 실행해줘.
```
