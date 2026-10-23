# P00 고도화 작업 규칙 붙이기

권한 모드: Manual(편집마다 diff를 보고 허용)
사용법: '## 요청' 아래 줄을 Claude Code 입력창에 그대로 붙여 넣는다. 또는 입력창에 `@prompts/upgrade/P00_rules.md 의 요청을 수행해 줘`라고 입력한다.
처음 한 번만 한다. 다시 하면 규칙이 두 번 붙는다(그때는 git diff로 보고 git restore CLAUDE.md로 되돌린다).

## 요청
CLAUDE.md 끝에 이 파일의 '## 고도화 작업 규칙' 절을 그대로 덧붙여 줘. 위의 9장·10장 규칙은 지우거나 고치지 마.
reports/upgrade-log.md가 없으면 @prompts/upgrade/upgrade-log-template.md 를 복사해 만들어 줘. 이미 있으면 덮어쓰지 마.
끝나면 git diff --stat 을 보여 줘. 커밋은 내가 한다.

## 고도화 작업 규칙
- 목적: docs/의 5장 5차 점검 반영본(디자인 시스템·컴포넌트 규칙·S02~S06 화면 명세)에 맞춰 지금 앱을 다듬는다. 10장까지 만든 서버 연결과 자동 검사는 그대로 살린다.
- 쓰기 범위: lib/, test/, reports/upgrade-log.md. docs/upgrade-gap.md는 읽기만 한다. android/·pubspec.yaml·서버 프로젝트(C:\dev\projects\icn-subway-server)·5장 원본(C:\dev\chapter05-ai\docs)은 요청에서 따로 허락할 때만 바꾼다.
- 먼저 읽을 것: docs/000_읽는순서.md → docs/ui-review-round5-design-plugin.md → docs/design-system.json·docs/component-rules.md → docs/S02~S06-screen-spec.md → docs/screen-flow.csv·docs/ui-requirements.csv·docs/ui-validation-decisions.md → docs/upgrade-gap.md(P01 결과) → 지금 lib·test.
- 디자인 값(색·글자 크기·간격·모서리·누르는 영역)은 docs/design-system.json에 이름이 있는 값만 쓴다. 코드에 새 숫자를 지어내지 않는다. 모바일에서 바꿔야 하면 이유를 reports/upgrade-log.md 2절에 적는다.
- 지킬 결정: 10장 결정(공개 GET /api/tips 토큰 유지, 403 문구 — reports/app-integration.md 6절), 9장 인계의 '시안과 다르게 둔 것'(docs/handoff.md 1절). 이것과 다르게 바꿔야 하면 편집 전에 먼저 알려 주고, 바꾼 이유를 기록한다.
- 문구는 lib/l10n/app_strings.dart에 한국어·영어를 함께 넣는다. 서버가 주는 한국어 오류 문구를 화면에 그대로 쓰지 않는다.
- 실제 역 정보(층수·승강장 위치·요금·시간)를 지어내지 않는다. 명세에 '현장 확인'으로 남은 것은 그대로 둔다.
- 패키지를 새로 넣지 않는다. 꼭 필요하면 이유를 말하고 사람의 승인을 받은 뒤 reports/package-check.csv에 적는다.
- 확인: 편집 뒤 flutter analyze와 flutter test를 실행하고 마지막 줄을 그대로 보여 준다. 바뀐 화면은 사람이 에뮬레이터로 명세와 대조한다. 사람이 알려 주지 않은 화면 결과를 성공으로 쓰지 않는다.
- 검사를 지우거나 기대값을 오류에 맞춰 바꾸지 않는다. 명세가 바뀌어 기대값을 바꿀 때는 근거(명세 파일·줄)를 기록한다.
- 로직이 있는 변경은 커밋 전에 Codex 반박을 받는다(C:\dev\CLAUDE.md). 문구·색 값만 바꾼 변경은 받지 않아도 된다.
- 토큰·비밀번호·개인 경로를 파일·로그·커밋에 넣지 않는다. 요청문 하나를 마칠 때마다 사람이 diff를 보고 커밋한다.
