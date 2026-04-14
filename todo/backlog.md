# Backlog

## [TODO-1] 프로젝트 기술 스택 확정 및 서브 프로젝트 생성

owner: human
priority: P0
module: root
status: backlog
depends: none
context: 현재 `cloud-agent/` 디렉토리가 비어 있음. 개발을 위한 언어, 프레임워크 선정이 필요함.
spec:
  - 백엔드/프런트엔드 기술 스택 결정
  - `cloud-agent/` 하위에 기본 프로젝트 구조 생성 (예: `backend/`, `frontend/`)
done-criteria: `cloud-agent/` 디렉토리에 마커 파일(package.json, build.gradle 등)이 존재함

## [TODO-2] 기술 스택에 따른 프로젝트 문서 업데이트

owner: agent
priority: P1
module: project-docs
status: backlog
depends: TODO-1
context: 확정된 기술 스택을 바탕으로 문서 구체화 필요
spec:
  - `architecture/overview.md`에 구성 요소 및 데이터 레이어 작성
  - `setup/getting-started.md`에 실행 방법 및 환경 변수 작성
  - `conventions/code-style.md`에 언어별 컨벤션 추가
done-criteria: 각 문서의 "기술 스택 확정 후 채울 예정" 섹션이 실제 내용으로 대체됨
