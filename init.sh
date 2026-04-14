#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# init.sh — CGDS (Claude-Gemini Dev System)
# Run inside project-docs/
# Usage: bash init.sh
# ============================================================

DOCS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "${DOCS_DIR}")"

# ---- colors ----
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
# Logo
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
# Phase 0: Pre-check + Project name input
# ============================================================

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
# Phase 1: Directory creation
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
  "shared"
  "temporary"
)

for d in "${dirs[@]}"; do
  mkdir -p "${DOCS_DIR}/${d}"
done

done_ "디렉토리 생성 완료"

# ============================================================
# Phase 2: Skeleton files
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

### 2-5. REVIEWER.md 프로젝트 컨텍스트 채우기
Discovery 결과에서 아래 항목을 REVIEWER.md의 프로젝트 컨텍스트 섹션에 자동 반영한다.
- 대상 플랫폼 (OS, 런타임, 프로토콜)
- 기술 스택 제약 (프레임워크, 스레딩 모델, 특이 사항)

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

# ---- owner defaults ----
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

# ---- shared (inter-agent communication) ----
cat > "${DOCS_DIR}/shared/README.md" << 'HEREDOC'
# Shared — Inter-Agent Communication

This directory is the **async communication channel** between agents.
All files in this directory MUST be written in **English** for token efficiency.

## Communication Protocol

### Review ↔ Result Loop

```
Reviewer (Gemini #2)              Implementer (Claude Code)
       │                                    │
       ├─ creates review_YYYY_MM_DD.md ────→│
       │                                    ├─ reads review
       │                                    ├─ applies fixes
       │←── creates result_YYYY_MM_DD.md ───┤
       ├─ reads result                      │
       ├─ verifies fixes                    │
       └─ (optional) creates follow-up ────→│
```

### File Naming

| File | Author | Purpose |
|------|--------|---------|
| `review_YYYY_MM_DD.md` | Reviewer (Gemini #2) | Runtime review report |
| `result_YYYY_MM_DD.md` | Implementer (Claude Code) | Fix report responding to review |
| `review_YYYY_MM_DD_v2.md` | Reviewer | Follow-up if result is insufficient |
| `result_YYYY_MM_DD_v2.md` | Implementer | Response to follow-up |

When multiple reviews occur on the same date, append version suffix: `_v2`, `_v3`, etc.

### File Format — review_*.md

```markdown
# Review Report — YYYY-MM-DD
> Reviewer: Gemini CLI #2
> Scope: {files or modules reviewed}
> Platform: {target OS / runtime}

## Critical
1. [{file}:{line}] {problem description}
   - checklist: {item number, e.g. 2-1}
   - cause: {why this is a problem}
   - fix: {specific fix suggestion}

## Warning
1. [{file}:{line}] {problem description}
   - checklist: {item number}
   - cause:
   - fix:

## Info
1. [{file}:{line}] {note}

## Summary
- critical: {N}
- warning: {N}
- info: {N}
```

### File Format — result_*.md

```markdown
# Result Report — YYYY-MM-DD
> Implementer: Claude Code
> Responding to: review_YYYY_MM_DD.md

## Applied Fixes

### Critical
1. [{file}:{line}] {what was fixed}
   - review item: Critical #1
   - change: {description of code change}
   - status: fixed | deferred | wontfix
   - reason: {if deferred or wontfix, explain why}

### Warning
1. [{file}:{line}] {what was fixed}
   - review item: Warning #1
   - change:
   - status:

## Deferred Items
{list items not fixed in this cycle with reasons}

## Summary
- fixed: {N}
- deferred: {N}
- wontfix: {N}
```

### Rules

1. **Language**: All communication in English. No exceptions.
2. **Immutability**: Once created, files are never modified. Corrections go in new files.
3. **Traceability**: Every result item must reference the original review item.
4. **Scope**: Only runtime/execution concerns. No design opinions or feature suggestions.
5. **Cleanup**: Files older than 30 days may be archived to `temporary/` by the human.

### How to Trigger

Tell the Reviewer agent:
```
Read REVIEWER.md, then review the code and write your report to
project-docs/shared/review_YYYY_MM_DD.md
```

Tell the Implementer agent:
```
Read project-docs/shared/review_YYYY_MM_DD.md,
apply fixes, then write your report to
project-docs/shared/result_YYYY_MM_DD.md
```
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

done_ "골격 파일 생성 완료 (16개)"

# ============================================================
# Phase 3: Agent pointers (project root)
# ============================================================
info "에이전트 포인터 생성 중... (${PROJECT_ROOT}/)"

# ---- CLAUDE.md ----
if [ ! -f "${PROJECT_ROOT}/CLAUDE.md" ]; then
  cat > "${PROJECT_ROOT}/CLAUDE.md" << 'HEREDOC'
# Claude Code Instructions

All conventions, architecture, and standards are defined in `project-docs/`.
Read project-docs/ before starting any task.

## Required References
- `project-docs/architecture/overview.md` — Architecture
- `project-docs/conventions/code-style.md` — Code conventions
- `project-docs/todo/` — Task management
- `project-docs/decisions/` — Architecture Decision Records

## Inter-Agent Communication

After implementation, check `project-docs/shared/` for review reports.

### When a review file exists (`review_*.md`):
1. Read the review report
2. Apply fixes for all Critical and Warning items
3. Write a result report to `project-docs/shared/result_YYYY_MM_DD.md`
4. Follow the result format defined in `project-docs/shared/README.md`
5. All communication in `shared/` must be in **English**

### Result file rules:
- Every fix must reference the original review item number
- Items not fixed must be listed under "Deferred Items" with reasons
- Never modify the original review file
HEREDOC
  done_ "CLAUDE.md → ${PROJECT_ROOT}/CLAUDE.md"
else
  warn "CLAUDE.md 가 이미 존재합니다. 건너뜁니다."
fi

# ---- GEMINI.md ----
if [ ! -f "${PROJECT_ROOT}/GEMINI.md" ]; then
  cat > "${PROJECT_ROOT}/GEMINI.md" << 'HEREDOC'
# Gemini CLI Instructions (Designer / Architect)

All conventions, architecture, and standards are defined in `project-docs/`.
When a PRD or requirement is provided, decompose it into TODO items
following `project-docs/todo/README.md` format.

## Required References
- `project-docs/architecture/overview.md` — Architecture
- `project-docs/todo/README.md` — TODO format and owner criteria
- `project-docs/conventions/code-style.md` — Code conventions

## Sync Rules
- Record what / why / impact for every change
- Archive originals in `project-docs/temporary/`

## Role Boundary
This agent handles **design and decomposition** only.
Runtime review is handled by a separate Reviewer agent (see REVIEWER.md).
Do not perform runtime-level code review — that is not your responsibility.
HEREDOC
  done_ "GEMINI.md → ${PROJECT_ROOT}/GEMINI.md"
else
  warn "GEMINI.md 가 이미 존재합니다. 건너뜁니다."
fi

# ---- REVIEWER.md ----
if [ ! -f "${PROJECT_ROOT}/REVIEWER.md" ]; then
  cat > "${PROJECT_ROOT}/REVIEWER.md" << 'HEREDOC'
# Reviewer Instructions (Gemini CLI #2)

This agent performs **runtime-focused code review** only.
Do NOT evaluate design intent or feature completeness.
The sole question is: "Will this code actually run correctly on the target platform?"

## Role in Agent Architecture

```
Gemini CLI #1 (Designer)  ── design ──→  Claude Code (Implementer)
                                              │
                                              ▼ code
                                    Gemini CLI #2 (Reviewer) ← THIS AGENT
                                              │
                                              ▼ review report
                                    project-docs/shared/review_YYYY_MM_DD.md
                                              │
                                              ▼ read by
                                    Claude Code (applies fixes)
                                              │
                                              ▼ result report
                                    project-docs/shared/result_YYYY_MM_DD.md
```

## Review Checklist

### 1. Language Spec Accuracy
- Code where syntax is interpreted differently from intent
  - Python: type annotation vs assignment confusion, mutable default args, late binding closures
  - JS/TS: hoisting, implicit coercion, missing optional chaining, strictNullChecks violations
  - Common: operator precedence mistakes, short-circuit side effects
- Code that executes but has no effect (silent failure)
- Language/runtime version compatibility issues

### 2. Platform Runtime Constraints
- API calls that don't work on the target OS/runtime
  - macOS: Cocoa main thread requirement, App Sandbox, Gatekeeper signing
  - Browser: file:// CORS restrictions, AudioWorklet module loading, Web API availability
  - Linux: desktop environment differences (X11/Wayland), DBus dependencies
- Platform differences in file paths, permissions, protocols
  - Mixed absolute/relative paths, OS-specific path separators, temp file locations
- External binary/service dependency availability
  - Subprocess calls without existence checks
  - Missing fallback when network services are unavailable

### 3. Thread / Timing Safety
- Shared state access with race condition potential
  - Read-modify-write patterns without locks
  - Multiple threads calling methods on the same object
- Callback registration order vs actual invocation order mismatch
  - Callbacks triggered before initialization completes
  - Gap between event listener registration and event firing
- Missing error handling in async operations
  - Unhandled promise rejections
  - Exception loss in fire-and-forget threads
- Lock scope appropriateness
  - Under-protection: shared state accessed outside critical section
  - Over-protection: unnecessary locks causing deadlock or performance issues

### 4. State Machine Consistency
- force() calls that bypass defined transition rules
  - Whether force() usage is documented in comments/ADR
- Missing recovery path when transition() fails
  - Callers ignoring transition() returning false
- State desync between internal state and UI/external systems
  - State changed internally but not reflected in UI/API

### 5. Resource Management
- Unclosed connections/streams/contexts
  - AudioContext, MediaStream, WebSocket, DB connections
  - Missing try-finally or context manager usage
- Memory leak patterns
  - Event listeners registered without cleanup
  - Circular references preventing GC
  - Closures capturing unnecessarily large scopes
- Uncancelled timers/intervals
  - setInterval/setTimeout without clear
  - requestAnimationFrame without cancel
  - threading.Timer without cancel()

### 6. Data Integrity
- Missing input validation
  - External input (API responses, user input, files) used without validation
  - Missing exception handling for base64 decode failures
- Encoding/decoding mismatches
  - Broken UTF-8 assumptions
  - Mixed binary vs text mode

## Project Context

<!-- Auto-filled by Discovery phase (INIT.md step 2-5) -->

### Target Platform
- OS:
- Runtime:
- Protocol:

### Tech Stack Constraints
- Main frameworks:
- Threading model:
- Special considerations:

## Output

Write review reports to: `project-docs/shared/review_YYYY_MM_DD.md`
Follow the format defined in `project-docs/shared/README.md`.

After writing the review, inform the user:
```
Review complete. Report: project-docs/shared/review_YYYY_MM_DD.md
Critical: {N}, Warning: {N}, Info: {N}

Next: tell Claude Code to read the review and apply fixes.
```

## How to Invoke

```
Read REVIEWER.md, then review the following code from a runtime perspective.
Target platform: {OS, runtime, etc.}
Write your report to project-docs/shared/review_YYYY_MM_DD.md

{code or file paths}
```

Full project review:
```
Read REVIEWER.md, then review all project source files from a runtime perspective.
Iterate file by file. Write a consolidated report to
project-docs/shared/review_YYYY_MM_DD.md
```

## Required References
- `project-docs/architecture/overview.md` — Execution environment context
- `project-docs/setup/getting-started.md` — Runtime requirements
- `project-docs/shared/README.md` — Communication protocol and file formats
HEREDOC
  done_ "REVIEWER.md → ${PROJECT_ROOT}/REVIEWER.md"
else
  warn "REVIEWER.md 가 이미 존재합니다. 건너뜁니다."
fi

# ============================================================
# Phase 4: Git branch + commit
# ============================================================
info "Git 브랜치 생성 중..."

cd "${DOCS_DIR}"

if [ -d ".git" ]; then
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

  # upstream push
  HAS_REMOTE="$(git remote get-url origin 2>/dev/null || echo "")"
  if [ -n "${HAS_REMOTE}" ]; then
    info "원격 push 중... (origin/${PROJECT_SLUG})"
    if git push -u origin "${PROJECT_SLUG}" 2>/dev/null; then
      done_ "push 완료: origin/${PROJECT_SLUG}"
    else
      warn "push 실패. 수동으로 실행하세요: git push -u origin ${PROJECT_SLUG}"
    fi
  else
    warn "remote origin이 없습니다. push를 건너뜁니다."
    info "원격 연결 후 push:"
    echo -e "     ${DIM}git remote add origin <레포 URL>${NC}"
    echo -e "     ${DIM}git push -u origin ${PROJECT_SLUG}${NC}"
  fi
else
  warn ".git 이 없습니다. 브랜치 생성을 건너뜁니다."
  info "수동으로 설정하세요:"
  echo -e "     ${DIM}cd project-docs${NC}"
  echo -e "     ${DIM}git init && git add . && git commit -m \"docs: init\"${NC}"
  echo -e "     ${DIM}git checkout -b ${PROJECT_SLUG}${NC}"
fi

# ============================================================
# Done
# ============================================================
echo ""
echo -e "${GREEN}${BOLD}   ┌─────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}${BOLD}   │                                                 │${NC}"
echo -e "${GREEN}${BOLD}   │   ✓  초기화 완료: ${PROJECT_NAME}${NC}"
echo -e "${GREEN}${BOLD}   │                                                 │${NC}"
echo -e "${GREEN}${BOLD}   │   project-docs/    16개 골격 파일 생성          │${NC}"
echo -e "${GREEN}${BOLD}   │   CLAUDE.md        → 구현자 (Claude Code)      │${NC}"
echo -e "${GREEN}${BOLD}   │   GEMINI.md        → 설계자 (Gemini CLI #1)    │${NC}"
echo -e "${GREEN}${BOLD}   │   REVIEWER.md      → 리뷰어 (Gemini CLI #2)    │${NC}"
echo -e "${GREEN}${BOLD}   │   shared/           에이전트 간 소통 (영어)     │${NC}"
echo -e "${GREEN}${BOLD}   │   branch           → ${PROJECT_SLUG}${NC}"
echo -e "${GREEN}${BOLD}   │                                                 │${NC}"
echo -e "${GREEN}${BOLD}   └─────────────────────────────────────────────────┘${NC}"
echo ""

echo -e "  ${BOLD}에이전트 구조:${NC}"
echo ""
echo -e "   ${CYAN}Gemini #1${NC} (GEMINI.md)   ── 설계/분해 ──→  ${CYAN}Claude Code${NC} (CLAUDE.md)"
echo -e "     설계자                                          구현자"
echo -e "                                                      │"
echo -e "                                                      ▼ 코드"
echo -e "                                            ${MAGENTA}Gemini #2${NC} (REVIEWER.md)"
echo -e "                                              리뷰어"
echo -e "                                                      │"
echo -e "                                                      ▼"
echo -e "                                            ${DIM}shared/review_*.md${NC}  (EN)"
echo -e "                                                      │"
echo -e "                                                      ▼ 읽고 수정"
echo -e "                                            ${CYAN}Claude Code${NC}"
echo -e "                                                      │"
echo -e "                                                      ▼"
echo -e "                                            ${DIM}shared/result_*.md${NC}  (EN)"
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
