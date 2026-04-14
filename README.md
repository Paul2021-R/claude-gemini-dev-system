# CGDS — Claude-Gemini Dev System

멀티 에이전트(Claude, Gemini) 기반 프로젝트 문서 프레임워크.

## 사용법

```bash
# 1. 프로젝트 루트에서 clone
cd my-project/
git clone <이 레포 URL> project-docs

# 2. init 실행
cd project-docs/
bash init.sh

# 3. 에이전트에게 Discovery 지시
# "project-docs/init/INIT.md를 읽고 순서대로 실행해줘."
```

## init.sh 가 하는 일

1. 프로젝트명 입력받기
2. `project-docs/` 내부에 골격 디렉토리 + 파일 15개 생성
3. 상위 프로젝트 폴더에 `CLAUDE.md`, `GEMINI.md` 에이전트 포인터 생성
4. 프로젝트명으로 git 브랜치 생성 및 커밋

## init 이후 구조

```
my-project/
├── CLAUDE.md              ← 에이전트 포인터 (init이 생성)
├── GEMINI.md              ← 에이전트 포인터 (init이 생성)
├── project-docs/          ← 이 레포 (브랜치: {프로젝트명})
│   ├── init/
│   │   ├── INIT.md        ← 에이전트 부트스트랩 체크리스트
│   │   └── defaults/
│   ├── architecture/
│   ├── api/
│   ├── conventions/
│   ├── setup/
│   ├── decisions/
│   ├── roadmap/
│   ├── todo/
│   ├── temporary/
│   ├── init.sh
│   └── README.md
├── sub-project-fe/
├── sub-project-be/
└── ...
```

## 브랜치 전략

- `main` — 템플릿 원본. init.sh + README.md만 존재
- `{project-name}` — 프로젝트별 브랜치. init 후 자동 생성
- 템플릿 업데이트 시: main에서 수정 → 각 프로젝트 브랜치에서 merge
