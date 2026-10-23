# ICN Subway Steps · Flutter 앱

인천공항 1터미널(T1) 입국장에서 서울역행 공항철도(AREX) 열차에 탈 때까지를 단계별 사진 카드로 안내하는 앱입니다. 직통열차와 일반열차를 각각 5단계로 나눠 단계마다 현장 사진, 한·영 표지판 칩, 할 일을 보여 줍니다. 다른 여행객이 남긴 팁을 단계마다 볼 수 있고, 로그인하면 팁을 올리고 내 팁의 상태를 바꿀 수 있습니다.

- 앱은 [ICN Subway Steps 서버](https://github.com/maengdori8/icn-subway-steps-server)(Spring Boot 4 · Java 21 · H2 · JWT)에 HTTP로 연결합니다.
- 'AI활용 모바일 앱 풀스택 개발' 수업 프로젝트입니다. 9장에서 확정 시안(`docs/screens/ICN-subway-steps-v03.src.html`)을 가짜 저장소로 화면에 옮기고, 10장에서 서버에 연결한 뒤 5장 설계 자료에 맞춰 고도화했습니다.
- 표지판 글자와 안내 문구는 현장 확인 전 초안입니다. 층수·승강장 위치·요금·시간은 지어내지 않고 적지 않았습니다.

## 화면

| 화면 | 내용 |
| --- | --- |
| S01 경로 목록 | 직통·일반열차 경로와 진행 상태. T2 경로는 '준비 중'으로만 보입니다 |
| S02 단계 안내 | 사진(넘기면 정육면체처럼 돎), 표지판 칩, 할 일, 단계별 팁, 아래 고정 이전/다음 버튼, 완료 화면 |
| S03 팁 등록 | 제목·위치 1~80자, 메모 0~150자(코드 포인트 기준)를 검사한 뒤 올림 |
| S04 로그인 | 서버 로그인(JWT). 계정이 없으면 파란 '회원가입' 링크 |
| S05 설정 | 밝게/어둡게, 한국어/English, 사진 출처 |
| S06 내 팁 | 내가 올린 팁 목록과 '확인함/오래됨' 상태 바꾸기 |
| S07 회원가입 | 아이디(영어 소문자·숫자·밑줄 4~24자)와 비밀번호(8자 이상). 가입하면 바로 로그인됩니다 |

하단 메뉴(떠 있는 캡슐 모양)는 S01·S06·S05에만 있습니다.

## 서버 연결

- 서버 주소는 `--dart-define=API_BASE_URL=...`로 줍니다. 기본값은 `http://10.0.2.2:8097`(Android 에뮬레이터에서 본 PC의 localhost)입니다.
- 서버가 127.0.0.1에서만 받으므로 실제 휴대폰은 접속할 수 없습니다. 웹(Chrome)에서 서버 연결은 확인하지 않았습니다(서버에 CORS 설정이 없음).
- 경로·단계 같은 공개 GET에는 토큰을 붙이지 않습니다. 팁 등록·상태 변경·내 팁에는 `Authorization: Bearer` 토큰을 붙입니다.
  - 예외: `GET /api/tips`는 로그인했으면 토큰을 붙여, 서버가 내가 올린 팁(mine)을 표시하게 합니다(reports/app-integration.md 6절).
- 로그인 토큰은 메모리에만 두고 기기에 저장하지 않습니다. 보호 요청이 401이면 로그아웃해 다시 로그인하게 하고, 403이면 로그인을 유지한 채 권한을 설명합니다.
- 요청 하나는 15초까지 기다립니다. 연결 끊김·시간 초과·서버 오류를 나눠 안내하고, 실패한 등록·변경은 자동으로 다시 보내지 않습니다.
- 연결이 끊긴 동안에는 3초마다, 앱으로 돌아오면 바로 목록을 다시 읽습니다. INTERNET 말고 다른 권한은 쓰지 않습니다.
- 표본 계정은 student01·student02입니다. 비밀번호는 서버 저장소의 docs/requirements.md에 있는 공개 표본 값이며 로컬 실습 전용입니다.

## 실행

Flutter 3.47.7(Dart 3.13.5)에서 확인했습니다. 서버를 먼저 켜 둡니다(서버 README의 '실행').

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8097
```

- 서버 없이 화면만 볼 때: `flutter run --dart-define=FAKE_SCENARIO=none`. 9장 가짜 저장소로 실행되고, 앱을 다시 켜면 처음 자료로 돌아갑니다.
  - 다른 값: `offline`(첫 경로 읽기 연결 끊김), `empty`(경로 0건), `tips-error`(첫 팁 읽기 실패).
  - 가짜 저장소의 로그인은 실제 인증이 아닙니다. 비밀번호를 비우지 않으면 되고, 아이디 `wrong`만 실패합니다.
- release 빌드: `flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:8097`. R8이 shared_preferences 플러그인 코드를 지워 시작 화면에서 멈추던 문제를 android/app/proguard-rules.pro로 막았습니다.

## 구조

| 위치 | 내용 |
| --- | --- |
| lib/main.dart, app.dart | 시작(서버 저장소, FAKE_SCENARIO를 주면 가짜 저장소), MaterialApp(테마·언어·하단 알림) |
| lib/screens/ | S01~S07 화면, 하단 메뉴가 있는 home_shell, 팁 상태 바꾸기(tip_status_actions.dart) |
| lib/repositories/ | 저장소 약속(subway_repository.dart), 서버 저장소(http_subway_repository.dart)와 HTTP 전송(http_api_transport.dart), 가짜 저장소와 처음 자료(fake_*) |
| lib/models/ | 경로·단계·팁·로그인 결과(서버 명세의 camelCase), step_photos.dart(photoKey → 앱 사진·출처) |
| lib/state/app_controller.dart | 테마·언어·경로별 진행(기기에 저장), 로그인(메모리), 경로·단계 목록 |
| lib/widgets/ | 공통 위젯, 떠 있는 하단 메뉴(floating_tab_bar.dart), 연결 끊김 안내와 자동 다시 읽기(offline_message.dart) |
| lib/validation/ | 팁 입력 규칙(tip_rules.dart), 회원가입 규칙(signup_rules.dart) |
| lib/theme/, lib/l10n/ | design-system.json의 색·글자·간격, 화면 문구 한국어/English |
| assets/photos/ | 단계 사진 8장과 출처(CREDITS.md) |
| test/ | 위젯 검사, 서버 명세·응답 표본과 맞는지 보는 계약 검사, HTTP 전송 검사 |
| docs/ | 5장 설계 자료 사본(읽는 순서는 docs/000_읽는순서.md), 서버 문서 사본(api/), 서버 응답 표본(samples/), 화면 캡처(screenshots/) |
| reports/ | 10장 서버 연결 기록(app-integration.md), 고도화 기록(upgrade-log.md), 화면 검사표, 패키지 확인표, Newman 결과 |
| postman/ | 10장 Postman 컬렉션(요청 31개)과 환경(비밀번호 칸은 비어 있음) |
| prompts/upgrade/ | 고도화 요청문(P00~P05) |

## 확인한 결과

- flutter analyze 문제 없음, flutter test 193개 모두 통과(AI 실행, 2026-10-23).
- 10장 Postman 컬렉션을 Newman으로 실행해 요청 31개·검사 78개가 모두 통과했습니다(AI 실행, reports/ch10-postman.junit.xml).
- 에뮬레이터에서 사람이 직접 대조하는 확인은 reports/app-integration.md의 '내가 확인' 칸에 따로 남깁니다.

## 사진 출처

단계 사진은 인천국제공항공사(공공데이터포털, 공공누리 제1유형)와 위키미디어 공용 사진(CC BY-SA 4.0·2.0, CC BY 2.5)을 줄이거나 잘라 썼습니다. 작성자·라이선스·원본 주소는 `assets/photos/CREDITS.md`와 앱의 설정 > 사진 출처에 있습니다.
