# P03 느린 연결·불러오는 중·S03 칸 오류 (필수)

권한 모드: 요청 1은 Plan, 요청 2는 Manual
대상 ID: C-26(S1-09·S2-04·S6-02), S6-01, S3-01(docs/upgrade-gap.md)
먼저 할 일: P01에서 질문 4(400 칸 오류 문구) 답을 적어 둔다. 답이 없으면 C-26·S6-01만 먼저 한다.

## 요청 1 (Plan 모드에서 보낸다)
@docs/upgrade-gap.md 의 C-26·S6-01·S3-01 행과 근거 명세(@docs/ui-handoff.md 의 시간 기준, @docs/component-rules.md 의 불러오는 중 규칙, @docs/S02-screen-spec.md·@docs/S03-screen-spec.md·@docs/S06-screen-spec.md 의 상태 절)를 읽어 줘.
지금 코드 lib/screens/route_list_screen.dart, step_guide_screen.dart, my_tips_screen.dart, add_tip_screen.dart, lib/widgets/common.dart, lib/repositories/subway_repository.dart, fake_subway_repository.dart 도 읽어 줘. 지금은 고치지 마.
바꿀 방법과 추가할 검사를 표로 정리하고, reports/upgrade-log.md '0. 결정'의 질문 4 답을 어떻게 따를지 보여 줘.

## 요청 2 (계획을 승인한 뒤 Manual로 보낸다)
승인한 계획대로 고쳐 줘.
- S01·S02(단계·팁)·S06의 불러오는 중이 8초를 넘으면 명세의 '느린 연결' 줄을 보인다. 응답이 오면 사라지고, 화면을 떠나면 타이머를 정리한다. 문구는 명세 문구를 쓰고 와이파이 이름 같은 현장 정보를 지어내지 않는다.
- S06 불러오는 중에 명세의 문구 줄(Loading your tips… / 한국어)을 보인다.
- S03에서 서버가 400과 errors(title·location·note)를 주면 그 칸 아래에 오류를 보이고 첫 오류 칸에 초점을 주며 세 칸 값을 지킨다. 칸 이름이 없는 오류(route·stepNo 등)는 지금처럼 상자로 보인다. 서버의 한국어 문구는 화면에 쓰지 않는다(질문 4 답대로).
- 10장 시간 초과 흐름([팁 목록 확인])과 그 검사는 그대로 통과해야 한다.
- 검사용으로 가짜 저장소 failNext가 fieldErrors를 줄 수 있게 해도 된다.
위젯 검사: 응답을 9초 늦춘 뒤 8초에 느린 연결 줄, 응답 뒤 사라짐, 화면을 떠난 뒤 타이머 없음, S06 문구, 400 칸 오류·초점·값 유지, 칸 없는 오류는 상자. flutter analyze·flutter test 마지막 줄을 보여 줘.
reports/upgrade-log.md 1절 P03 행을 적고(AI 실행, 화면 대조는 '미실행'), Codex 반박 판정을 3절에 적어 줘. 커밋은 내가 한다.

## 내가 확인할 것(에뮬레이터)
- 느린 응답(서버를 멈추지 말고 FAKE_SCENARIO 또는 에뮬레이터 네트워크 지연)에서 8초 뒤 줄이 보이는지
- S06 불러오는 중 문구
- 실제 서버 400은 앱 검증이 먼저 막아 만들기 어렵다. 위젯 검사 결과로 대신한다고 기록한다
