# P02 S02 단계 이동·큰 글자·빈 단계·낭독 (필수)

권한 모드: 요청 1은 Plan, 요청 2는 Manual
대상 ID: S2-01, S2-02, S2-03, S2-06, C-24(docs/upgrade-gap.md)
먼저 할 일: P01에서 질문 5(큰 글자 문턱) 답을 적어 둔다.

## 요청 1 (Plan 모드에서 보낸다)
@docs/upgrade-gap.md 의 S2-01·S2-02·S2-03·S2-06·C-24 행과, 각 행이 가리키는 명세(@docs/S02-screen-spec.md 의 규칙·상태 절, @docs/design-system.json, @docs/component-rules.md)를 읽어 줘.
지금 코드 lib/screens/step_guide_screen.dart, lib/widgets/common.dart, lib/widgets/step_widgets.dart, test/helpers.dart 도 읽어 줘. 지금은 고치지 마.
항목마다 '명세 규칙 → 지금 동작 → 바꿀 방법(파일·함수) → 추가할 검사 이름'을 표로 정리해 줘.
reports/upgrade-log.md '0. 결정'의 질문 5 답을 따르고, docs/handoff.md 1절 '글자 2배 이상' 행과 달라지는 점을 먼저 알려 줘.

## 요청 2 (계획을 승인한 뒤 Manual로 보낸다)
승인한 계획대로 고쳐 줘.
- 단계를 옮기면(이전·다음·사진 밀기·전체 단계 목록) 본문을 맨 위로 올린다. 동작 줄이기 설정이면 바로 옮긴다.
- 큰 글자 판정은 명세대로 본문 16 기준 배율로 한다(1.3배 이상이면 '전체 단계'를 다음 줄로, 1.7배 이상이면 이전·다음을 본문 끝으로). 비선형 배율(Android 200%에서 본문 약 1.75배)도 맞게 판정한다.
- 단계가 0개인 경로는 완료 화면 대신 명세의 빈 상태(문구 en·ko, [경로 목록으로])를 보인다.
- 새 팁으로 스크롤하는 애니메이션은 동작 줄이기 설정이면 하지 않는다.
- 전체 단계 목록 항목과 펼침 버튼이 낭독에서 누를 수 있는 항목·펼침 상태로 읽히게 한다(SemanticsService.announce는 deprecated라 쓰지 않는다).
- 서버 연결과 10장 검사는 그대로 둔다. 디자인 값은 design-system.json 값만 쓴다.
위 동작마다 위젯 검사를 추가해 줘(비선형 TextScaler, disableAnimations, 빈 단계, tester.getSemantics 포함). flutter analyze·flutter test 마지막 줄을 보여 줘.
reports/upgrade-log.md 1절 P02 행에 바꾼 파일과 analyze·test 결과(AI 실행)를 적고 화면 대조 칸은 '미실행'으로 둬. 2절에 handoff.md와 달라진 문턱을 적어 줘.
로직 변경이라 커밋 전에 Codex 반박을 받아 3절에 판정을 적어 줘. 커밋은 내가 한다.

## 내가 확인할 것(에뮬레이터)
- 일반열차 2단계(서버 팁 여러 개)에서 팁까지 내린 뒤 '다음' → 진행 표시가 화면 맨 위에 보이는지
- 기기 글꼴 130%·200%에서 S02 하단 바(docs/screenshots/S02-step2-ko-font2x*.png와 비교)
- 개발자 옵션에서 애니메이션을 끄고 팁을 올렸을 때 새 팁으로 바로 이동하는지
