# Getting Started

## 개발 환경 설정

이 프로젝트는 **macOS (M4 Mac)**를 최종 타겟으로 하지만, 개발은 **Linux** 환경에서도 가능하도록 설계되었습니다.

### 필수 소프트웨어
- Python 3.10+
- Node.js 18+ (pnpm 권장)
- Whisper.cpp (로컬 바이너리 및 모델)

### Linux 개발 가이드 (Mocking)
현재 개발 환경이 Linux인 경우, macOS 전용 기능인 `pywebview`의 Cocoa 엔진과 `pynput`의 일부 기능이 제한될 수 있습니다.
- **Mocking**: `src/core/utils/mocks.py` (예시)를 통해 시스템 윈도우 호출을 시뮬레이션합니다.
- **Headless**: UI 테스트가 어려운 경우 CLI 로그를 통해 상태 전이를 확인합니다.

### 초기 셋업 순서
1. `project-docs/todo/backlog.md`의 **[TODO-001]**에 따라 `.env` 파일을 생성합니다.
2. Python 가상환경을 생성하고 의존성을 설치합니다. (`pip install -r requirements.txt`)
3. `project/ui` 디렉토리에서 프론트엔드 의존성을 설치합니다. (`pnpm install`)
4. `python main.py`를 실행하여 MCP 서버를 기동합니다.

## 프로젝트 규약
- 모든 코드는 `project-docs/conventions/code-style.md`를 따릅니다.
- 새로운 설계 결정은 `project-docs/decisions/`에 ADR로 기록합니다.
