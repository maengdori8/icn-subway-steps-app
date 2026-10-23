# 앱 고도화 기록 (reports/upgrade-log.md)

P00에서 prompts/upgrade/upgrade-log-template.md를 복사해 만든다. 결과의 출처를 나눈다. AI 실행: Claude Code가 실행한 명령의 출력. 내가 확인: 내가 에뮬레이터에서 직접 본 것. 아직 하지 않은 칸은 '미실행'.
토큰·비밀번호 원문은 넣지 않는다. 항목 ID는 docs/upgrade-gap.md를 따른다.

## 0. 결정 (P01)

| 질문 | 내 답 | 날짜 |
|---|---|---|
| 1 마감 전 범위 | P02~P04만(필수 11개). 권장·선택 묶음과 애플식 3가지는 마감(10-22) 뒤 | 2026-10-21 |
| 2 낡은 5장 문서(K-01~K-08) | P05 뒤 Claude가 5장 원본(C:\dev\chapter05-ai\docs)을 고치고 앱 docs/ 사본을 다시 복사(앱 폴더 밖 쓰기 허락) | 2026-10-21 |
| 3 S03 시간 초과 흐름 | 10장 앱 방식([팁 목록 확인] 뒤 다시 올리기) 유지. S03 명세는 문서 동기화 때 맞춤 | 2026-10-21 |
| 4 S03 400 칸 오류 문구 | 앱 입력 검사를 다시 돌려 맞는 문구를 보이고, 맞는 종류가 없으면 일반 문구(이 칸을 다시 확인하세요 류). route·stepNo 오류는 지금처럼 상자 | 2026-10-21 |
| 5 S02 큰 글자 문턱 | 명세대로 본문 16 기준 1.3배·1.7배. docs/handoff.md '글자 2배 이상' 행과 달라진 점은 2절에 기록 | 2026-10-21 |
| 6 S05 버전 문구 | 5차 안: '버전 1.0.0 · 학생 실습 프로젝트 / Version 1.0.0 · student project', 가짜 저장소로 실행할 때만 '· 시연용 데이터 / · Demo data'를 붙임 | 2026-10-21 |

P01 확인(AI 실행, 2026-10-21): docs/upgrade-gap.md의 필수 11개(C-15, C-19, C-24, C-26, S2-01, S2-02, S2-03, S2-06, S3-01, S5-01, S6-01)가 모두 지금 코드에서 표대로임을 직접 확인했다(예: labeled_field.dart:64-65, home_shell.dart:26, step_guide_screen.dart:98·168·256, step_widgets.dart:73).

## 1. 요청문별 진행

| 요청문 | 대상 ID | 바꾼 파일 | flutter analyze | flutter test | 화면 대조(내가 확인) | Codex | 커밋 |
|---|---|---|---|---|---|---|---|
| P02 | S2-01, S2-02, S2-03, S2-06, C-24 | lib/screens/step_guide_screen.dart, lib/widgets/step_widgets.dart, lib/widgets/common.dart, lib/l10n/app_strings.dart(noSteps), test/step_guide_upgrade_test.dart(새 검사 12개: 처음 8개 + Codex 지적 반영 4개) | No issues found!(AI 실행) | 00:13 +133: All tests passed!(AI 실행, 처음 8개 때). 고친 줄을 잠깐 빼면 새 검사가 실패함을 확인(처음 7개, Codex 지적 반영 뒤 4곳 더, AI 실행) | 미실행 | 3절 | 사람(아직) |
| P03 | C-26, S6-01, S3-01 | lib/widgets/common.dart(SlowConnectionNote), lib/screens/route_list_screen.dart, lib/screens/step_guide_screen.dart, lib/screens/my_tips_screen.dart, lib/screens/add_tip_screen.dart, lib/validation/tip_rules.dart(rejected), lib/repositories/fake_subway_repository.dart(failNext fieldErrors), lib/l10n/app_strings.dart, test/loading_errors_upgrade_test.dart(새 검사 9개: 처음 6개 + Codex 지적 반영 3개) | No issues found!(AI 실행) | 00:16 +143: All tests passed!(AI 실행, 처음 6개 때). 요청 번호 key·섞인 400 조건을 빼면 보강 검사가 실패함(AI 실행) | 미실행 | 3절 | 사람(아직) |
| P04 | C-15, S5-01, C-19 | lib/widgets/labeled_field.dart(secret), lib/screens/login_screen.dart, lib/l10n/app_strings.dart(version), lib/state/app_controller.dart(demoData), lib/screens/settings_screen.dart, lib/screens/home_shell.dart, test/input_settings_tabs_upgrade_test.dart(새 검사 6개: 처음 5개 + Codex 지적 반영 1개) | No issues found!(AI 실행) | 00:02 +5: All tests passed!(AI 실행, 처음 5개 때). 전체는 P05 | 미실행 | 3절 | 사람(아직) |
| P05 | 회귀 | (코드 변경 없음) | No issues found!(AI 실행) | 00:18 +152: All tests passed!(AI 실행) | 미실행(아래 AI 실행 확인은 사람 대조가 아님) | — | 사람(아직) |
| 추가 요청(2026-10-21) | 연결 끊김 그림 안내·연결되면 자동 다시 읽기 | lib/widgets/offline_message.dart(새 파일: OfflineMessage·AutoRetry·OfflineIllustration), lib/widgets/common.dart(StatusMessage image·note), lib/screens/route_list_screen.dart·step_guide_screen.dart·my_tips_screen.dart(요청 번호·_recovering·AutoRetry, S02 _retrySteps), lib/l10n/app_strings.dart(offlineAutoRetry), test/offline_retry_test.dart(새 검사 11개: 처음 6개 + Codex 지적 반영 5개) | No issues found!(AI 실행) | 00:18 +163: All tests passed!(AI 실행). S01·S02 요청 번호, 복구 중 이어 가기, _busy를 하나씩 빼면 해당 검사가 실패함(AI 실행) | 미실행 | 3절 | 사람(아직) |
| 추가 요청 2(2026-10-21) | 회원가입 화면·로그인 화면 파란 '회원가입' 글자 | lib/validation/signup_rules.dart(새 파일), lib/repositories/subway_repository.dart·http_subway_repository.dart·fake_subway_repository.dart(signup), lib/screens/signup_screen.dart(새 화면), lib/screens/login_screen.dart(링크·가입 뒤 바로 로그인), lib/l10n/app_strings.dart(회원가입 문구), test/signup_test.dart(새 검사 13개: 처음 9개 + Codex 지적 반영 4개), test/signup_contract_test.dart(새 검사 4개) | No issues found!(AI 실행) | 00:21 +180: All tests passed!(AI 실행) | 미실행 | 3절 | 사람(아직) |
| 추가 요청 3(2026-10-22) | 상단 바·하단 메뉴를 인스타그램 느낌으로 | lib/theme/app_theme.dart(상단 바 밝은 surface·본문색 제목·가운데, AppSizes.navBar, 쓰지 않게 된 navigationBarTheme 뺌), lib/widgets/floating_tab_bar.dart(새 파일: 떠 있는 둥근 캡슐 하단 메뉴), lib/screens/home_shell.dart(NavigationBar → FloatingTabBar), lib/theme/app_colors.dart(주석), test/helpers.dart(bottomNav 찾는 위젯 바꿈), test/text_scale_test.dart(탭 누르는 영역을 InkWell로 잼), test/floating_tab_bar_test.dart(새 검사 2개) | No issues found!(AI 실행) | 00:19 +182: All tests passed!(AI 실행) | 미실행 | 받지 않음(모양 변경. 낭독·탭 동작은 검사로 확인) | 사람(아직) |
| 추가 요청 4(2026-10-22) | 하단 메뉴 선택 칸이 미끄러지듯 이동(사용자 녹화) | lib/widgets/floating_tab_bar.dart(StatefulWidget으로 바꿈: 선택 칸 하나를 Stack에 두고 AnimationController로 옮김, 앞쪽 끝 easeOutCubic·뒤쪽 끝 easeInOutCubic 350ms, 끌면 손가락을 따라가고 놓은 자리의 탭 고름, 동작 줄이기면 바로, 사용자 요청으로 누를 때 물결·눌림 색 없앰), test/floating_tab_bar_test.dart(움직임 검사 4개 + 누름 색 없음 검사 1개) | No issues found!(AI 실행) | 00:20 +187: All tests passed!(AI 실행) | 미실행 | 받지 않음(움직임만 바꿈. 검사로 확인) | 사람(아직) |
| 추가 요청 5(2026-10-22) | S02 사진 넘김을 인스타그램 스토리처럼 입체로 | lib/widgets/step_widgets.dart(새 CubePage: 넘기는 동안 사진이 맞닿은 모서리를 축으로 돌고 돌아간 만큼 어두워짐, 동작 줄이기면 평평하게), lib/screens/step_guide_screen.dart(사진 PageView의 각 장을 CubePage로 감쌈), test/story_cube_test.dart(새 검사 3개) | No issues found!(AI 실행) | 00:19 +190: All tests passed!(AI 실행). 처음에는 text_scale 여정 검사 4개가 실패함('전체 단계'를 접는 프레임에 사진 PageView가 새로 만들어져 같은 컨트롤러가 두 곳에 붙음). 하나만 붙어 있을 때만 page를 읽도록 고친 뒤 통과(AI 실행) | 미실행 | 받지 않음(움직임만 바꿈. 검사로 확인) | 사람(아직) |
| 추가 요청 6(2026-10-22) | 빈 단계 사진 채우기(2단계 교통센터·일반열차 4단계 개찰구) | assets/photos/transport_center.jpg·local_gate.jpg(새 사진, 위키미디어 공용 원본을 가로 720px로), assets/photos/CREDITS.md·SOURCE-licenses.txt(출처), pubspec.yaml(assets), lib/models/step_photos.dart(transportCenter·localGate 키와 출처 한 줄, 개찰구는 2007년이라 연도 표시), lib/screens/settings_screen.dart·lib/l10n/app_strings.dart(설정 > 사진 출처에 두 줄·CC BY 2.5 주소·원본 주소 2개), lib/repositories/fake_seed.dart(같은 사진 키), test/step_photos_test.dart(새 검사 2개), test/navigation_test.dart·repository_test.dart·settings_test.dart(사진·출처 확인으로 바꿈), test/text_scale_test.dart(설정을 출처 맨 아래 줄까지 내림). 서버(사용자 허락): SeedData.java(2단계·LOCAL 4단계 photoKey), PublicReadTest.java, docs/api-examples/route-steps.json(생성기로 다시 만듦, 1곳 바뀜). 문서(사용자 요청): 서버 docs/api-spec.yaml(photoKey 설명)·data-model.md(시드 표)·functional-spec.md(사진 키 목록), 앱 docs/api/api-spec.yaml·data-model.md(서버 원본 다시 복사, 같음), docs/samples/express-steps.json(2단계 photoKey), test/server_samples_test.dart | No issues found!(AI 실행) | 00:19 +192: All tests passed!(AI 실행). 처음에는 text_scale 설정 검사 4개가 실패함(라이선스 주소가 2개라 'creativecommons.org'로 하나를 고를 수 없음). 서버 gradlew test 64개 통과(AI 실행) | 미실행 | 받지 않음(사진·출처 추가) | 사람(아직) |
| 추가 요청 7(2026-10-22) | 직통열차 빈 사진도 채우기('더 찾아 직통열차': 4단계 개찰구·5단계 승강장) | assets/photos/express_gate.jpg(위키미디어 공용 원본에서 개찰구·표지판 부분을 잘라 720×540)·express_platform.jpg(720×480), assets/photos/CREDITS.md·SOURCE-licenses.txt, pubspec.yaml, lib/models/step_photos.dart(expressGate·expressPlatform 키, 출처에 2015년·잘라냄 표시), lib/screens/settings_screen.dart·lib/l10n/app_strings.dart(사진 출처 두 줄·CC BY-SA 2.0 주소·원본 주소 2개), lib/repositories/fake_seed.dart, test/step_photos_test.dart(사진 준비 중 칸 위젯 검사 1개 더함: 이제 모든 시드 단계에 사진이 있어 따로 봄), test/repository_test.dart·settings_test.dart·server_samples_test.dart. 서버(사용자 허락): SeedData.java(EXPRESS 4·5단계 photoKey), PublicReadTest.java, docs/api-examples/route-steps.json(생성기로 다시 만듦, 2곳 바뀜), docs/api-spec.yaml·data-model.md·functional-spec.md(사진 키 여덟 개). 앱 docs/api 사본 다시 복사, docs/samples/express-steps.json(4·5단계 photoKey, 서버 예시 본문과 같음 확인) | No issues found!(AI 실행) | 00:19 +193: All tests passed!(AI 실행). 서버 gradlew test 64개 통과(AI 실행) | 미실행 | 받지 않음(사진·출처 추가) | 사람(아직) |

추가 요청 5 확인(AI 실행, 2026-10-22): 에뮬레이터(debug 빌드)에서 직통열차 S02를 열고 screenrecord로 두 번 녹화해(기기 파일은 지움) 장면 24장·20장으로 확인. 1단계 사진을 손가락으로 밀면(adb input swipe 1.2초) 1단계 사진은 오른쪽 모서리, 2단계 칸('사진 준비 중')은 왼쪽 모서리를 축으로 돌아, 맞닿은 모서리가 앞으로 나온 정육면체처럼 넘어간다. 돌아간 면은 어둡다가 다 넘어가면 평평하고 원래 밝기로 돌아온다. '다음'을 눌러도 2→3단계가 같은 모양으로 돈다. 직통열차 진행(3/5)은 에뮬레이터 앱에 남아 있다.

추가 요청 4 확인(AI 실행, 2026-10-22): 사용자 녹화(3.9초)에서 Windows 기본 기능(WinRT MediaComposition)으로 장면 12장을 뽑아 봄. 다른 탭을 누르면 화면과 채운 아이콘은 바로 바뀌고, 연한 회색 칸이 새 탭으로 미끄러지며 가는 동안 늘어났다 줄어든다. 에뮬레이터(debug 빌드)를 screenrecord로 녹화해(기기 파일은 지움) 장면 24장으로 확인: '설정'을 누르면 칸이 늘어나며 오른쪽으로, '경로'를 누르면 왼쪽으로 옮겨 가고, 경로→내 팁으로 끌면 칸이 손가락을 따라가다 놓은 자리의 '내 팁'이 선택된다.

추가 요청 3 확인(AI 실행, 2026-10-22, debug 빌드, 서버 dev 켜 둠): 에뮬레이터에서 S01·S02·S05를 밝게, S01을 어둡게 찍어 봄. 상단 바는 화면 바탕과 같은 색에 굵은 제목이 가운데, 하단 메뉴는 화면 아래 떠 있는 둥근 캡슐(아이콘 + 작은 글자, 선택한 탭은 연한 회색 둥근 칸)으로 보임. 낭독 이름은 예전처럼 'Routes / Tab 1 of 3'.

추가 요청 2 확인(AI 실행, 2026-10-21, debug 빌드, 서버 dev 켜 둠): curl로 서버 POST /api/auth/signup이 명세대로 400(형식)·409(이미 있는 아이디)를 주는지 봄(계정 만들지 않음). 에뮬레이터에서 내 팁 → 로그인 화면에 'Don't have an account? Sign up'(Sign up은 파란 링크색)이 보임. 눌러 가입 화면에서 시험 계정 tester_1739를 만들면 바로 로그인되어 내 팁(빈 목록)과 'Account created. You're logged in.' 알림이 뜨고, 설정에 'Logged in as tester_1739'. 시험 비밀번호는 실행 중에만 만들고 어디에도 적지 않았다. 이 계정은 서버 dev DB에 남아 있다.

추가 요청 에뮬레이터 확인(AI 실행, 2026-10-21, debug 빌드, 서버 dev 켜 둠): adb로 비행기 모드를 켜고 앱을 열면 S01에 그림(와이파이 끊김 + 비행기 표시)·'You're offline'·와이파이 안내·[Try again]·자동 안내 줄이 보임. 앱을 켜 둔 채 비행기 모드를 끄면 누르지 않아도 약 7초 뒤 경로 목록이 나옴(망이 다시 붙는 시간 포함). 권한은 이미 있는 INTERNET만 쓰고 새로 넣지 않았다.

P05 에뮬레이터 확인(AI 실행, 2026-10-21, debug 빌드 API_BASE_URL=http://10.0.2.2:8097, 서버 dev 켜 둠): S01이 서버 경로를 읽음. 일반열차 2단계에서 팁까지 내린 뒤 '다음' → 3단계 맨 위(진행 3/5·사진·제목)가 보임(움직임 250ms 뒤). S05 정보 칸 'Version 1.0.0 · student project'(서버 저장소라 Demo data 없음). S05를 내린 뒤 같은 탭을 다시 누르면 맨 위(APPEARANCE)로 감. 비밀번호 제안 줄·8초 느린 연결 줄·글꼴 130%/200%·TalkBack은 보지 않았다.

## 2. 명세·9장 인계와 다르게 둔 것(이유)

| 항목 | 명세·인계 | 앱 | 이유 |
|---|---|---|---|
| 이전·다음을 본문 끝으로 옮기는 문턱(P02, S2-02) | docs/handoff.md 1절 '글자 2배 이상' 행(9장, 4차 DEC-07 제안) | 본문 16 기준 1.7배 이상(stepNavInline), '전체 단계' 아래 줄은 1.3배(stepsButtonOnOwnLine) | S02 명세 규칙과 0절 결정 5. Android 글꼴 200%는 본문이 약 1.75배라 2.0 문턱으로는 고정 바가 남았다. handoff.md는 9장 기록이라 고치지 않고 여기 적는다 |
| 단계 이동 뒤 맨 위로 올리는 움직임 시간(P02, S2-01) | 명세는 '맨 위로 올린다'만 정함(시간 없음) | 250ms easeOut | DS photoPaging(사진 넘김)과 같은 값을 다시 씀. 새 숫자를 만들지 않았다 |
| 같은 탭 다시 누름 → 맨 위 움직임 시간(P04, C-19) | DS sameTab·CR 하단 메뉴는 '맨 위로 스크롤'만 정함 | 250ms easeOut, 동작 줄이기면 바로 | S02 단계 이동과 같은 값. 탭 화면 본문은 이 경로의 PrimaryScrollController에 붙는 기본값을 써서 화면마다 컨트롤러를 넘기지 않았다 |
| '느린 연결' 줄 모양(P03, C-26) | UH·CR은 문구와 '문구 아래 한 줄'만 정함 | 바로 위 불러오는 중 문구와 같은 글자 모양, 간격 없음 | 새 숫자를 만들지 않으려고 옆 문구 모양을 그대로 씀. 낭독은 liveRegion으로 알림 |
| S03 서버 400 칸 오류(P03, S3-01) | S03 규칙: errors 키로 칸 오류 | 앱 규칙을 다시 돌려 맞는 종류가 없으면 'Check this field again. / 이 칸을 다시 확인하세요.' | 0절 결정 4. 앱 검사가 먼저 막아서 실제 서버 400은 만들기 어렵다. 가짜 저장소 failNext(fieldErrors)로 위젯 검사만 했다 |
| S05 버전 문구(P04, S5-01) | S05 미결 1(10장 뒤 바꾼다), R5 COPY-17 | 'Version 1.0.0 · student project'(가짜 저장소면 ' · Demo data'), '버전 1.0.0 · 학생 실습 프로젝트'(' · 시연용 데이터') | 0절 결정 6 문구를 그대로 씀. 가짜 저장소 판정은 AppController.demoData(FAKE_SCENARIO·검사) |
| 연결 끊김 안내에 그림(추가 요청) | DS statusMessage 'icon: 없음(제목·설명·버튼만)' | 연결 끊김(S01·S02 단계·S06)만 위에 아이콘 그림(둥근 바탕 112, 와이파이 끊김 56, 비행기 표시 22·테두리 3)과 버튼 아래 한 줄('If airplane mode is on, turn it off. We'll load this automatically when you're back online. / 비행기 모드라면 꺼 주세요. 인터넷이 다시 연결되면 자동으로 불러와요.') | 2026-10-21 사용자 요청. DS에 그림 크기 이름이 없어 새 숫자를 썼다. 그림은 아이콘으로 그려 두 테마 색을 따르고 애셋이 없다. 낭독에서는 빼고 제목이 알린다. 5장 문서에 반영함(2026-10-21, D13·4절) |
| 연결되면 자동 다시 읽기(추가 요청) | 명세는 연결 끊김 + [다시 시도]만 정함 | 연결 끊김으로 실패한 뒤 아직 못 읽은 동안(_recovering) 3초마다, 앱으로 돌아올 때(resumed) 바로 화면을 둔 채 다시 읽음(AutoRetry). 다시 붙는 도중 다른 실패(시간 초과·서버)가 나면 그 실패 화면을 보이되 자동 재시도는 이어 감. 처음부터 다른 실패면 자동으로 다시 보내지 않음. 성공·화면 이탈·로그인 사용자 변경 때 멈춤 | 2026-10-21 사용자 요청. 새 패키지를 넣지 않는 규칙이라 connectivity_plus(ACCESS_NETWORK_STATE 권한) 대신 요청 결과로 판단한다. 끊긴 동안 요청은 바로 실패해 부담이 적다. 3초는 새 숫자 |
| 회원가입(추가 요청 2) | 5장 S04 openQuestions 1·앱 handoff.md '회원가입(범위 밖)', 서버 api-spec '앱 화면에는 없다(계정 발급 방식 미정)' | 로그인 화면 버튼 아래 'Don't have an account? / 계정이 없나요?' + 파란 'Sign up / 회원가입'(TextButton, 링크색 AppColors.link) → 가입 화면(아이디·비밀번호·비밀번호 확인, 서버와 같은 규칙) → 가입하면 로그인 화면으로 돌아와 같은 값으로 바로 로그인(들어온 목적대로 S03 또는 들어온 화면) | 2026-10-21 사용자 요청. 서버 계약은 그대로 썼다(POST /api/auth/signup, 409 USERNAME_TAKEN). '계정 발급 방식(강사 확인)' 질문은 D12로 닫았고 5장 문서에 반영함(2026-10-21, S07 명세·4절) |
| 상단 바(추가 요청 3) | DS colors 역할 'signage=상단 바·표지판 칩', 상단 바 남색 바탕·흰 글자·왼쪽 제목 | 화면 바탕과 같은 surface, 본문색 굵은 제목(21/700), 가운데 정렬, 그림자 없음. 상태 표시줄 아이콘은 밝게면 어둡게, 어둡게면 밝게. 남색은 표지판 칩에만 | 2026-10-22 사용자 요청(인스타그램 화면을 예로 줌). 글자 크기·굵기는 예전 상단 바 값을 그대로 썼다. 5장 문서에 반영함(2026-10-22, D14·4절) |
| 하단 메뉴(추가 요청 3) | DS components.bottomNav: 화면 폭 전체 surface 막대, 높이 68, 선택 항목은 primary 16% 알약 | 화면 아래 떠 있는 둥근 캡슐(좌우 18·아래 12 띄움, 최소 높이 68, 안쪽 6, 둥근 정도 999, divider 테두리, 그림자 검정 12%·흐림 18·아래 4). 탭마다 아이콘 + 작은 글자(12, 선택 700·본문색 / 나머지 500·보조색), 선택한 탭은 surfaceContainer 둥근 칸과 채운 아이콘 | 2026-10-22 사용자 요청. 글자는 질문에 대한 사용자 답대로 남겼다(여행객이 뜻을 바로 알도록). 간격·높이·둥근 정도는 DS 값(page·card·fieldGap·navBarHeight·chip)을 다시 썼고, 그림자 세 값은 새 숫자다. 글자를 키우면 캡슐도 높아진다. 낭독은 NavigationBar처럼 '이름 + Tab n of N' 버튼·선택 상태. 5장 문서에 반영함(2026-10-22, D14·4절) |
| 하단 메뉴 선택 칸 움직임(추가 요청 4) | DS bottomNav otherTab은 '그 화면으로 바뀐다'만 정함(움직임 없음), DS 시간은 사진 넘김 250ms | 선택 칸 하나가 새 탭으로 350ms 동안 미끄러진다. 앞쪽 끝은 easeOutCubic, 뒤쪽 끝은 easeInOutCubic이라 가는 동안 늘어났다 줄어든다. 캡슐 위를 좌우로 끌면 칸이 손가락을 따라가고, 놓은 자리의 탭을 고른다(원래 탭이면 그대로). 아이콘·글자는 고른 순간 바뀐다. 동작 줄이기면 바로 옮긴다. 끌기는 낭독에서 빼고 탭 버튼만 읽힌다 | 2026-10-22 사용자 요청(인스타그램 녹화). 350ms와 두 곡선은 녹화처럼 늘어나는 모양이 보이도록 고른 새 값이다. 5장 문서에 반영함(2026-10-22, D15·4절) |
| S02 사진 넘김 모양(추가 요청 5) | DS photoPaging은 사진 넘김 시간 250ms만 정함(평평하게 밀림) | 넘기는 동안 두 사진이 정육면체의 이웃한 면처럼 맞닿은 모서리를 축으로 최대 90° 돈다(원근 0.001). 돌아간 만큼 검정을 덮는다(최대 35%). 손가락으로 밀 때와 이전·다음 버튼 모두 같고, 버튼으로 넘기는 시간·곡선은 그대로(250ms easeOut). 동작 줄이기면 평평하게 넘긴다 | 2026-10-22 사용자 요청('사진 넘어가는거 인스타 스토리 넘어가는거처럼'). 90°·원근 0.001·35%는 새 값이다. 5장 문서에 반영함(2026-10-22, D16·4절) |

## 3. Codex 반박 판정

| 요청문 | 지적 | 판정(수용·기각·보류) | 이유 | 조치 |
|---|---|---|---|---|
| P02 | [중간] 비선형 검사가 예전 글자 10 기준 판정을 잡지 못함(test/step_guide_upgrade_test.dart 모의 배율) | 수용 | 모의 배율이 16 이하를 모두 같은 배율로 키워 글자 10과 16의 판정이 같았다 | 모의 배율에 small(글자 10 이하 배율)을 더하고, 실제 StepProgress의 버튼 줄 위치를 보는 검사 2개 추가(10은 1.35배·본문 1.25배 → 같은 줄, 본문 1.3배·10은 1.2배 → 아래 줄). 예전 판정으로 되돌리면 두 검사 실패(AI 실행) |
| P02 | [중간] 마지막 단계 → 완료 → 다시 보기에서 스크롤·사진 컨트롤러 충돌을 검사하지 않음 | 수용 | 완료에서 돌아올 때 PageController를 새로 만드는 분기에 검사가 없었다 | 본문을 내린 5단계 → 완료 → '5단계 다시 보기' 검사 추가(예외 없음·맨 위·진행 5/5·사진 5단계). 사진 밀기 검사에 진행 표시와 사진 쪽 일치 단언 추가. 컨트롤러를 새로 만드는 줄을 빼면 실패(AI 실행) |
| P02 | [낮음] 낭독 검사에 실제 누르기·중복 노드·지난 팁 버튼 확인이 빠짐 | 수용 | onTap을 넣었지만 낭독기 누르기로 실제 이동하는지 보지 않았다 | semantics tap으로 3단계 이동·목록 접힘, 지금 단계 선택됨, 'All steps' 노드 1개, 지난 팁 펼침 버튼(버튼·펼침 상태 한 노드) 검사 추가. onTap·MergeSemantics를 빼면 실패(AI 실행) |
| P03 | [중간] 같은 자리에서 요청을 바꾸는 경우를 검사하지 않아 요청 번호 key를 빼도 통과(test/loading_errors_upgrade_test.dart) | S02 수용, S06 기각 | S02는 팁을 기다리는 중 단계를 옮기면 같은 자리에서 새 요청이 나간다. S06은 사용자가 바뀌려면 로그아웃 안내(다른 화면 트리)를 거쳐서 같은 자리 재사용이 생기지 않는다. S06 key는 방어용으로 둔다 | '팁을 기다리는 중 단계를 옮기면 새 요청부터 8초를 다시 센다' 검사 추가. key를 빼면 실패(AI 실행) |
| P03 | [중간] 400 상자 조건의 경계(칸·칸 아닌 이름 섞임, 이름 없음) 검사가 없음 | 수용 | 섞인 경우 상자를 숨기도록 조건을 잘못 바꿔도 통과했다 | {'location','stepNo'} → 칸 오류 + 상자, 이름 없음 → 상자만 검사 추가. 조건을 빼면 실패(AI 실행) |
| P04 | [낮음] 실제 저장소의 demoData 판정을 검사하지 않음 | 수용 | 문구 함수에 false를 직접 넣는 검사뿐이었다 | HttpSubwayRepository면 false, FakeSubwayRepository면 true 검사 추가(네트워크 요청 없음) |
| 추가 요청 | [높음] 다시 붙는 도중 실패 종류가 바뀌면(끊김 → 시간 초과·서버) 자동 재시도가 영구히 멈춤(S01·S02·S06) | 수용 | 타이머가 연결 끊김 안내 위젯 안에만 있어, 종류가 바뀌어 안내가 사라지면 타이머도 사라졌다 | 자동 재시도를 AutoRetry로 떼고, 화면마다 _recovering(연결 끊김에서 시작해 아직 못 읽음)일 때 실패 화면을 감싼다. 성공·화면 이탈·로그인 사용자 변경 때 멈춤. 검사 추가, 이어 가기를 빼면 실패(AI 실행) |
| 추가 요청 | [높음] [다시 시도]가 자동 요청과 겹쳐 늦게 온 앞 응답이 화면을 되돌림. S02는 사진 컨트롤러 교체·팁 중복 읽기 | 수용 | S01 _load와 S02 _loadSteps에 요청 번호가 없었다(S06은 있었음) | S01 _request, S02 _stepsRequest로 앞 요청 결과를 버린다. 검사 2개 추가, 요청 번호를 빼면 각각 실패(AI 실행) |
| 추가 요청 | [높음] 서버 주소가 호스트 이름이면 비행기 모드의 DNS 실패가 server로 분류돼 안내·자동 재시도가 안 나올 수 있음 | 보류 | 지금 주소는 IP(10.0.2.2:8097)라 에뮬레이터 비행기 모드에서 ENETUNREACH → offline으로 확인했다. 호스트 이름 주소·실제 기기는 확인하지 못했고, DNS 실패를 끊김으로 단정하면 '확인된 끊김만 offline' 규칙과 어긋난다 | 4절 남은 문제에 적음 |
| 추가 요청 | [중간] 검사가 요청이 걸린 동안의 안전성(겹침·주기·resumed)과 종류 변화를 보지 않음 | 수용(초점·낭독 검사는 기각) | 모든 가짜 응답이 지연 0이었다. 초점은 FocusHeading이 처음 만들 때만 걸고, 끊김 실패가 되풀이되는 동안 같은 위젯이 남아 다시 걸리지 않는 구조다 | 지연 10초 가짜 응답으로 검사 5개 추가(종류 변화 뒤 이어 가기, S01·S02 겹침, 요청 중 주기·resumed에도 1개, 성공 뒤 멈춤). _busy를 빼면 실패(AI 실행) |
| 추가 요청 2 | [중간] 가입 시간 초과를 실패로 단정해 다시 가입하게 함(서버는 가입을 마쳤을 수 있어 다시 보내면 409) | 수용 | 전송 계층도 시간 초과는 처리 여부를 모르는 상태로 정의한다(S03 시간 초과와 같음) | 시간 초과면 노란 상자 'No reply from the server, so we can't tell if your account was created. Try logging in with it. / 응답이 없어 가입됐는지 알 수 없어요. 입력한 아이디로 로그인해 보세요.' + [로그인] → 보낸 값으로 로그인 화면에서 로그인해 봄. 가입을 다시 보내지 않는 검사 추가 |
| 추가 요청 2 | [중간] 가입 중 뒤로·가입 뒤 로그인 실패 같은 경쟁을 검사하지 않음, 팁 목적 성공 알림 미확인 | 수용 | 가짜 응답이 모두 지연 0이었다 | 가입 5초 지연 중 뒤로 → 늦은 결과로 로그인·이동 없음, 가입 뒤 로그인 실패 → 실패 상자·아이디 유지·가입 알림 없음 검사 추가, 팁 목적 검사에 알림 확인 추가 |
| 추가 요청 2 | [낮음] 코드 포인트 검사가 UTF-16 길이 구현도 통과시킴 | 수용 | 이모지 8개는 두 방식 모두 8 이상이었다 | 이모지 7개·4개 거절, 공백 8개 허용, ASCII 72바이트 허용·73바이트 거절 추가 |
| 추가 요청 2 | [낮음] 400 칸 이름의 화면 연결(일반 문구·초점) 검사가 없음 | 수용(접근성 낭독 검사는 보류) | 계약 검사는 fieldErrors 추출만 봤다 | 맞는 값에 서버 400(username)을 주면 'Check this field again.'·아이디 칸 초점·서버 문구 안 보임 검사 추가. 오류 낭독은 LabeledField(errorText)가 기존과 같아 따로 검사하지 않음 |

## 4. 남은 문제·다음 묶음

- 사람이 에뮬레이터로 볼 것(P02~P04 '내가 확인할 것'): 글꼴 130%·200% S02 하단 바, 애니메이션 끄고 팁 올리기, 8초 느린 연결 줄(네트워크 지연), S06 불러오는 중 문구, 비밀번호 보이기 때 키보드 제안 줄, S01·S06·S05 같은 탭 다시 누름.
- 확인하지 못한 것: TalkBack 실제 낭독, 실제 서버 400(앱 검사가 먼저 막음), 실제 전송의 8초 안내 → 15초 시간 초과 연결(각각은 검사함).
- 0절 결정 2 처리(2026-10-21, AI 실행): 5장 원본 9개 파일(S02~S06 명세, ui-handoff.md, screen-flow.csv, design-system.json, ui-review-round5-design-plugin.md)에서 K-01~K-08을 10장·고도화 뒤 실제 앱에 맞췄고, 앱 docs/ 사본을 다시 복사했다(머리 2줄을 빼면 원본과 같음, design-system.json JSON 문법·screen-flow.csv 칸 수 확인). 5장 원본은 git이 아니라서 고치기 전 파일을 세션 임시 폴더에 따로 백업했다.
  - K-01 403 문구: S02 명세, SF 36행, UH PATCH 행을 10장 결정 문구로. R5 COPY-19는 점검 기록이라 행은 두고 끝에 '바뀐 점' 절을 더했다.
  - K-02 시간 초과: S02·S03·S04·S06 명세, UH 71·127행, SF 5·43·56·69행에서 '시간 초과 없음'과 '규칙(앱 반영 필요)'을 지우고 15초 현재 동작으로. 8초 줄은 '고도화 P03에서 넣음, 위젯 검사 통과·화면 대조 전'으로 적었다.
  - K-03·K-05 S03 시간 초과 흐름과 10장 문구: S03 명세 states·navigation·openQuestions 2, UH 78·127행, SF 43행, DS noticeBox(warning·behavior)와 snackBar use.
  - K-04 offline 판정: UH 133행(기기에 망이 없을 때만 offline).
  - K-06: 앱 docs/handoff.md는 9장 기록이라 1~4절은 두고 5절 '10장·고도화 뒤 바뀐 점'을 더했다(K-01·K-05의 handoff.md 부분도 이 절).
  - K-07 로그인 유지: S04 openQuestions 2, UH 62행에 '메모리에만 둠, 기기 저장은 미정(질문 22)'.
  - K-08 S05 버전: openQuestions 1을 '결정되어 미정에서 지움'으로 옮기고 번호를 하나씩 당겼다. R5 COPY-17도 끝 절에 적었다.
- 규칙 표시 바꾸기(2026-10-21, AI 실행, 사용자 요청): 고도화(P02~P04)로 앱에 넣은 규칙의 '규칙(앱 반영 필요)' 표시를 '현재 동작(고도화, 위젯 검사 통과·화면 대조 전)'으로 바꾸고, 옛 동작을 말하던 문장을 지금 앱 동작으로 고쳤다. 고친 곳: S02:16·18(단계 0개·큰 글자), S03:17, S04:16, S05:16, S06:16·18, CR:59·147·163·187, UH:7·76·81·118·132, DS:381·462·510·546, SF:14·23(표시에 쉼표가 있어 4번째 칸을 큰따옴표로 감쌈). 새 표시의 뜻은 범례 줄(000_읽는순서.md:9, S02~S06 :6, UH:9, CR:9)에 한 문장씩 더했다. S02:20(표지판 글자 낭독, 정하지 않은 일)은 그대로 두었다. UH:7은 '글자 2배 이상' 행이 지금은 본문 16 기준 1.7배라고 적고, 앱 docs/handoff.md 5절에 그 줄을 더했다.
  - 앱 docs/ 사본 10개를 다시 복사했다. 머리 2줄을 빼면 원본과 같고, design-system.json은 JSON 문법 통과, screen-flow.csv는 따옴표를 아는 방식으로 읽어 72행 모두 4칸이다. 범례·S02:20·UH:132 말고는 '규칙(앱 반영 필요)'이 남지 않았다.
  - 표시 그대로 사람이 에뮬레이터로 대조하면 '(고도화, 위젯 검사 통과·화면 대조 전)'을 지운다.
- 연결 끊김 안내(추가 요청)에서 남은 것:
  - 서버 주소가 호스트 이름이면 비행기 모드의 DNS 실패가 server로 분류될 수 있다(Codex 보류). 실제 기기에서 IP 주소·호스트 이름 주소를 각각 확인해야 한다. 이벤트로 망 상태를 받으려면 connectivity_plus(ACCESS_NETWORK_STATE 권한)가 필요하고 새 패키지 승인을 받아야 한다.
  - S02 팁 영역만 실패한 경우(팁 영역 빨간 상자)는 자동으로 다시 읽지 않는다. [다시 시도]를 눌러야 한다.
  - 5장 문서 반영은 아래 '추가 요청 문서 반영'에서 했다.
  - 사람이 볼 것: 비행기 모드 켠 채 앱 열기 → 그림 안내, 끄면 누르지 않아도 목록이 나오는지(밝게·어둡게).
- 빈 사진 채우기(추가 요청 6·7)에서 남은 것:
  - 추가 요청 6에서는 직통열차 개찰구·승강장 사진을 찾지 못했다. 승강장으로 보인 2023년 사진(ICN 03.jpg)은 확대해 보니 공항 안 셔틀트레인이라 뺐다. 사용자가 '더 찾아 직통열차'라고 해서 추가 요청 7에서 다시 찾았다(Openverse·Unsplash·Flickr·정책브리핑·한국어 위키백과도 봄).
    - 위키미디어 공용 'Korail ar incheon int'l airport sta 02.jpg'(Asacyan, 2015, CC BY-SA 4.0): 사진 설명이 '인천국제공항역 KTX·직통열차용 개찰구'이고 주황색 개찰구와 '일반열차 ← · 직통열차 →' 표지판이 보여 4단계에 넣었다.
    - 'Wongwt 首爾機場快鐵 (16921458087).jpg'(Wei-Te Wong, 2015, CC BY-SA 2.0): 확대하니 문에 '직통열차 승차위치 3호차', 역명판 '인천국제공항 · 서울역 →'가 보여 5단계에 넣었다.
    - 뺀 것: 한국어 위키백과 '직통열차전용_승강장.JPG'(2011, GFDL만이라 앱에 GFDL 전문이 필요), Flickr '인천공항 직통열차 승강장'(모든 권리 보유).
  - 이제 두 경로 모두 다섯 단계에 사진이 있다. 다만 2007년·2015년 사진은 역 이름(2018년 '인천공항1터미널'로 바뀜)·KTX 표지 등이 지금과 다를 수 있어 현장 사진으로 바꾸는 것이 좋다.
  - 추가 요청 7 반영 확인(AI 실행, 사용자 허락): 앱 재시작으로 dev 서버가 이미 꺼져 있어 data/icn-subway.mv.db만 다시 지우고 dev 프로필로 켰다. 서버 응답에서 EXPRESS 4·5단계 expressGate·expressPlatform을 포함해 두 경로 모든 단계의 photoKey를 확인했고, 새 debug 빌드를 설치해 에뮬레이터 직통열차 4·5단계에 두 사진과 출처 줄이 보였다.
  - 일반열차 개찰구 사진은 2007년 촬영이라 지금 기계·표지판과 다를 수 있다(출처 표시에 연도를 적음). 현장 사진을 찍으면 바꾼다.
  - 서버는 경로 표가 비어 있을 때만 시드를 넣는다. 그래서 2026-10-22 사용자 허락을 받아 AI가 dev 서버를 끄고 data/icn-subway.mv.db만 지운 뒤(.jwt-secret은 둠) dev 프로필로 다시 켰다. 시험 계정 tester_1739·portfolio_1183과 그동안 올린 팁은 지워지고 시드가 다시 들어갔다. 서버 응답에서 EXPRESS·LOCAL 2단계 transportCenter, LOCAL 4단계 localGate, (그때는) EXPRESS 4·5단계 null을 확인했고, 에뮬레이터(debug 빌드) 일반열차 2·4단계에 두 사진과 출처 줄이 보였다(AI 실행).
  - 문서 반영(2026-10-22, AI 실행, 사용자 요청): 서버 docs/api-spec.yaml의 photoKey 설명과 functional-spec.md의 사진 키 목록을 여섯 개로, data-model.md 시드 표의 EXPRESS·LOCAL 2단계를 transportCenter, LOCAL 4단계를 localGate로 고쳤다. 앱 docs/api/api-spec.yaml·data-model.md는 서버 원본을 다시 복사했다(같은 파일). 앱 docs/samples/express-steps.json(10장 표본)은 2단계 photoKey만 고쳤고, 서버 생성기가 새 코드로 만든 route-steps.json 응답 본문과 같은지 비교해 같음을 확인했다. 서버 gradlew test 64개, 앱 00:19 +192 통과(AI 실행).
- 추가 요청 문서 반영(2026-10-21, AI 실행, 사용자 요청): 5장 원본에 회원가입(S07)과 연결 끊김 그림·자동 다시 읽기를 적고 앱 docs/ 사본을 다시 복사했다. 고치기 전 원본은 세션 임시 폴더에 다시 백업했다.
  - 새 파일 S07-screen-spec.md(회원가입, S04 명세와 같은 10개 항목). 앱 docs/에도 복사 머리줄을 넣어 새 사본을 만들었다.
  - 회원가입: S04(들어오는 곳·⑥ 파란 글자·회원가입 글자 동작·이동·openQuestions 1을 '결정됨'으로), S03 openQuestions 3을 '결정됨'으로, ui-handoff(일곱 화면, '범위 밖'에서 회원가입 화면 뺌, '아직 결정할 것'에서 계정 질문 뺌, 상태표 S07 줄, API 표 회원가입 행), ui-validation-decisions(D12·D13 추가, 계정 질문 뺌), ui-requirements.csv R09, screen-flow.csv S04→S07과 S07 흐름 7행, DS screens·screenRules.signup·passwordToggle, CR 버튼·입력칸·눈 아이콘·하단 메뉴 용도.
  - 연결 끊김: S02·S06 states, ui-handoff(확정한 것·상태표·API 표), DS onlineOnly·statusMessage(icon·offline·behavior), CR 가운데 안내(모양·변형·자동 다시 읽기), screen-flow.csv(S01 안내·자동 다시 읽기 1행·S02·S06 안내).
  - 범례 줄 8곳의 새 표시 뜻을 '앱 고도화(P02~P04)와 그 뒤 추가 요청(연결 끊김 그림·자동 다시 읽기, S07 회원가입)'으로 넓혔다. 흐름 수 71 → 79(000_읽는순서·ui-handoff).
  - 확인: 앱 사본 15개가 머리 2줄을 빼면 원본과 같음, design-system.json JSON 문법 통과, screen-flow.csv 79행 모두 4칸, ui-requirements.csv 9행 모두 5칸(따옴표를 아는 방식으로 읽음).
  - 서버 사본(2026-10-22, AI 실행, 사용자 허락): 서버(C:\dev\projects\icn-subway-server\docs)의 사본 6개(S02·S03 명세, screen-flow.csv, ui-handoff.md, ui-requirements.csv, ui-validation-decisions.md)를 원본으로 다시 복사했다. md 사본 머리줄의 원본 경로가 역슬래시 없이 깨져 있어(C:devchapter05-aidocs) 'C:\dev\chapter05-ai\docs · 복사 2026-10-22'로 바로잡았다. 머리 2줄을 빼면 원본과 같다. 서버 git에서는 이 6개가 staged 위에 고친 내용이 더해진 상태(MM)라, 커밋 전에 다시 git add 해야 새 내용이 들어간다.
- 추가 요청 3~5 문서 반영(2026-10-22, AI 실행, 사용자 요청): 5장 원본에 밝은 상단 바·떠 있는 하단 메뉴(추가 요청 3), 선택 칸 움직임·끌기·누름 색 없음(추가 요청 4), 사진 입체 넘김(추가 요청 5)을 적고 앱·서버 사본을 다시 복사했다. 고치기 전 원본과 앱·서버 사본은 세션 임시 폴더에 백업했다.
  - 결정: ui-validation-decisions.md에 D14(상단 바·하단 메뉴 모양)·D15(선택 칸 움직임)·D16(사진 넘김)을 더했다. 000_읽는순서·ui-handoff의 결정 범위를 D1~D16으로 고쳤다(D12·D13을 더할 때 D1~D11로 남아 있었음).
  - design-system.json: components.bottomNav(FloatingTabBar, status·shape·selected·press·drag·accessibility), page.appBar(surface·가운데·그림자 없음), stepPhoto(CubePage), motion.photoPaging(입체 넘김)과 새 키 motion.tabIndicator, flutterAdaptations 역할·동작 줄이기 규칙, sourceFiles, tokenEvidence 4개(signage·appBarTitle·navLabel·navBarHeight), revision.changes 한 줄.
  - component-rules.md: 단계 사진(넘김 모양, 하지 말 것에 넘기는 동안 그림자 예외), 하단 메뉴(모양·다른 탭·끌기·누름 표시·접근성·하지 말 것), 공통 규칙(상단 바 줄 새로, 동작 줄이기·시간).
  - 화면 명세 S02 action(사진 넘김 모양)·S05 action(선택 칸·끌기), ui-handoff 확정한 것(하단 메뉴·상단 바·S02 사진 넘김·색), screen-flow.csv 3행 추가(선택 칸 움직임, 끌기, 사진 넘김)로 흐름 79 → 82(000_읽는순서·ui-handoff).
  - 범례 줄 9곳(000_읽는순서, S02~S07, UH, CR)의 새 표시 뜻에 '밝은 상단 바·떠 있는 하단 메뉴와 선택 칸 움직임, 사진 입체 넘김'을 더했다.
  - 사본: 앱 docs/ 12개(md 10개는 머리줄 '복사 2026-10-22', screen-flow.csv·design-system.json)와 서버 docs/ 5개(S02·S03 명세, ui-handoff.md, ui-validation-decisions.md, screen-flow.csv). 덮어쓰기 전에 사본이 모두 옛 원본과 같았음(따로 고친 사본 없음)을 확인했다. ui-requirements.csv는 바꾸지 않아 다시 복사하지 않았다.
  - 확인: 다시 복사한 사본 17개가 머리 2줄을 빼면 원본과 같고, 나머지 앱 사본 4개와 서버 ui-requirements.csv도 원본과 같다. design-system.json JSON 문법 통과, screen-flow.csv 82행 모두 4칸·BOM·LF 유지(따옴표를 아는 방식으로 읽음).
  - 서버 git에서는 다시 복사한 5개를 커밋 전에 git add 해야 새 내용이 들어간다.
- 권장·선택 묶음과 애플식 3가지는 마감(10-22) 뒤.
