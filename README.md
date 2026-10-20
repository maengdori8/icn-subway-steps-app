# ICN Subway Steps · Flutter 앱 (9장 화면 구현)

인천공항 T1 입국장에서 서울역행 공항철도(AREX) 열차에 탈 때까지를 단계별 사진 카드로 안내하는 앱입니다(직통열차·일반열차 각 5단계). 확정 시안 `docs/screens/ICN-subway-steps-v03.src.html`을 Flutter로 옮겼습니다. 서버 연결은 10장에서 하고, 지금은 **메모리 가짜 저장소**로 동작합니다(앱을 다시 켜면 처음 자료로 돌아감).

## 실행

```powershell
$env:Path = 'C:\dev\flutter\bin;' + $env:Path; $env:PUB_CACHE = 'C:\dev\pub-cache'
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554        # 또는 -d chrome
```

- 시연 로그인: 아이디는 아무 값(비밀번호는 비우지만 않으면 됨). `student01`은 예시 팁 2번(일반열차 4단계)의 주인이고, 아이디 `wrong`은 로그인 실패를 보여 줍니다. 실제 인증이 아닙니다.
- 상태 확인용 가짜 상황: `flutter run --dart-define=FAKE_SCENARIO=offline` (첫 경로 읽기 연결 끊김), `empty` (경로 0건), `tips-error` (첫 팁 읽기 실패).
- 10장 서버 주소: `--dart-define=API_BASE_URL=...` (기본 `http://10.0.2.2:8097`, 에뮬레이터에서 PC의 localhost).

## 구조

| 위치 | 내용 |
| --- | --- |
| lib/main.dart, app.dart | 시작, MaterialApp(밝게·어둡게 테마, 언어, 하단 알림) |
| lib/screens/ | S01 경로 목록, S02 단계 안내, S03 팁 등록, S04 로그인, S05 설정, S06 내 팁, 하단 메뉴(home_shell) |
| lib/models/ | 경로·단계·팁·로그인 결과(JSON 이름은 docs/ui-handoff.md 후보의 snake_case) |
| lib/repositories/ | 저장소 약속(subway_repository.dart), 가짜 저장소와 처음 자료(fake_*), HTTP 뼈대(http_subway_repository.dart) |
| lib/state/app_controller.dart | 테마·언어·경로별 진행(기기에 기억), 로그인(메모리), 경로·단계 목록 |
| lib/theme/ | design-system.json의 색(colors / colorsDark)·글자·간격 |
| lib/l10n/ | 화면 문구 en/ko(시안의 T 사전) |
| lib/validation/tip_rules.dart | 팁 입력 규칙(코드 포인트 기준 1~80 / 150) |
| test/ | 위젯 검사(하단 메뉴, 이동, 완료, 팁 경계, 로그인, 설정, 내 팁, 글자 1.3·2.0배) |
| docs/ | 5장 설계 자료 사본, 9장 인계(handoff.md), 에뮬레이터 화면(screenshots/) |
| reports/ | 화면 검사표(screen-check.csv), 패키지 확인표(package-check.csv) |

사진 출처: `assets/photos/CREDITS.md`와 앱의 설정 > 사진 출처.
