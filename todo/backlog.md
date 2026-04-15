# Project Backlog

## ✅ 완료된 항목

### [TODO-001] ~ [TODO-007]
1차 구현 완료 (2026-04-15). 전체 파이프라인 동작 확인.

---

## 📋 미해결 항목

### [TODO-008] 나노봇 Discord 봇 메시지 필터 해제
- **owner**: user
- **priority**: P0 (blocker)
- **module**: integration
- **status**: backlog
- **depends**: none
- **context**: 나노봇이 `message.author.bot` 체크로 봇 메시지를 무시하도록 설정되어 있어
  Voice UI에서 Bot 토큰으로 보낸 메시지에 반응하지 않음.
- **spec**: 나노봇 `on_message` 핸들러에서 봇 메시지 차단 조건 제거 또는 Voice UI 봇 ID 예외 처리.
- **done-criteria**: speak 도구가 호출되어 음성이 정상 출력됨 (전체 사이클 완성).

---

## 📋 추가 개선 항목

### [TODO-009] 디버그 로그 제거 및 프로덕션 정리
- **owner**: agent
- **priority**: P2
- **module**: core / ui
- **status**: backlog
- **context**: 디버깅 과정에서 추가된 console.log, debug=True 등 정리 필요.
- **spec**: `window.py` debug=True 제거, MicCapture 디버그 로그 제거, Supertone 응답 키 로그 제거.
- **done-criteria**: 불필요한 로그 없이 동작.
