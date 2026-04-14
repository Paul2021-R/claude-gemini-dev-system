# Architecture Overview

AI Voice UI는 Python 백그라운드 프로세스와 React 기반의 웹뷰 인터페이스가 결합된 구조로, Jarvis(nanobot) MCP 서버로 동작하며 음성 입출력을 담당합니다.

## 구성 요소

### 1. Python Core (Backend)
- **MCP Server**: Jarvis가 호출하는 `speak`, `cancel`, `get_state` 도구를 노출합니다.
- **Hotkey Listener (`pynput`)**: 글로벌 핫키(`Ctrl+Space`)를 감지하여 UI 윈도우를 제어합니다.
- **Window Manager (`pywebview`)**: **Instant-on** 방식(최초 1회 생성 후 Hide/Show)으로 윈도우 라이프사이클을 관리하여 반응성을 극대화합니다.
- **STT Engine (Whisper.cpp)**: 로컬에서 음성을 텍스트로 변환하는 핵심 엔진입니다.
- **State Controller**: 모든 앱 상태의 **Single Source of Truth** 역할을 하며, React UI로 상태 변화를 전파합니다.

### 2. React UI (Frontend)
- **Neural Sphere (Three.js)**: Python에서 Push된 상태에 따라 5가지 애니메이션을 수행합니다.
- **Precision Audio Sync**: Web Audio API의 **`currentTime`**을 기준으로 음소 타이밍을 정밀하게 동기화하여 립싱크를 구현합니다.
- **Microphone Capture**: 브라우저 API를 통해 마이크 입력을 **결정된 표준 방식**에 따라 캡처하고, 시각화(AnalyserNode) 및 STT 데이터(Python) 전달을 수행합니다.

## 데이터 레이어 & 통신

- **JS ↔ Python**: `window.pywebview.api` 브릿지를 통해 직접 함수를 호출합니다.
- **External API (Jarvis 연동)**:
    - **Outbound**: Discord Webhook을 통해 Jarvis 봇에게 텍스트를 전달합니다.
    - **Inbound**: Jarvis가 MCP `speak` 도구를 호출하여 응답을 전달합니다.
- **TTS API (Supertone)**: 텍스트와 음소 데이터를 수신하며, 오디오 스트리밍을 처리합니다.

## 인프라 및 환경
- **Runtime**: Python 3.10+, Node.js 18+
- **Mocking Strategy**: Linux 개발 환경에서는 `pywebview` 및 핫키 모듈을 Mocking하여 로직 검증을 수행합니다.

