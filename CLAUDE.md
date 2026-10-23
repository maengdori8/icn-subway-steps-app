# 내 앱 프로젝트 작업 기준 · ICN Subway Steps

인천공항 T1 입국장 → 서울역행 공항철도 탑승 단계 안내 Flutter 앱이다. 9장에서 가짜 저장소로 화면을 만들었고, 10장부터 같은 폴더에서 Spring Boot 서버(C:\dev\projects\icn-subway-server)에 연결한다.
C:\dev\CLAUDE.md의 팀 규칙(Claude=구현, Codex=반박)이 함께 적용된다.

## 9장 작업 규칙
- 먼저 읽을 것: docs/ui-handoff.md → docs/design-system.json, docs/S02·S03-screen-spec.md, docs/screens/ICN-subway-steps-v03.src.html, docs/ui-verify-round4-v03.md → docs/handoff.md(9장 인계) → 현재 lib.
- 화면: S01 경로 목록, S02 단계 안내, S03 팁 등록, S04 로그인, S05 설정, S06 내 팁. 하단 메뉴는 S01·S06·S05에서만.
- 입력 규칙(팁 제목·위치 1~80자, 메모 선택 150자, 코드 포인트 기준), 상태(VERIFIED/OUTDATED), 올린 사람만 상태 변경을 바꾸지 않는다.
- 패키지: 지금은 flutter_localizations(SDK)·shared_preferences만 쓴다. 새 패키지는 이유를 말하고 사람의 승인을 받은 뒤 reports/package-check.csv에 적는다.
- 실제 역 정보(층수·승강장 위치·요금·시간)를 지어내지 않는다. 표지판 글자와 안내 문구는 현장 확인 전 초안이다.
- 확인: flutter analyze와 flutter test. 검사를 지우거나 기대값을 오류에 맞춰 바꿔서 통과시키지 않는다.
- 토큰·비밀번호·개인 경로를 파일에 쓰지 않는다. 실행하지 않은 결과를 '확인함'으로 쓰지 않는다.

## 다음 장 규칙을 더할 때
10장부터 제공되는 규칙은 이 파일 끝에 `## N장 작업 규칙` 절로 붙이고, 위 규칙은 지우지 않는다.

## 10장 작업 규칙
- 9장 규칙의 '쓰기 범위'와 '패키지' 줄은 10장부터 아래 줄이 대신한다. 나머지 9장 규칙은 그대로 지킨다.
- 쓰기 범위: lib/, test/, pubspec.yaml(패키지 추가를 사람이 승인한 뒤), reports/app-integration.md(요청에서 지시한 칸만).
- 먼저 읽을 것: docs/integration-inputs.md → 자료표가 가리키는 파일(docs/design-system.json·component-rules.md·handoff.md, docs/api/의 서버 문서 사본, docs/samples/) → 현재 lib·pubspec.yaml·test.
- 바꿀 것: 더미 저장소를 실제 HTTP 요청으로 바꾸고 S04 로그인·토큰·보호 요청을 연결한다. 9장의 테마·공통 위젯·화면 배치와 입력 규칙은 유지한다.
- 서버 주소는 --dart-define=API_BASE_URL 값으로 받는다(에뮬레이터 기본값 http://10.0.2.2:8097). PC 주소·토큰을 코드에 쓰지 않는다.
- 공개 GET에는 토큰을 붙이지 않는다. 등록·반환·수정·삭제 같은 보호 요청에만 Bearer를 붙인다. owner_id·status는 요청 본문에 넣지 않는다.
- 보호 요청의 401이면 메모리의 로그인 정보를 지우고 다시 로그인하게 한다(로그인 요청 자체의 401은 아이디·비밀번호 확인 안내). 403이면 로그인 상태를 유지하고 권한을 설명한다. 실패한 변경 요청을 자동으로 다시 보내지 않는다.
- 패키지: 기본은 http(publisher dart.dev)만 쓴다. 사진 선택 실습에서만 image_picker(publisher flutter.dev)를 쓴다. 그 밖의 패키지는 이유를 말하고 사람의 승인을 받는다.
- 확인: flutter analyze와 flutter test를 실행하고 출력을 그대로 보여 준다. flutter run과 에뮬레이터 화면은 사람이 본다. 사람이 알려 주지 않은 화면 결과를 reports/app-integration.md에 성공으로 쓰지 않는다.
- 검사를 지우거나 기대값을 오류에 맞춰 바꾸지 않는다. 토큰·비밀번호·개인 경로를 파일·로그·커밋에 넣지 않는다.
- 이 프로젝트의 예외(2026-10-21 사용자 결정): GET /api/tips는 로그인했으면 토큰을 붙인다. 서버가 요청 토큰으로 mine(내가 올림)을 계산하는 명세(docs/api/api-spec.yaml)를 따른다. 이 요청이 401이면 요청 당시 세션일 때 로그인 정보를 지우고 토큰 없이 다시 읽는다. 경로·단계 같은 다른 공개 GET에는 붙이지 않는다(reports/app-integration.md 6절).

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
