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
