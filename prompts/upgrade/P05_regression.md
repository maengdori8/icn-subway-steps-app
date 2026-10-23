# P05 회귀 검사·화면 대조·기록 (P02~P04 뒤)

권한 모드: Manual
먼저 할 일: P02~P04를 커밋한다. 내 서버를 켠다(PC http://127.0.0.1:8097).

## 요청
P02~P04에서 바꾼 것 전체를 다시 확인해 줘.
1. flutter analyze와 flutter test를 실행하고 마지막 줄을 그대로 보여 줘.
2. docs/upgrade-gap.md 의 필수 11개(C-15, C-19, C-24, C-26, S2-01, S2-02, S2-03, S2-06, S3-01, S5-01, S6-01)마다 '바꾼 파일·검사 이름·결과'를 표로 정리해 reports/upgrade-log.md 1절에 맞춰 줘. 검사가 없는 항목은 '검사 없음'으로 적어 줘.
3. 서버 연결 코드(lib/repositories)를 바꾸지 않았는지 git diff로 확인해 줘. 바꿨다면 postman/ch10-app-integration.collection.json 을 다시 돌려야 한다고 알려 줘.
4. 내가 에뮬레이터에서 볼 확인 목록을 만들어 줘(화면·조작·기대 결과·캡처 파일 이름 docs/screenshots/upgrade/…). 화면 결과는 내가 알려 주기 전까지 '미실행'으로 둬.
5. reports/upgrade-log.md 4절에 남은 문제와 다음 묶음(권장·선택, docs/upgrade-gap.md 4절 질문 7~24)을 정리해 줘.
토큰·비밀번호를 기록에 쓰지 마. 커밋은 내가 한다.
