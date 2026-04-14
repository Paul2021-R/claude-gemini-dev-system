#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# init.sh — CGDS (Claude-Gemini Dev System)
# project-docs/ 내부에서 실행한다.
# ============================================================

DOCS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "${DOCS_DIR}")"

# ---- 색상 ----
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
done_() { echo -e "${GREEN}[DONE]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

# ============================================================
# 로고
# ============================================================
echo ""
echo -e "${MAGENTA}${BOLD}"
cat << 'LOGO'
   ╔═══════════════════════════════════════════════════╗
   ║                                                   ║
   ║    ██████╗ ██████╗ ██████╗ ███████╗               ║
   ║   ██╔════╝██╔════╝ ██╔══██╗██╔════╝               ║
   ║   ██║     ██║  ███╗██║  ██║███████╗               ║
   ║   ██║     ██║   ██║██║  ██║╚════██║               ║
   ║   ╚██████╗╚██████╔╝██████╔╝███████║               ║
   ║    ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝               ║
   ║                                                   ║
   ║       Claude - Gemini   Dev  System               ║
   ║       Project Docs Initializer                    ║
   ║                                                   ║
   ╚═══════════════════════════════════════════════════╝
LOGO
echo -e "${NC}"
echo -e "   ${DIM}Multi-agent project documentation framework${NC}"
echo ""

# ============================================================
# Phase 0: 사전 확인 + 프로젝트명 입력
# ============================================================

# init/ 디렉토리 존재 여부로 이미 초기화됐는지 판단
if [ -d "${DOCS_DIR}/init" ]; then
  warn "이미 초기화된 project-docs입니다."
  read -rp "   재초기화 하시겠습니까? 기존 내용이 덮어씌워집니다 (y/N): " confirm
  if [[ ! "${confirm}" =~ ^[yY]$ ]]; then
    echo "   취소되었습니다."
    exit 0
  fi
  echo ""
fi

FOLDER_NAME="$(basename "${PROJECT_ROOT}")"
echo -e "  ${BOLD}프로젝트 설정${NC}"
echo ""
read -rp "   프로젝트명 (기본값: ${FOLDER_NAME}): " PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:-${FOLDER_NAME}}"

PROJECT_SLUG="$(echo "${PROJECT_NAME}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')"

echo ""
info "프로젝트: ${BOLD}${PROJECT_NAME}${NC}"
info "브랜치명: ${BOLD}${PROJECT_SLUG}${NC}"
echo ""

# ============================================================
# Phase 1: 디렉토리 생성
# ============================================================
info "디렉토리 구조 생성 중..."

dirs=(
  "init/defaults"
  "architecture"
  "api"
  "conventions"
  "setup"
  "decisions"
  "roadmap"
  "todo"
  "temporary"
)

for d in "${dirs[@]}"; do
  mkdir -p "${DOCS_DIR}/${d}"
done

done_ "디렉토리 생성 완료"

# ============================================================
# Phase 2: 골격 파일 생성
# ============================================================
info "골격 파일 생성 중..."

QUARTER="Q$(( ($(date +%-m) - 1) / 3 + 1 )) $(date +%Y)"
TODAY="$(date +%Y-%m-%d)"

# ---- INIT.md ----
cat > "${DOCS_DIR}/init/INIT.md" << HEREDOC
# Project-Docs Init — ${PROJECT_NAME}

> 이 문서는 에이전트(Claude, Gemini 등)가 프로젝트 문서를 세팅할 때 따르는 부트스트랩 체크리스트이다.
> 순서대로 실행하며, 각 Phase 완료 후 다음으로 넘어간다.

- **프로젝트명**: ${PROJECT_NAME}
- **브랜치**: ${PROJECT_SLUG}

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
\`\`\`
[발견] 서브 프로젝트 N개
  1. {폴더명} — {언어/프레임워크} ({마커 파일})
  2. {폴더명} — {언어/프레임워크} ({마커 파일})
\`\`\`

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

\`\`\`
=== Project Discovery 결과 ===

프로젝트명: ${PROJECT_NAME}
서브 프로젝트: {N}개
  - {sub1}: {stack}
  - {sub2}: {stack}
인프라: {infra 요약}

이 정보가 맞습니까? 수정할 부분이 있으면 알려주세요.
\`\`\`

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

\`\`\`bash
git add .
git commit -m "docs: Discovery 완료 (${PROJECT_NAME})"
\`\`\`

---

## 이 INIT을 실행하는 방법

에이전트에게 아래와 같이 지시한다:

\`\`\`
project-docs/init/INIT.md를 읽고 순서대로 실행해줘.
\`\`\`
HEREDOC

# ---- owner 기본값 ----
cat > "${DOCS_DIR}/init/defaults/owner-template.md" << 'HEREDOC'
# Owner 분배 기본값

> init에서 사용자가 별도 지정하지 않을 경우 이 기본값을 적용한다.

## 사람 (human) — 직접 작성

- 서비스 핵심 비즈니스 로직
- 보안/인증 설계
- 아키텍처 결정이 필요한 작업
- 외부 서비스 연동 설계
- 데이터 모델링 (스키마 설계)

## 에이전트 (agent) — 위임 가능

- CRUD 엔드포인트, DTO/엔티티 생성
- 테스트 코드 작성
- 설정 파일, 마이그레이션 스크립트
- API 문서화
- 린트/포맷터 설정
- 보일러플레이트, 유틸리티 함수
- CI/CD 파이프라인 스크립트
- 리팩토링 (명확한 지시 하에)
HEREDOC

# ---- architecture ----
cat > "${DOCS_DIR}/architecture/overview.md" << 'HEREDOC'
# Architecture Overview

<!-- 이 문서는 init에서 에이전트가 Discovery 결과로 채운다 -->

## 구성 요소

## 데이터 레이어

## 인프라
HEREDOC

# ---- api ----
cat > "${DOCS_DIR}/api/README.md" << 'HEREDOC'
# API Documentation

## Overview

<!-- 서브 프로젝트별 서버 URL 및 포트 -->

---

### [TODO] 상세 엔드포인트 명세

정의되는 대로 아래 항목을 채울 예정이다.
HEREDOC

# ---- conventions ----
cat > "${DOCS_DIR}/conventions/code-style.md" << 'HEREDOC'
# Code Style & Conventions

## General

<!-- init에서 탐지된 언어 목록과 들여쓰기 규칙이 채워진다 -->

## Naming

| 대상 | 규칙 | 예시 |
|------|------|------|
| 변수/함수 | camelCase | `getUserById` |
| 클래스 | PascalCase | `UserService` |
| 상수 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| 파일 (TS) | kebab-case | `user-service.ts` |
| DB 컬럼 | snake_case | `created_at` |

<!-- init에서 탐지된 언어별 섹션이 아래에 추가된다 -->

## Git Convention

### Branch Structure
- `main` — 배포 전용. 직접 커밋 금지
- `develop` — 개발 메인. 모든 PR의 기본 타겟
- `feature/YYYYMMDD-이슈번호` — 기능 개발
- `bug/YYYYMMDD-이슈번호` — 버그 수정
- `chore/YYYYMMDD-이슈번호` — 설정/환경 작업
- `hotfix/YYYYMMDD-이슈번호` — 긴급 수정
- `release/vX.Y.Z` — 배포 점검

### Commit Message
- 형식: `type: 설명`
- type: feat, fix, refactor, docs, test, chore, style, rename, remove
- 한글 허용, type 접두사는 영문 소문자 고정
HEREDOC

# ---- setup ----
cat > "${DOCS_DIR}/setup/getting-started.md" << 'HEREDOC'
# Getting Started

<!-- 이 문서는 init에서 에이전트가 Discovery 결과로 채운다 -->

## Prerequisites

## Repository Setup

## Environment Variables

> **주의**: `.env` 파일은 절대 커밋하지 않는다.

## Running Locally

## Troubleshooting
HEREDOC

# ---- decisions ----
cat > "${DOCS_DIR}/decisions/ADR-000-template.md" << 'HEREDOC'
## ADR-000: Template

- **status**: template
- **date**: YYYY-MM-DD
- **context**: 어떤 문제/상황에서 결정이 필요했는가
- **decision**: 무엇을 결정했는가
- **alternatives**: 검토했으나 채택하지 않은 대안
- **consequences**: 이 결정의 결과와 트레이드오프
HEREDOC

cat > "${DOCS_DIR}/decisions/template.md" << 'HEREDOC'
# ADR-{NUMBER}: {제목}

## Status
<!-- Proposed | Accepted | Deprecated | Superseded -->

## Date
<!-- YYYY-MM-DD -->

## Context
<!-- 이 결정이 필요한 배경과 문제 상황을 기술 -->

## Decision
<!-- 어떤 결정을 내렸는지 기술 -->

## Consequences

### Positive
### Negative

## Alternatives Considered

---

> **사용법**: 이 파일을 복사해 `ADR-001-{요약}.md` 형식으로 저장한다.
HEREDOC

# ---- roadmap ----
cat > "${DOCS_DIR}/roadmap/current.md" << HEREDOC
# Roadmap — ${QUARTER}

## Quarter Goals

## Milestones

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Project Initialization | ${TODAY} | 🟡 In Progress |

## In Progress

## Completed

## Blocked / At Risk

| Item | Blocker | Owner |
|------|---------|-------|

## Notes
HEREDOC

# ---- todo ----
cat > "${DOCS_DIR}/todo/README.md" << 'HEREDOC'
## TODO 관리 규약

### 파일 구조
- `backlog.md` — 미착수 작업 목록
- `in-progress.md` — 진행 중 작업
- `done.md` — 완료된 작업 아카이브

### TODO 항목 포맷
```
[TODO-번호] 제목

owner: {사용자명} | agent
priority: P0 (blocker) | P1 (core) | P2 (standard) | P3 (nice-to-have)
module: {서브 프로젝트 모듈명}
status: backlog | in-progress | review | done
depends: TODO-번호 (선행 의존성, 없으면 none)
context: 이 작업이 필요한 이유 1줄
spec: 구체적 구현 요구사항
done-criteria: 완료 판단 기준
```

### owner 분배 기준

<!-- init에서 사용자 답변 또는 기본값으로 채워진다 -->
<!-- 기본값: init/defaults/owner-template.md 참조 -->

### 우선순위 기준
- **P0**: 이게 없으면 다른 작업 진행 불가
- **P1**: 서비스 핵심 기능. MVP 필수
- **P2**: MVP 포함이지만 핵심 의존성 없음
- **P3**: MVP 이후 또는 있으면 좋은 것
HEREDOC

cat > "${DOCS_DIR}/todo/backlog.md" << 'HEREDOC'
## Backlog

(TODO 항목이 여기에 추가된다)
HEREDOC

cat > "${DOCS_DIR}/todo/in-progress.md" << 'HEREDOC'
## In Progress

(진행 중 항목이 여기로 이동한다)
HEREDOC

cat > "${DOCS_DIR}/todo/done.md" << 'HEREDOC'
## Done

(완료 항목이 여기로 이동한다)
HEREDOC

# ---- temporary ----
cat > "${DOCS_DIR}/temporary/README.md" << 'HEREDOC'
## Temporary — 원본 문서 보관소

에이전트가 sync 처리한 임시 문서의 원본을 보관하는 디렉토리이다.

### 파일 네이밍
- 형식: `YYYYMMDD_원본파일명.md`

### 운영 규칙
- 이 디렉토리의 파일은 수동 삭제만 허용한다
- 에이전트는 이 디렉토리의 파일을 sync 대상으로 취급하지 않는다
HEREDOC

done_ "골격 파일 생성 완료 (15개)"

# ============================================================
# Phase 3: 에이전트 포인터 (상위 프로젝트 루트)
# ============================================================
info "에이전트 포인터 생성 중... (${PROJECT_ROOT}/)"

if [ ! -f "${PROJECT_ROOT}/CLAUDE.md" ]; then
  cat > "${PROJECT_ROOT}/CLAUDE.md" << 'HEREDOC'
# Claude Code 지시

이 프로젝트의 모든 규약, 아키텍처, 컨벤션은 project-docs/에 정의되어 있다.
작업 전 반드시 project-docs/를 읽고 따른다.

## 필수 참조
- project-docs/architecture/overview.md — 아키텍처
- project-docs/conventions/code-style.md — 코드 컨벤션
- project-docs/todo/ — 작업 관리
- project-docs/decisions/ — 아키텍처 결정 기록
HEREDOC
  done_ "CLAUDE.md → ${PROJECT_ROOT}/CLAUDE.md"
else
  warn "CLAUDE.md 가 이미 존재합니다. 건너뜁니다."
fi

if [ ! -f "${PROJECT_ROOT}/GEMINI.md" ]; then
  cat > "${PROJECT_ROOT}/GEMINI.md" << 'HEREDOC'
# Gemini CLI 지시

이 프로젝트의 모든 규약, 아키텍처, 컨벤션은 project-docs/에 정의되어 있다.
PRD 또는 요구사항이 입력되면 project-docs/를 참조하여 TODO 항목으로 분해한다.

## 필수 참조
- project-docs/architecture/overview.md — 아키텍처
- project-docs/todo/README.md — TODO 포맷 및 owner 기준
- project-docs/conventions/code-style.md — 코드 컨벤션

## Sync 규약
- 변경 시 what / why / impact 3요소를 반드시 기록
- project-docs/temporary/에 원본 보관
HEREDOC
  done_ "GEMINI.md → ${PROJECT_ROOT}/GEMINI.md"
else
  warn "GEMINI.md 가 이미 존재합니다. 건너뜁니다."
fi

# ============================================================
# Phase 4: Git 브랜치 생성 + 커밋
# ============================================================
info "Git 브랜치 생성 중..."

cd "${DOCS_DIR}"

if [ -d ".git" ]; then
  # 이미 git repo인 경우 — 브랜치만 생성
  CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || echo "")"

  if [ "${CURRENT_BRANCH}" = "${PROJECT_SLUG}" ]; then
    info "이미 ${PROJECT_SLUG} 브랜치입니다."
  elif git show-ref --verify --quiet "refs/heads/${PROJECT_SLUG}" 2>/dev/null; then
    git checkout "${PROJECT_SLUG}"
    done_ "기존 브랜치 ${PROJECT_SLUG}로 전환"
  else
    git checkout -b "${PROJECT_SLUG}"
    done_ "브랜치 생성: ${PROJECT_SLUG}"
  fi

  git add -A
  git commit -m "docs: project-docs 초기화 (${PROJECT_NAME})" --allow-empty
  done_ "커밋 완료"
else
  warn ".git 이 없습니다. 브랜치 생성을 건너뜁니다."
  info "수동으로 git init 후 브랜치를 생성하세요:"
  echo -e "     ${DIM}git init && git add . && git commit -m \"docs: init\"${NC}"
  echo -e "     ${DIM}git checkout -b ${PROJECT_SLUG}${NC}"
fi

# ============================================================
# 완료
# ============================================================
echo ""
echo -e "${GREEN}${BOLD}   ┌─────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}${BOLD}   │                                                 │${NC}"
echo -e "${GREEN}${BOLD}   │   ✓  초기화 완료: ${PROJECT_NAME}${NC}"
echo -e "${GREEN}${BOLD}   │                                                 │${NC}"
echo -e "${GREEN}${BOLD}   │   project-docs/    15개 골격 파일 생성          │${NC}"
echo -e "${GREEN}${BOLD}   │   CLAUDE.md        → 프로젝트 루트             │${NC}"
echo -e "${GREEN}${BOLD}   │   GEMINI.md        → 프로젝트 루트             │${NC}"
echo -e "${GREEN}${BOLD}   │   branch           → ${PROJECT_SLUG}${NC}"
echo -e "${GREEN}${BOLD}   │                                                 │${NC}"
echo -e "${GREEN}${BOLD}   └─────────────────────────────────────────────────┘${NC}"
echo ""

echo -e "  ${BOLD}생성된 구조:${NC}"
echo ""
if command -v tree &> /dev/null; then
  tree "${DOCS_DIR}" --dirsfirst -I '.git' | sed 's/^/   /'
else
  find "${DOCS_DIR}" -not -path '*/.git/*' -type f | sort | sed "s|${DOCS_DIR}/|   project-docs/|"
fi

echo ""
echo -e "  ${BOLD}다음 단계:${NC}"
echo ""
echo -e "  에이전트에게 아래와 같이 지시하세요:"
echo ""
echo -e "     ${DIM}project-docs/init/INIT.md를 읽고 순서대로 실행해줘.${NC}"
echo ""
