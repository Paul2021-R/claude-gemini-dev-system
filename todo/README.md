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
