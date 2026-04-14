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

#### 사람 (human) — 직접 작성
- 서비스 핵심 비즈니스 로직
- 보안/인증 설계
- 아키텍처 결정이 필요한 작업
- 외부 서비스 연동 설계
- 데이터 모델링 (스키마 설계)

#### 에이전트 (agent) — 위임 가능
- CRUD 엔드포인트, DTO/엔티티 생성
- 테스트 코드 작성
- 설정 파일, 마이그레이션 스크립트
- API 문서화
- 린트/포맷터 설정
- 보일러플레이트, 유틸리티 함수
- CI/CD 파이프라인 스크립트
- 리팩토링 (명확한 지시 하에)

### 우선순위 기준
- **P0**: 이게 없으면 다른 작업 진행 불가
- **P1**: 서비스 핵심 기능. MVP 필수
- **P2**: MVP 포함이지만 핵심 의존성 없음
- **P3**: MVP 이후 또는 있으면 좋은 것
