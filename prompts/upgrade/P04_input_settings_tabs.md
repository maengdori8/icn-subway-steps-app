# P04 비밀번호 제안·설정 버전 문구·같은 탭 맨 위로 (필수)

권한 모드: 요청 1은 Plan, 요청 2는 Manual
대상 ID: C-15(S4-01), S5-01, C-19(S1-10·S5-02·S6-03)(docs/upgrade-gap.md)
먼저 할 일: P02를 끝낸다(ScrollColumn 스크롤 제어를 함께 씀). P01에서 질문 6(버전 문구) 답을 적어 둔다.

## 요청 1 (Plan 모드에서 보낸다)
@docs/upgrade-gap.md 의 C-15·S5-01·C-19 행과 근거(@docs/component-rules.md 의 비밀번호·하단 메뉴 규칙, @docs/S04-screen-spec.md·@docs/S05-screen-spec.md·@docs/S06-screen-spec.md, @docs/design-system.json 의 bottomNav)를 읽어 줘.
지금 코드 lib/widgets/labeled_field.dart, lib/screens/login_screen.dart, settings_screen.dart, home_shell.dart, route_list_screen.dart, my_tips_screen.dart, lib/l10n/app_strings.dart 도 읽어 줘. 지금은 고치지 마.
바꿀 방법과 추가할 검사를 표로 정리해 줘.

## 요청 2 (계획을 승인한 뒤 Manual로 보낸다)
승인한 계획대로 고쳐 줘.
- 비밀번호 칸은 [보이기]를 눌러도 키보드 제안·자동고침을 끈다.
- S05 버전 문구를 reports/upgrade-log.md '0. 결정'의 질문 6 답으로 바꾼다(en·ko). 더는 '서버에 연결하지 않음'이라고 말하지 않는다.
- 하단 메뉴에서 지금 탭을 다시 누르면 그 화면(S01·S05·S06) 본문을 맨 위로 올린다. 동작 줄이기 설정이면 바로 옮긴다.
위젯 검사: 보이기를 누른 뒤 비밀번호 TextField의 enableSuggestions·autocorrect가 false, S05 정보 칸 문구, 아래로 스크롤 → 같은 탭 다시 누름 → 맨 위. flutter analyze·flutter test 마지막 줄을 보여 줘.
reports/upgrade-log.md 1절 P04 행을 적어 줘(AI 실행, 화면 대조는 '미실행'). 같은 탭 부분은 Codex 반박을 짧게 받아 3절에 적어 줘. 커밋은 내가 한다.

## 내가 확인할 것(에뮬레이터)
- 비밀번호를 보이게 한 상태에서 키보드 제안 줄이 안 나오는지(키보드 앱마다 다를 수 있음)
- S05 버전 문구
- S01·S06·S05에서 아래로 내린 뒤 같은 탭을 다시 누르면 맨 위로 가는지
