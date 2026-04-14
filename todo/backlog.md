# Project Backlog

## 📋 핵심 작업 목록

### [TODO-001] 환경 변수 정의 및 .env.example 작성
- **owner**: agent
- **priority**: P0 (blocker)
- **module**: core
- **status**: backlog
- **depends**: none
- **context**: 초기 구현 시 필요한 API 키와 경로 설정을 확립해야 함.
- **spec**: Discord Webhook, Supertone, Whisper 경로 등 필요한 모든 변수 정의.
- **done-criteria**: `.env.example` 파일이 생성되고 필수 변수가 문서화됨.

### [TODO-002] Python MCP 서버 및 기초 환경 구축
- **owner**: agent
- **priority**: P0 (blocker)
- **module**: core
- **status**: backlog
- **depends**: TODO-001
- **context**: Jarvis가 호출할 MCP 인터페이스 정의가 핵심임.
- **spec**: `mcp` 라이브러리 설치, `speak`, `cancel`, `get_state` 도구 스켈레톤 및 Python 상태 머신 구현.
- **done-criteria**: MCP 서버가 실행 가능하며 상태 전이 로직이 검증됨.

### [TODO-003] 글로벌 핫키 및 Instant-on 윈도우 구현
- **owner**: agent
- **priority**: P1 (core)
- **module**: core
- **status**: backlog
- **depends**: TODO-002
- **context**: 사용자 입력 감지 및 고속 UI 표시 제어.
- **spec**: `pynput` 핫키 감지, `pywebview` 윈도우 최초 생성 후 Hide/Show 로직 구현. Linux 대응 Mocking 포함.
- **done-criteria**: 핫키 입력 시 즉시 윈도우가 노출되고 10초 후 숨김 처리됨.

### [TODO-004] pywebview-React 브릿지 및 빌드 통합
- **owner**: agent
- **priority**: P1 (core)
- **module**: integration
- **status**: backlog
- **depends**: TODO-003
- **context**: Python과 React 간의 실질적인 통신 통로 확보.
- **spec**: `window.pywebview.api` 호출 규격 정의, React 프로덕션 빌드 로드 로직 구현.
- **done-criteria**: Python에서 보낸 상태값이 React UI에 전달되는 것이 확인됨.

### [TODO-005] Three.js Neural Sphere 및 Audio Sync 구현
- **owner**: agent
- **priority**: P1 (core)
- **module**: ui
- **status**: backlog
- **depends**: TODO-004
- **context**: 앱의 핵심 시각 요소 및 정밀 싱크 구현.
- **spec**: Sphere 상태 애니메이션, Web Audio API `currentTime` 기반 음소 동기화 로직 구현.
- **done-criteria**: 오디오 재생 시간과 음소 타이밍이 일치하여 시각화됨.

### [TODO-006] 브라우저 마이크 캡처 및 STT(Whisper.cpp) 연동
- **owner**: agent
- **priority**: P1 (core)
- **module**: audio
- **status**: backlog
- **depends**: TODO-004
- **context**: 음성 인식 파이프라인 완성.
- **spec**: React에서 마이크 데이터 캡처, Python으로 전달 후 Whisper.cpp 실행 및 결과 반환.
- **done-criteria**: 발화 시 텍스트로 변환되어 로그에 출력됨.

### [TODO-007] TTS(Supertone) 및 Discord Webhook 전체 통합
- **owner**: agent
- **priority**: P1 (core)
- **module**: integration
- **status**: backlog
- **depends**: TODO-005, TODO-006
- **context**: 전체 사용자 시나리오 완성.
- **spec**: Supertone Stream API 연동, STT 결과를 Discord로 전송 및 Jarvis 응답 처리.
- **done-criteria**: 핫키 발화부터 Jarvis 응답 음성 출력까지 전체 사이클 동작.
