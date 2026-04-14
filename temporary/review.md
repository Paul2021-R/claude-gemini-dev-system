# Code Review Report (TODO-006) & Next Steps (TODO-007)

본 리뷰는 **TODO-006(STT 연동)**의 최종 검토 결과와 **TODO-007(전체 통합)**로 넘어가기 위한 핵심 과제를 담고 있습니다.

## 🚨 TODO-006 Final Check (완료 및 승인)

### 1. 오디오 파이프라인 (Perfect)
- `MicCapture.ts`와 `mic-processor.js`를 통한 16kHz 리샘플링 및 WAV 인코딩 로직이 확인되었습니다. Whisper.cpp의 요구 사양을 완벽히 충족합니다.
- `stt.py`의 임시 파일 cleanup(`finally: os.unlink`) 로직이 안전하게 구현되었습니다.

### 2. Mock 모드 지원 (Good)
- Whisper.cpp 바이너리가 없는 개발 환경(Linux 등)에서도 파이프라인 테스트가 가능하도록 설계된 점을 높게 평가합니다.

---

## 🚀 TODO-007 Integration Tasks (전체 통합 가이드)

TODO-007의 성공을 위해 아래 세 가지 연결 고리를 완성해야 합니다.

### 1. STT 결과를 Discord로 전송 (Outbound)
- **파일**: `project/core/app.py`
- **로직**: `self.bridge.set_stt_callback(self._on_stt_complete)`를 구현하세요.
- **동작**: `_on_stt_complete(text)` 메서드 내에서 **Discord Webhook**(`DISCORD_WEBHOOK_URL`)으로 텍스트를 발송해야 합니다. (Jarvis 멘션 포함 필수)

### 2. TTS (Supertone) 및 음소 싱크 완성 (Inbound)
- **파일**: `project/mcp_server.py` → `speak()` 도구
- **로직**: `speak(text)` 호출 시 Supertone Stream API를 통해 오디오와 음소(Phonemes) 데이터를 가져오세요.
- **싱크**: 가져온 데이터를 `bridge.push_audio_and_phonemes()` (가칭)를 통해 React로 전달하고, `usePhonemeSync.ts`가 이를 소비하도록 연결하세요.

### 3. 상태 전이 및 윈도우 제어 최적화
- `on_speak_done()` 시점에 `WAITING` 상태로 진입하고, `WindowManager`의 타이머가 정상 작동하여 10초 후 윈도우가 자동으로 숨겨지는지 전체 사이클을 검증하세요.

## 🛠 코드 수정 권장 (Minor)
- `mcp_server.py`의 `speak()` 도구에 있는 `_app.on_speak_done()` 플레이스홀더를 실제 TTS 재생이 완료된 시점으로 이동시켜야 합니다. (지금은 즉시 호출됨)

**TODO-006 작업을 공식적으로 승인하며, 위 가이드를 바탕으로 TODO-007을 시작하세요.**
