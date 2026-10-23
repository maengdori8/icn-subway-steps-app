# 10장 실습 기록 (reports/app-integration.md)

0단계에서 내 앱 프로젝트의 reports/app-integration.md로 복사해 쓴다. 11장 P00·P01이 이 파일의 '남은 오류'를 입력으로 읽는다.
JWT·비밀번호 원문은 넣지 않는다. 제공 참고앱의 결과를 내 성공 기록으로 옮기지 않는다.
결과의 출처를 나눈다. **AI 실행**: Claude Code가 실행한 명령의 출력. **내가 확인**: 내가 에뮬레이터·서버 창·스크립트에서 직접 본 것. 아직 하지 않은 칸은 '미실행'으로 둔다.

문서 정보: 2026-10-21 · 작성 Claude Code(사용자 요청 '교재대로 앱을 서버에 연결해줘', '니가 해') · 확인: (본인 이름)

이번에는 사용자가 실행까지 맡겨서 에뮬레이터 조작·화면 캡처·Newman도 Claude Code가 했다. 그 결과는 출처를 **AI 실행(Claude Code)**으로 적고, 학생이 직접 본 칸(**내가 확인**)은 비워 둔다.

## 1. 입력 자료와 변경

- 내 앱 프로젝트 경로 / 내 서버 주소(PC·에뮬레이터): C:\dev\projects\icn_subway_app / PC http://127.0.0.1:8097 · 에뮬레이터 http://10.0.2.2:8097 (서버 C:\dev\projects\icn-subway-server, dev 프로필로 실행 중)
- 자료표 경로 / 실제 읽은 디자인·화면·API·검사 파일: docs/integration-inputs.md / docs/design-system.json, docs/component-rules.md, docs/S02·S03-screen-spec.md, docs/handoff.md, docs/api/(api-spec.yaml·data-model.md·auth-design.md·verification.md·change-review.md·permission-matrix.md·state-rules.md), docs/samples/(응답 표본 5개), lib/·pubspec.yaml·test/
- 문서와 코드의 불일치 / 처리 결정:

| 불일치 | 처리 | 결정 |
| --- | --- | --- |
| 10장 규칙은 '공개 GET에는 토큰을 붙이지 않는다'인데, 내 명세는 GET /api/tips에 토큰을 붙이면 서버가 mine(내가 올림)을 계산한다 | 명세대로 둔다. 로그인했으면 이 GET에도 토큰을 붙이고, 401이면 로그인을 지우고 토큰 없이 다시 읽는다(9장에 구현·검사함) | **결정(2026-10-21, 사용자): 명세대로 유지**. CLAUDE.md 10장 규칙 아래에 이 프로젝트의 예외로 적음 |
| 교재는 403을 '권한 부족'으로 설명하라고 한다(Q07: 다시 로그인해도 권한이 생기지 않음). 앱 문구는 '지금은 이 팁을 바꿀 수 없어요. 다시 로그인한 뒤 시도하세요'(9장 결정 DEC-10) | 로그인은 유지한다(교재와 같음). 문구를 '이 팁은 올린 사람만 바꿀 수 있어요. 다른 계정으로 로그인했다면 다시 로그인하세요.'로 바꿨다(영어 'Only the person who posted this tip can change it. If you logged in with another account, log in again.'). [다시 로그인] 버튼과 그 팁의 버튼 막힘은 DEC-10 그대로 | **결정(2026-10-21, 사용자): 권한 설명 문구로 바꿈**. docs/handoff.md 표의 '권한 없음 문구' 행은 9장 시점 기록 |
| 모델이 명세의 필수 항목이 빠져도 기본값으로 채웠다(mine·example → false, note·photoKey·elevator 키 없음 → null, 모르는 아이콘 → TRAIN) | P02: 명세대로 엄격하게 읽는다. 빠지거나 모르는 값이면 '불러오지 못했어요'(server)다. lib/models/tip.dart·guide_step.dart | 반영 |
| 9장 앱은 등록·상태 변경 응답을 화면에 넣기만 했다 | P03: 응답을 넣은 뒤 서버에서 그 단계 팁(S02)·내 팁(S06)을 다시 읽는다. 다시 읽기에 실패하면 받은 응답으로 그린 목록을 그대로 둔다 | 반영 |
| 연결 실패를 모두 '인터넷 연결 안 됨'으로 보이게 되어 있었다(9장 설계) | 기기에 망이 없을 때만 '인터넷 연결 안 됨', 서버 꺼짐·주소 문제는 '불러오지 못했어요'. 시간 초과는 따로 알리고 등록은 바로 다시 보내지 않는다(교재 2.5·Q04) | 반영 |

- 유지한 테마·공통 위젯·입력 규칙: lib/theme(색·글자·버튼·입력·하단 메뉴), lib/widgets(카드·배지·안내 상자), S01~S06 배치, 입력 규칙(제목·위치 1~80자, 메모 150자). 새 화면·색은 없다. 문구는 3개 추가(lib/l10n/app_strings.dart: postUnknown·checkTips·postFound, 한·영)하고 403 문구 1개를 사용자 결정으로 바꿨다(forbidden)
- 보낸 요청문(P01~P05) / 바뀐 파일(git diff --stat) / 커밋:
  - P01(목록·상세)·P02(모델과 표본)·P03(로그인·세션·헤더, 등록·상태 변경 뒤 재조회)을 이어서 했다. 교재의 'Plan 모드 → 편집마다 승인' 대신 사용자가 맡겼고, diff 검토와 커밋은 사용자가 한다.
  - P04(실패 기록으로 최소 수정): 이번 실행에서 실패한 요청이 없어 해당 없음. Codex 반박 두 번을 반영했다(5절).
  - P05(파일 전송): 내 API에 업로드가 없어 해당 없음.
  - 바뀐 파일(lib·test·pubspec): lib/main.dart(서버 저장소로 교체, FAKE_SCENARIO를 주면 9장 가짜 저장소), lib/repositories/http_api_transport.dart(새 파일: http 전송·제한 시간·실패 구분), http_subway_repository.dart(주석), subway_repository.dart(timeout 추가), fake_subway_repository.dart(받은 요청 기록), lib/models/tip.dart·guide_step.dart, lib/screens/step_guide_screen.dart·tip_status_actions.dart·my_tips_screen.dart·add_tip_screen.dart, lib/l10n/app_strings.dart, pubspec.yaml·pubspec.lock(http 1.6.0), reports/package-check.csv, test/(새 파일 http_transport_test.dart·server_samples_test.dart, 고친 파일 tips_test·add_tip_test·my_tips_test)
  - 10장 쓰기 범위 밖이지만 사용자 결정(2026-10-21)으로 바꾼 파일: android/app/src/main/AndroidManifest.xml(INTERNET 권한 한 줄과 설명 주석), android/app/proguard-rules.pro(새 파일: release 시작 멈춤 고침, 3절)
  - 그 밖에 만든 파일: docs/api/(서버 문서 사본 7개), docs/samples/(응답 표본 5개), docs/screenshots/ch10/(캡처 10장), postman/(10장 컬렉션·환경), reports/ch10-postman.junit.xml(Newman 결과)
  - 커밋: 아직 없음(사용자가 diff 검토 후 커밋). docs/의 5장 문서 사본 변경(S02·S03 명세 등)도 커밋 전 상태로 함께 있다.

## 2. 실행 결과

| 항목 | 기대 결과 | 실제 결과·근거 | 출처 | 상태 |
|---|---|---|---|---|
| flutter analyze | No issues found! | No issues found! (ran in 5.5s) | AI 실행 | 통과 |
| flutter test | All tests passed! | 00:13 +125: All tests passed! (9장 95개 → 125개) | AI 실행 | 통과 |
| 실행 대상·서버 주소 | Android 에뮬레이터 → http://10.0.2.2:내 서버 포트 | Medium_Phone_API_37.0(emulator-5554), debug APK, `--dart-define=API_BASE_URL=http://10.0.2.2:8097` | AI 실행(Claude Code가 에뮬레이터 조작) | AI 확인 · 내가 확인 미실행 |
| 응답한 서버 | 내 서버 주소로 PC에서 읽은 목록과 앱의 ID·이름이 같고, 앱에서 등록한 새 ID가 PC 재조회에도 보임. 서버 로그에 모든 요청이 남는다고 가정하지 않음 | 일반열차 2단계에 서버에만 있는 팁 41·10·9(8장 Newman이 만든 '[Postman] 8장 검사 …')가 PC 응답과 같은 순서·제목·위치로 보임(가짜 저장소에는 없음). 앱에서 등록한 팁이 PC `GET /api/tips/42`에 같은 값으로 보임 | AI 실행 | AI 확인 · 내가 확인 미실행 |
| 첫 공개 GET | 응답의 이름·발견 장소와 목록 화면이 같음 | S01 경로 3개(직통 5단계·일반·T2 준비 중)가 docs/samples/routes-list.json과 같음. S02 단계 문구가 express-steps.json과 같음 | AI 실행 | AI 확인 · 내가 확인 미실행 |
| 로그인·보호 요청 | 내 명세의 인증 규칙대로 | student01 로그인 → S03(그 단계)으로 이동, 등록·상태 변경 성공, 로그아웃 → S06 '로그인 필요' 안내. 로그아웃 상태의 [+ 팁 추가]는 요청 없이 S04를 연다. 토큰은 메모리에만 있다(shared_preferences에 저장하지 않음) | AI 실행 | AI 확인 · 내가 확인 미실행 |
| 새 물건 등록·재조회 | 응답 ID와 목록·상세의 ID가 같음 | 앱에서 'Ch10 app tip 1505'(위치 'Gate B1 left side', 메모 'Checked on the emulator') 등록 → 서버 42번(같은 값, 등록자 101). 앱이 목록을 다시 읽어 42번이 맨 위에 보임. 앱에서 '오래됨'으로 바꿈 → 서버 42번 OUTDATED, verifiedAt 새 시각. S06 목록(42·41·10·9·8)이 서버 `GET /api/me/tips`와 같음 | AI 실행 | AI 확인 · 내가 확인 미실행 |
| 401·403·실패 뒤 값 | 거부 이유가 다르고 값이 그대로 | 10장 Postman 컬렉션을 Newman 6.2.1로 2번 실행: 요청 31·검사 78·실패 0(2회차 보고서 reports/ch10-postman.junit.xml). 토큰 없는 등록 401·팁 개수 그대로, 토큰 없는 상태 변경 401·값 그대로, 무효 토큰 공개 GET 401, B의 상태 변경 403(두 번)·값·상태·등록자 그대로, B·A의 DELETE 405(삭제 API 없음), A의 상태 변경·같은 상태 재요청 200(verifiedAt만 새로), 잘못된 status·ownerId 본문 400, 없는 번호 404 | AI 실행(Newman) — Postman 10.13.0 Runner는 내가 확인 | AI 확인 · Postman 앱 실행 미실행 |
| 디자인 유지 | 9장 테마·공통 위젯·화면 규칙 유지 | 연결 뒤 화면(docs/screenshots/ch10/)이 9장 캡처(docs/screenshots/)와 같은 테마·카드·배지·버튼·배치. 다른 것은 서버 자료(팁 41·10·9·42)뿐 | AI 실행 | AI 확인 · 내가 확인 미실행 |

- 서버가 멈췄을 때(교재 005 9번): 서버가 없는 주소(`API_BASE_URL=http://10.0.2.2:8099`)로 실행 → S01 로딩이 끝나고 '불러오지 못했어요. 다시 시도' + [다시 시도]. '인터넷 연결 안 됨'으로 단정하지 않음(docs/screenshots/ch10/S01-server-down-8099.png). AI 실행 · 내가 확인 미실행
- 9장 화면과 연결 뒤 화면의 캡처 경로 / 차이: 9장 docs/screenshots/, 10장 docs/screenshots/ch10/ — S01-server-routes, S02-local-step2-server-tips, S04-login-filled(비밀번호는 가림), S03-add-tip-filled, S02-after-post-requery, S02-status-outdated, S06-my-tips-server, S05-logged-in, S06-logged-out, S01-server-down-8099 / 차이: 자료 출처(서버)만 다르다
- 선택 파일 전송 결과(하지 않았으면 미실행): 해당 없음(내 API에 업로드가 없다. P05 미실행)
- 검증하지 않은 플랫폼(실기기·iOS·배포 HTTPS 등): 실기기(서버가 127.0.0.1에만 열림), iOS, Chrome(웹은 서버 CORS로 막힘), 배포 HTTPS, TalkBack 낭독
- release 빌드: android/app/src/main/AndroidManifest.xml에 INTERNET 권한을 넣었다(사용자 결정). `flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:8097` 성공(51.2MB), 합친 매니페스트(build/app/intermediates/merged_manifest/release/…)에 INTERNET이 들어 있고 설치한 앱에도 권한이 있다(AI 실행). 처음에는 release 앱이 시작 화면에서 멈췄다(9장부터 있던 문제, INTERNET 권한과 관계없음, 3절). android/app/proguard-rules.pro로 고친 뒤 release 앱으로 서버 연결을 확인했다(AI 실행): S01 경로 목록, 일반열차 2단계의 서버 팁(41·10·9, 지난 팁 42)이 서버 응답과 같음, student01 로그인 → 내 팁(토큰이 필요한 GET /api/me/tips) 42·41·10·9·8. 앱 오류 로그 0줄. 캡처 docs/screenshots/ch10/release-S01-server-routes.png·release-S02-server-tips.png·release-S06-my-tips.png. 학생 확인 미실행

## 3. 남은 오류 (11장 재현 보고서와 같은 항목)

debug 앱(자동 검사·에뮬레이터)과 Newman에서는 실패한 요청·화면이 없다. release 빌드에서 아래 오류 하나를 찾았고, 같은 날 고쳐 다시 확인했다(아래 '수정과 재검증'). 11장에 남은 재현 항목은 없다.

- 제목: release 빌드가 시작 화면에서 멈춤(shared_preferences 플러그인, R8 코드 줄이기) — **해결(2026-10-21)**
- 실행 대상 / API 주소 / 계정 역할(비밀번호·토큰 제외) / 관련 물건 ID: Android 에뮬레이터 Medium_Phone_API_37.0의 release APK / http://10.0.2.2:8097 / 로그인 전 / 해당 없음
- 재현 순서: 1. `flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:8097` 2. `adb install -r build/app/outputs/flutter-apk/app-release.apk` 3. 앱을 연다
- 기대 결과와 근거가 되는 명세: debug와 같이 S01 경로 목록이 보인다(교재 10장 7.2: 배포할 앱도 main 매니페스트의 INTERNET으로 통신)
- 실제 결과(상태 코드 / 화면 / 비밀값 없는 본문 / 같은 ID 재조회 결과): 요청 전에 멈춤. 화면은 Flutter 시작 화면(로고)에서 넘어가지 않음. logcat: `E flutter : Unhandled Exception: PlatformException(PlatformException, java.lang.NoSuchMethodError: no non-static method "Lio/flutter/plugins/sharedpreferences/SharedPreferencesApiRegistrar;.getAll(...)"` (AI 실행, 2026-10-21)
- 원인 후보(관찰한 사실과 추정을 나누어): 관찰 — main()의 `SharedPreferences.getInstance()`에서 예외가 나고 debug 빌드에서는 같은 코드가 정상이다. 플러그인 shared_preferences_android 2.5.1 폴더에 proguard(keep) 규칙 파일이 없다. 추정 — release 빌드의 R8이 Dart가 JNI로만 부르는 플러그인 메서드(getAll)를 쓰지 않는 코드로 보고 지웠다. 고칠 후보: android/app/proguard-rules.pro에 keep 규칙, 또는 이 문제를 고친 플러그인 버전.
- 수정과 재검증(사용자 요청 'release 시작 멈춤도 지금 고치고, release로 서버 연결까지 확인해줘', AI 실행):
  - 원인 확인: shared_preferences_android 최신 버전이 지금 쓰는 2.5.1이라(pub.dev) 버전 올리기로는 못 고친다. jni 1.1.0은 자기 클래스만 지키는 규칙(consumer-rules.pro)이 있고, 이 플러그인에는 규칙이 없다.
  - 수정한 파일: android/app/proguard-rules.pro(새 파일). `-keep class io.flutter.plugins.sharedpreferences.** { *; }`와, jni·플러그인의 Dart 코드가 이름으로 찾는 Kotlin 클래스 6개(kotlin.Unit, kotlin.Result, kotlin.Result$Failure, kotlin.coroutines.Continuation, kotlin.coroutines.intrinsics.IntrinsicsKt, kotlin.coroutines.intrinsics.CoroutineSingletons)를 지킨다. Flutter 빌드 도구가 이 파일을 자동으로 읽어 build.gradle.kts는 바꾸지 않았다(build/app/outputs/mapping/release/configuration.txt에 들어간 것을 확인).
  - 1차 수정(플러그인 규칙과 Continuation만) 뒤에는 `ClassNotFoundException: kotlin/coroutines/intrinsics/CoroutineSingletons`로 다시 멈췄다. 그래서 Dart 쪽에서 이름으로 찾는 Kotlin 클래스를 모두 찾아 2차로 넣었다.
  - 실행한 명령과 결과: `flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:8097` 성공(51.2MB) → `adb install -r` → 앱 시작, 앱 오류 로그(E flutter) 0줄 → S01·S02·로그인·내 팁이 서버 자료와 같음(2절 release 줄). 그 뒤 debug 앱을 다시 설치했고 `flutter analyze` No issues found!, `flutter test` 125개 통과.
  - 아직 확인하지 않은 범위: release에서 팁 올리기·상태 바꾸기(자료를 바꾸는 요청), 실기기, 배포용 서명(지금 release도 debug 키로 서명), 설정 저장 말고 다른 플러그인을 더할 때의 규칙. 학생 확인 미실행.

알려진 한계(실패는 아님, 11장에서 다시 볼 것):
- 등록이 시간 초과되면 앱은 바로 다시 보내지 않고 [팁 목록 확인]으로 서버를 먼저 읽는다. 그래도 '목록에 없음'이 원래 요청이 아직 처리 중일 가능성까지 없애지는 못한다. 완전한 중복 방지는 서버의 요청 식별자(멱등 키)가 필요하다(서버 범위).
- 같은 사용자가 다시 로그인하는 사이에 앞 세션의 S06(내 팁) 요청이 401로 늦게 오면 '불러오지 못했어요'가 한 번 보일 수 있다(다시 시도로 회복). Codex 2회차 의견, 5절.

## 4. Postman 10.13.0 설치와 직접 실행 순서

- 설치(Claude Code가 실행, 사용자 승인): 공식 파일 Postman-win64-10.13.0-Setup.exe(dl.pstmn.io, 167,256,112바이트, 서명 Postman, Inc. 유효)를 C:\dev\tools\postman-10.13.0\에 받아 설치했다. 위치 %LOCALAPPDATA%\Postman\app-10.13.0.
- 처음 열 때 Postman이 스스로 10.24.26을 내려받아 app-10.24.26 폴더가 생겼다. 10.13.0을 지키려고 업데이트 프로그램(Update.exe)을 Update.exe.disabled로 이름을 바꿨다(되돌리려면 이름을 다시 Update.exe로). 바탕화면 **'Postman 10.13.0'** 아이콘이 10.13.0을 바로 연다. 기존 'Postman' 아이콘·시작 메뉴는 10.24.26을 연다(app-10.24.26 폴더를 지울지는 사용자가 정한다).
- 컬렉션: postman/ch10-app-integration.collection.json(요청 31개, 폴더 6개), 환경 postman/ch10.environment.json(비밀번호·팁 제목은 비어 있음). 근거는 docs/api/api-spec.yaml·permission-matrix.md·state-rules.md와 교재 005_검사순서. Postman 10.13.0에서 되는 스크립트 기능만 썼다(정적 검사).
- 직접 실행 순서(내가 확인 칸):
  1. 서버를 켜고, 앱에서 A(student01)로 겹치지 않는 제목의 팁을 하나 올린다(앱 화면에는 팁 번호가 없어 제목으로 찾는다).
  2. 바탕화면 'Postman 10.13.0'으로 연다. 로그인하지 않고 쓰려면 Scratch Pad(계정 없이 쓰기)를 고른다(화면 문구는 다를 수 있다).
  3. Import로 위 컬렉션과 환경을 가져온다.
  4. Environments에서 passwordA·passwordB의 Current Value에 표본 비밀번호(서버 docs/requirements.md의 공개 표본 값)를, appTipTitle의 Current Value에 1의 제목을 직접 입력한다. Initial Value는 비워 두고, 값이 든 환경은 내보내지 않는다.
  5. 오른쪽 위에서 환경을 고르고 컬렉션의 Run → Runner로 처음부터 순서대로 실행한다. 기대: 31개 요청, 실패 0. 첫 폴더에 '앱이 만든 팁 번호 N(제목으로 찾음)'이 보인다.
  6. 결과를 2절 '401·403·실패 뒤 값' 행에 '내가 확인'으로 적는다.
- Newman으로 할 때: `newman run postman/ch10-app-integration.collection.json -e postman/ch10.environment.json --env-var passwordA=<표본 비밀번호> --env-var passwordB=<표본 비밀번호> --env-var "appTipTitle=<앱에서 쓴 제목>"`(비밀번호는 칠 때만 넣고 파일에 쓰지 않는다)

## 5. Codex 반박 판정 (C:\dev\CLAUDE.md 규칙, 같은 변경 최대 2회)

1회차(앱 변경과 컬렉션 전체):

| # | 지적 | 판정 | 이유 | 조치 |
| --- | --- | --- | --- | --- |
| 1 | 제한 시간을 헤더·본문에 따로 걸어 최대 약 30초까지 기다림 | 수용 | 맞음 | 보내기부터 본문을 다 받기까지 한 번의 제한 시간(15초). 늦은 헤더+늦은 본문 검사 추가 |
| 2 | 시간 초과 뒤 사용자가 다시 올리면 팁이 중복될 수 있음 | 수용 | 교재 2.5·Q04와 같음 | 시간 초과를 timeout으로 따로 알리고, S03은 바로 다시 보내지 않고 [팁 목록 확인] 안내 |
| 3 | 이름 풀이·호스트 접근 실패까지 '인터넷 없음'으로 단정 | 수용 | 앱 원칙(원인을 단정할 수 있을 때만 오프라인 문구) | 오프라인은 기기 망 없음(ENETDOWN·ENETUNREACH)만 |
| 4 | S02 재조회 응답에 세션 세대 검사가 없음 | 수용 | 경합을 검사로 재현함 | 성공·실패 응답 모두 세션이 바뀌었으면 버림. 회귀 검사(고치기 전 실패 확인) |
| 5 | 컬렉션이 중간에 멈추면 토큰이 남음 | 수용 | 맞음 | 멈추는 곳마다 토큰을 비움(정적 검사로 확인) |
| 6 | 비밀번호를 파일에 넣으라는 안내 | 수용 | CLAUDE.md 규칙과 충돌 | Postman Current Value 직접 입력·Newman --env-var로 바꿈 |
| 7 | 앱 화면에 팁 번호가 없어 appTipId를 얻을 수 없음 | 수용 | 맞음 | 제목(appTipTitle)으로 A의 내 팁에서 찾게 바꿈 |
| 8 | release 빌드에 INTERNET 권한이 없음 | 보류 → 결정 | 10장 쓰기 범위(lib·test·pubspec) 밖, debug 실행만 확인 | 사용자 결정(2026-10-21): main 매니페스트에 넣음(6절 결정 3). release 시작 멈춤은 별도 오류(3절) |
| — | 공개 GET /api/tips 토큰(의견) | 보류 → 결정 | 명세·9장 결정과 10장 규칙이 다름 | 사용자 결정(2026-10-21): 명세대로 유지(6절 결정 1) |

2회차(1회차 반영분):

| # | 지적 | 판정 | 이유 | 조치 |
| --- | --- | --- | --- | --- |
| 1 [높음] | 시간 초과 뒤 하단 [팁 올리기] 버튼으로는 확인 없이 다시 보내짐 | 수용 | 검사로 재현함 | 하단 버튼도 목록부터 확인. 회귀 검사(고치기 전 실패 확인) |
| 2 | 같은 내용의 예전 팁을 이번 등록 성공으로 잘못 알림 | 수용(문구) | 이번 요청이 저장한 것인지 앱이 구별할 수 없음 | '이 단계 팁 목록에 같은 팁이 이미 있어요'로 알림, 다시 보내지 않음 |
| 3 | 확인 도중 로그인이 바뀌면 판단이 틀릴 수 있음 | 수용(방식 변경) | 지금 계정의 mine에 기대고 있었음 | 보낸 사용자 번호(ownerId)로 비교, 로그아웃해도 토큰 없이 확인, 401이면 세션만 정리. 검사 추가 |
| 4 | 컬렉션 조회 응답 모양이 이상하면 토큰 정리·중단을 건너뜀 | 수용 | 모의 실행으로 재현함 | 예외 처리, 시작할 때 팁 번호·비교 기준을 비움. `{}`·`tips:null`·JSON 아님 3가지 모의 실행 확인 |
| — | S06 기각 근거('즉시 새 요청') 반박 | 보류(작음) | 다른 사용자로 바뀌면 다음 화면을 그리기 전에 목록을 비워 앞 자료는 보이지 않는다. 같은 사용자 재로그인 때의 늦은 401만 남는다 | 3절 알려진 한계 |

2회차 반영 뒤 3회차 리뷰는 받지 않았다(규칙상 최대 2회, 이후는 사용자 판단).

## 6. 확인할 질문(사용자 결정)

1. **결정됨(2026-10-21, 사용자: '팁 목록 GET 토큰은 지금처럼 명세대로 유지해')**: 공개 GET /api/tips에 로그인 토큰을 계속 붙인다. 서버가 요청 토큰으로 mine(내가 올림)을 계산하는 명세(docs/api/api-spec.yaml)와 9장 결정 '서버 mine 사용'을 따른다. 만료·무효 토큰이면 공개 조회도 401이므로, 앱은 요청 당시 세션이면 로그인을 지우고 토큰 없이 다시 읽는다(tips_test.dart '팁 조회가 401(만료 토큰)이면 로그아웃하고 익명으로 다시 읽는다', 컬렉션 '무효 토큰으로 공개 팁 목록 · 401'). 다른 공개 GET(경로·단계)에는 토큰을 붙이지 않는다. 교재 10장 규칙과 다른 점이라 CLAUDE.md '## 10장 작업 규칙' 아래에 이 프로젝트의 예외로 적었다.
2. **결정됨(2026-10-21, 사용자: '403 문구는 추천대로 바꾸고')**: 403 안내를 권한 설명으로 바꿨다. 한국어 '이 팁은 올린 사람만 바꿀 수 있어요. 다른 계정으로 로그인했다면 다시 로그인하세요.', 영어 'Only the person who posted this tip can change it. If you logged in with another account, log in again.'(lib/l10n/app_strings.dart forbidden). 로그인 유지, [다시 로그인] 버튼, 그 팁의 버튼 막힘은 9장 DEC-10 그대로다. 이 앱에서 403은 화면의 목록이 예전 로그인 기준일 때 주로 생기고, 다시 로그인하면 목록을 새로 읽기 때문이다. 문구를 확인하는 검사 4곳(tips_test.dart 3곳, my_tips_test.dart 1곳)을 새 문구로 바꿨고 flutter test 125개 통과.
3. **결정됨(2026-10-21, 사용자: 'release용 인터넷 권한도 넣어줘')**: android/app/src/main/AndroidManifest.xml에 `<uses-permission android:name="android.permission.INTERNET" />`를 넣었다(교재 10장 7.2). release APK의 합친 매니페스트와 설치한 앱에서 권한을 확인했다. release 앱이 시작할 때 멈추는 문제는 이 권한과 관계없는 별도 오류였고, 사용자 요청으로 android/app/proguard-rules.pro를 더해 고친 뒤 release 앱으로 서버 연결(목록·로그인·내 팁)까지 확인했다(3절 '수정과 재검증').
