# API 연동에 사용할 자료 (docs/integration-inputs.md)

이 문서는 실제 파일의 위치를 모은 자료표다. 새 API 계약이나 완료 보고서가 아니다.
0단계에서 내 앱 프로젝트(C:\dev\projects\icn_subway_app)의 docs\ 폴더로 복사한 뒤 채운다. 실습 자료의 원본 양식은 고치지 않는다.
경로는 앱 프로젝트 폴더 기준으로 적는다. 내 파일 이름이 다르면 같은 역할의 파일을 적는다.
Claude Code에는 이 파일과 함께 표가 가리키는 실제 파일 내용까지 읽게 한다.

작성: Claude Code(2026-10-21, 사용자 요청 '교재대로 앱을 서버에 연결해줘') · 확인: (본인 이름)

| 자료 | 실제 파일 경로 | 확인할 내용 | 남은 문제 |
|---|---|---|---|
| 5장 디자인 시스템 | docs/design-system.json | 색상·글꼴·간격·크기, 원래 시안 값과 모바일 조정 구분 | 5차 점검 결과는 문서에만 반영, 앱에는 미반영(사용자 결정) |
| 5장 컴포넌트 규칙·화면 명세 | docs/component-rules.md, docs/S02-screen-spec.md, docs/S03-screen-spec.md (S04·S05·S06-screen-spec.md도 있음) | 버튼·입력창·상태·필수 항목 | 없음 |
| 9장 화면 확인·인계 기록 | docs/handoff.md(3절 '10장에서 바꿀 곳'), reports/screen-check.csv | 적용한 테마·공통 위젯·남은 차이, handoff 3절의 바꿀 파일 | handoff 2절의 '아직 복사 안 함'은 9장 시점 기록이다(10장 0단계에서 docs/api/로 복사함) |
| 7장 API 계약 | docs/api/api-spec.yaml | URL·메서드·요청·응답·타입·오류 본문 | GET /api/tips는 토큰을 붙이면 서버가 mine을 계산한다. 10장 규칙 '공개 GET에는 토큰을 붙이지 않는다'와 다르다 → 사용자 결정(2026-10-21): 명세대로 유지(reports/app-integration.md 6절, CLAUDE.md 예외) |
| 7장 데이터 모델·인증 설계 | docs/api/data-model.md, docs/api/auth-design.md | 필드 타입, 공개·보호 요청, 로그인 응답의 토큰·사용자 필드(accessToken·user.id), 401·403 | 없음 |
| 7·8장 실제 검사 결과 | docs/api/verification.md('8장 Postman·Newman 검사' 절 포함) | 요청·기대·실제·서버 재조회·미해결 문제 | 8장 학생 직접 실행·H2 확인은 서버 기록대로 미실행 |
| 7·8장 변경·인계 | docs/api/change-review.md | 바뀐 서버 파일, Postman 파일 경로 | 없음 |
| 8장 권한표·상태 규칙(함께 읽음) | docs/api/permission-matrix.md, docs/api/state-rules.md | 401·403·405, 같은 상태를 다시 보낼 때 | 없음 |
| 응답 표본 | docs/samples/routes-list.json, docs/samples/express-steps.json, docs/samples/tips-express-3.json, docs/samples/tips-local-4.json, docs/samples/login-response.json | 실제 목록 응답, 토큰을 숨긴 로그인 응답 | 내 목록 경로는 /api/items가 아니라 /api/routes·/api/routes/{route}/steps·/api/tips(내 명세) |
| 현재 Flutter 프로젝트 | lib/, pubspec.yaml, test/ | 지금 자료를 주는 곳(더미 저장소), http 패키지 유무 | 9장에는 가짜 저장소(lib/repositories/fake_subway_repository.dart)였고 http가 없었다. 10장에서 http 1.6.0을 넣고 HTTP 저장소로 바꿈 |

- docs/api/의 파일은 내 서버 프로젝트(C:\dev\projects\icn-subway-server)의 사본이다(2026-10-21 복사, 8장과 패키지 정리까지 반영된 작업 트리). 원본이 바뀌면 다시 복사한다.
- 응답 표본은 2026-10-21 실행 서버(127.0.0.1:8097, dev 프로필)에서 Claude Code가 받아 저장했다. 로그인 응답의 accessToken은 (숨김)으로 바꿨고 비밀번호는 저장하지 않았다.
- 서버 폴더의 data/(JWT 서명 키 .jwt-secret·DB 파일)·build/는 표에 적지 않았고 읽지 않았다.

## 이번 작업 범위

- 유지할 테마·공통 위젯·화면: lib/theme(app_colors.dart·app_theme.dart), lib/widgets(common·step_widgets·tip_card·labeled_field·mixed_text), 화면 S01~S06의 배치, 입력 규칙(lib/validation/tip_rules.dart: 제목·위치 1~80자, 메모 150자, 코드 포인트)
- 먼저 연결할 공개 요청 한 개: GET /api/routes(S01 목록) → 맞으면 GET /api/routes/{route}/steps(S02 상세) → GET /api/tips?route=&step=(S02 팁)
- 실행 대상·서버 주소: Android 에뮬레이터 Medium_Phone_API_37.0(emulator-5554) / http://10.0.2.2:8097 (PC에서는 http://127.0.0.1:8097)
- 현재 문서와 코드의 차이: (1) 공개 GET /api/tips에 로그인 토큰을 붙임(명세의 mine, 2026-10-21 사용자 결정으로 유지), (2) 403 안내 문구가 '다시 로그인' 쪽(9장 결정 DEC-10) → 2026-10-21 사용자 결정으로 권한 설명 문구로 바꿈(버튼은 유지), (3) 모델이 필수 항목 누락을 기본값으로 채우던 곳 → 10장 P02에서 명세대로 바꿈. 자세한 처리는 reports/app-integration.md 1절
- 읽지 못한 자료·아직 검사하지 않은 조건: 실기기(서버가 127.0.0.1에만 열림)·iOS·Chrome(웹)·배포 HTTPS 미확인, release 빌드는 INTERNET 권한을 넣고 시작 멈춤을 고쳐(android/app/proguard-rules.pro) 에뮬레이터에서 서버 연결까지 확인(reports/app-integration.md 3절, 자료를 바꾸는 요청은 미확인), 학생 직접 실행(에뮬레이터 화면 대조·Postman 10.13.0 Runner) 미실행

아직 확인하지 않은 칸은 '미확인'으로 둔다. 이 표를 채웠다는 사실이 연결 성공을 뜻하지 않는다.
