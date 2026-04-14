# ADR-001: 초기 아키텍처 고도화 및 백로그 구조 개선 (통합)

## Status
Accepted

## Date
2026-04-14

## Context
프로젝트 착수 전 PRD 분석 및 초기 백로그 검토 결과, 사용자 개입 없는 자동화된 구현과 고품질 UX 달성을 위해 다음과 같은 기술적 리스크와 구조적 누락이 발견됨:
1. **UX 품질**: `setTimeout` 기반 싱크의 부정확성 및 윈도우 생성/파괴 시의 지연 시간 문제.
2. **구조적 누락**: Python-React 브릿지 연결 작업의 부재 및 마이크 캡처 주체의 불분명함.
3. **환경 및 설정**: 개발 환경(Linux)과 타겟(macOS)의 불일치 및 환경변수 설정의 낮은 우선순위.

## Decision

### 1. UI/Audio 아키텍처 최적화
- **정밀 오디오 싱크**: Web Audio API의 `currentTime`을 기준 시계로 사용하여 `requestAnimationFrame` 루프 내에서 음소/자막을 동기화함.
- **Instant-on 라이프사이클**: 윈도우를 파괴하지 않고 숨김(Hide/Show) 처리하여 핫키 즉시 반응성을 확보함.
- **중앙 집중 상태 관리**: Python Core를 Single Source of Truth로 설정하고 React는 Push된 상태에 따른 렌더링만 수행함.

### 2. 백로그 및 구현 전략 수정
- **브릿지 우선 통합**: TODO-002와 003 사이에 `pywebview` 브릿지 연결 및 React 빌드 로드 작업을 추가하여 조기에 통합 테스트가 가능하도록 함.
- **환경 설정(P0)**: `.env.example` 작성 및 환경변수 구조 정의를 최우선 순위(P0)로 격상하여 초기 개발의 차단 요소를 제거함.
- **마이크 캡처 전략**: 시각화(AnalyserNode)와의 완벽한 연동 및 데이터 흐름의 일관성을 위해 **브라우저(React)에서 캡처(Web Audio API)**하여 Python으로 전달하는 방식으로 **결정함**.

### 3. 개발 환경 대응 (Cross-platform)
- **Mocking 전략**: Linux 환경에서는 `pywebview`와 핫키 라이브러리를 Mocking하거나, headless 모드/CLI 로그로 동작을 검증하는 단위 테스트를 강화함.

## Consequences

### Positive
- 립싱크 및 자막의 높은 정확도와 Native 앱 수준의 빠른 반응 속도 보장.
- 초기 단계에서 Python-React 통신 규격이 확정되어 병렬 개발 용이.
- 설정 및 환경 이슈로 인한 개발 중단 리스크 최소화.

### Negative
- 초기 셋업 단계에서 브릿지 및 오디오 시계 로직 구현을 위한 추가 공수 발생.
- Linux 개발 환경에서의 검증을 위한 Mock 코드 작성이 필요함.

## Alternatives Considered
- **Create/Destroy 방식**: 로딩 딜레이 문제로 기각.
- **Python 직접 오디오 캡처**: React UI의 실시간 시각화(AnalyserNode) 연동이 복잡해질 수 있어 차선책으로 둠.
