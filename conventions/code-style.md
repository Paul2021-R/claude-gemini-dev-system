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
