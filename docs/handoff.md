# 10장으로 넘길 화면과 API 연결 기록 (docs/handoff.md)

문서 정보: 2026-10-20 · 작성 Claude Code(9장 구현 세션) · 내 5장 디자인 사용(ICN Subway Steps v03) · 확인: (본인 이름)

비밀번호와 토큰은 적지 않는다. 직접 확인하지 않은 칸은 '미확인'으로 둔다. 10장·고도화 뒤 바뀐 점은 5절에 따로 적는다(1~4절은 9장 기록 그대로).

## 1. 화면 확인 결과

- 앱 프로젝트: C:\dev\projects\icn_subway_app · Flutter 3.47.7 (Dart 3.13.5)
- 실행 방법: 위젯 검사(flutter test), Android 에뮬레이터(API 37.2 'Medium_Phone' — 요청한 Medium_Phone_API_37.0은 시스템 이미지가 설치되어 있지 않아 실행 불가). Chrome·실기기는 미확인.
- 읽은 5장 자료: 내 자료(docs/ui-handoff.md, design-system.json, S02·S03 명세, screen-flow.csv, ui-requirements.csv, ui-validation-decisions.md, ui-verify-round4-v03.md, screens/ICN-subway-steps-v03.src.html)
- 테마: lib/theme/app_colors.dart(colors·colorsDark 20개 키), lib/theme/app_theme.dart(ThemeData 두 벌, 글자·버튼·입력·하단 메뉴·알림)
- 공통 위젯: lib/widgets/common.dart(FocusHeading·Pill·NoticeBox·StatusMessage·ScrollColumn), step_widgets.dart(진행 표시·표지판 칩·4:3 사진·안내 줄), tip_card.dart, labeled_field.dart, mixed_text.dart
- 화면: lib/screens/(route_list, step_guide, add_tip, login, settings, my_tips, home_shell)

### 시안과 다르게 둔 것(이유)

| 항목 | 시안 v03 | 앱 | 이유 |
| --- | --- | --- | --- |
| 본문 글자 | 15px | 16 | flutterAdaptations |
| 글꼴 | Noto Sans KR·Barlow Semi Condensed | 플랫폼 기본 | 기기에 있다고 가정하지 않음(DS 규칙). 글꼴 넣기는 미정 |
| 사진 없음 자리 | 작은 줄 상자 | 4:3 칸 안 아이콘+'사진 준비 중', 설명 줄은 칸 아래 | 단계마다 칩 위치가 흔들리지 않게(4차 VIS-06), 글자 2배에서 칸 넘침 방지 |
| 완료 안내 | 두 문장 | 승차권 보관 한 문장 | 사용자 결정 D4, 4차 DEC-09 |
| '5단계 다시 보기' | 숫자 5 고정 | 단계 수를 받음 | 4차 DEC-09 |
| ko 소개 문구 | '…열차에 탈 때까지' | '…서울역행 열차에 탈 때까지' | 4차 DEC-09 |
| 권한 없음 문구 | '올린 사람만 바꿀 수 있어요' | '지금은 바꿀 수 없어요. 다시 로그인한 뒤 시도하세요' + [다시 로그인], 그 팁 버튼 막음 | 4차 DEC-10 |
| 팁 알림 위치 | 팁 영역 맨 위 | 그 팁 카드 안 | 어느 팁의 알림인지 분명하게, 단계 이동 시 지움(DEC-02) |
| 테마 선택 표시 | 회색 링 | primary 테두리 + 체크(언어 목록과 같음) | 4차 VIS-09 |
| 역할 라벨·칩 영어 | 12px 회색 / 19px 0.9 | 14 본문색 / 21 불투명 | 4차 VIS-02·DEC-05 |
| 상태 바꾼 팁 | 지난 팁이 접혀 있으면 사라짐 | '오래됨'으로 바꾸면 지난 팁을 펼침 | 배지만 바뀌고 카드가 보이게(S02 명세 states) |
| 로그인 버튼 처리 중 | 즉시 | 버튼 막고 작은 진행 표시 | 가짜 저장소도 650ms 지연 |
| 하단 알림 | 화면에 남음 | 화면을 옮기면 닫음 | 4차 REG-05 |
| 글자 2배 이상 | 하단 고정 | 이전·다음을 본문 끝으로 | 4차 DEC-07 제안 |
| 라이선스 링크 | 없음(v03) | 주소를 선택·복사 가능한 글자로 | 4차 REG-07. url_launcher는 추가하지 않음 |
| 예시 팁 내용 | 화면 언어로 번역 | 영어 한 가지 | 사용자 글은 쓴 언어 하나(서버 필드 title이 문자열 하나) |

### 추가한 문구(시안 T 사전에 없음, lib/l10n/app_strings.dart의 [추가])
loadError(원인 모를 읽기 실패), loadingSteps, elevatorAt(서버가 엘리베이터 위치를 줄 때), postError(올리기 실패·값 유지), postErrorClosed(화면을 떠난 뒤 실패), sessionEnded(로그인 끝남·값 유지), loginError(연결 등), loginLeadGeneral, loginAgain, restartFor·stepsCount(낭독 이름), version 문구.

### 이번에 만들지 않은 것
지도·시간표·결제·푸시·소셜 로그인·회원가입(범위 밖), S03 사진 첨부(미정이라 숨김), 중국어·일본어.

## 2. 서버 자료 위치

| 자료 | 원본 | 사본(이 앱) | 복사한 날짜 |
| --- | --- | --- | --- |
| API 계약 | C:\dev\projects\icn-subway-server\docs\api-spec.yaml (서버 세션 작성) | 아직 복사 안 함(10장 시작 때 복사) | — |
| 데이터 모델·인증 | 같은 폴더 data-model.md, auth-design.md | 아직 복사 안 함 | — |

- **결정(2026-10-21, 사용자):** 서버 계약(camelCase, `/api/me/tips`)을 그대로 두고 앱 모델을 서버에 맞춘다. 서버 세션이 사용자 말을 전달해 앱 모델을 바꿨다.
- 앱 모델(lib/models)의 fromJson·toJson은 이제 서버 스키마와 같은 이름이다. 가짜 저장소의 처음 자료(fake_seed.dart)도 서버 응답 모양(봉투·camelCase, 시드 팁 7·8번)으로 두어 같은 fromJson을 지난다.
- 서버가 주지 않아 앱이 정하는 것: 경로별 상수 routeDisplays(lib/models/route_info.dart: 출발 터미널, S01 표지판 병기 줄), 준비 중 T2 카드 설명과 안내(시안 문구 t2msg), 사진 파일과 출처(photoKey → lib/models/step_photos.dart).
- 앱만의 규칙: 예시 팁(example)은 올린 사람이어도 상태 바꾸기 버튼을 숨기고, 내 팁(S06)에서 뺀다(서버는 올린 사람이면 허용·포함). '내가 올림'은 서버가 토큰으로 계산한 mine을 쓰고, 로그인·로그아웃으로 세션이 바뀌면 S02가 팁을 다시 읽어 mine을 맞춘다.
- 글자 수: 앱도 서버처럼 제목·위치·메모 모두 앞뒤 공백을 뺀 뒤 코드 포인트로 센다(메모를 입력 그대로 세던 시안 방식에서 바꿈).

## 3. 10장에서 바꿀 곳

### 저장소 메서드와 서버 API

| 메서드(lib/repositories/subway_repository.dart) | 요청 | 보내는 값 | 받는 값(읽는 함수) | 로그인 | 실패 처리(RepositoryErrorCode) |
| --- | --- | --- | --- | --- | --- |
| fetchRoutes() | GET /api/routes | — | {routes:[Route]} (RouteInfo.listFromJson) | 아니요 | 연결 실패 → offline(S01 '인터넷에 연결되지 않았습니다'), 그 밖 → '불러오지 못했어요' |
| fetchSteps(code) | GET /api/routes/{route}/steps | — | {route, steps:[Step]} (GuideStep.listFromJson). T2는 빈 steps | 아니요 | S02 전체 안내 + 다시 시도 |
| fetchTips(route, stepNo, session?) | GET /api/tips?route=&step= | 로그인했으면 Bearer 토큰 | {tips:[Tip]} 새 팁 먼저 (Tip.listFromJson) | 아니요(토큰 있으면 mine 계산) | 팁 영역만 '불러오지 못했어요' |
| fetchMyTips(session) | GET /api/me/tips | Bearer 토큰 | {tips:[Tip]} | 예 | S06 안내 + 다시 시도 |
| createTip(draft, session) | POST /api/tips | {route, stepNo, title, location, note}(TipDraft.toJson, 그 밖 항목은 400) | 201 Tip | 예 | 400 VALIDATION_FAILED(errors 키로 칸 오류), 401 → '로그인이 끝났어요'(값 유지), 그 밖 → '올리지 못했어요'(값 유지) |
| updateTipStatus(id, status, session) | PATCH /api/tips/{id}/status | {status} | Tip | 예(올린 사람) | 403 FORBIDDEN·401 → '지금은 바꿀 수 없어요' + 다시 로그인, 그 밖 → '상태를 바꾸지 못했어요' + 다시 시도 |
| login(username, password) | POST /api/auth/login | {username, password} | {accessToken, tokenType, expiresIn, user{id, username}} (UserSession.fromLoginJson) | — | 401 LOGIN_FAILED → invalidCredentials(아이디 유지·비밀번호 비움), 그 밖 → loginError |

Tip: id, route(EXPRESS/LOCAL), stepNo, title, location, note|null, status(VERIFIED/OUTDATED), verifiedAt·createdAt(UTC ISO 시각 → 배지는 서울 날짜 seoulDate), ownerId, mine, example.

### 연결할 때 주의
1. 무효·만료 토큰이 붙으면 공개 GET도 401이다. 앱은 401을 받으면 요청 당시 세션이 지금 세션일 때만 로그아웃(AppController.sessionExpired)하고, S02는 익명으로 다시 읽고 S06은 로그인 안내로 바뀐다(이미 구현·검사함).
2. 본문은 utf8.decode(bodyBytes)로 읽는다(HttpSubwayRepository가 이미 함). 오류 message는 한국어뿐이므로 RepositoryException.fromErrorResponse가 errors의 키를 fieldErrors(title·location·note·route·stepNo·status)로 남기고, 화면 문구는 앱이 고른다.
3. 서버는 127.0.0.1에만 열려 있어 실기기에서는 닿지 않는다(에뮬레이터는 10.0.2.2:8097).
4. 표본 계정: student01(101)·student02(102). 비밀번호는 서버 docs/requirements.md의 공개 표본 값(이 문서에 적지 않음).

### 바꿀 파일 / 그대로 둘 파일
- 바꿀 것: ApiTransport 구현 하나(http 패키지 승인 후, 연결 실패는 offline으로) → main.dart에서 HttpSubwayRepository(transport: …)로 교체, android/app/src/main/AndroidManifest.xml(INTERNET 권한, http:// 개발 주소면 cleartext 허용). 경로·본문·헤더·응답 읽기·오류 매핑은 http_subway_repository.dart에 이미 있고 test/api_contract_test.dart가 명세 예시로 검사한다.
- 로그인 결과: UserSession을 로그인 응답으로 채운다. 지금은 앱 메모리에만 두고 기기에 저장하지 않는다(앱을 끄면 로그아웃). 기기에 남길지는 10장에서 정한다.
- 그대로 둘 것: lib/models(서버 계약과 같음), lib/theme, lib/widgets, lib/screens, lib/l10n, lib/validation.
- 401·403·통신 실패 때 입력 유지: S03은 실패해도 값을 지우지 않고(401이면 다시 로그인 후 같은 화면으로 돌아옴), 위젯 검사 add_tip_test.dart에 실패 경우가 있다. 실제 서버 응답으로 다시 확인한다.

### 아직 실행하지 않은 플랫폼과 이후 검사
- Chrome(웹), 실기기, iOS: 미확인.
- TalkBack 실제 낭독(제목 초점 이동, 단계 제목 live region, 혼합 언어 구절의 목소리 전환): 미확인.
- 한글 낱말 단위 줄바꿈(4차 VIS-05): Flutter는 keep-all을 지원하지 않아 음절 단위로 끊길 수 있다. 미확인.

## 4. Codex 반박 리뷰 판정 (C:\dev\CLAUDE.md 규칙)

| 회차 | 지적 | 판정 | 이유 | 조치 |
| --- | --- | --- | --- | --- |
| 1 | [높음] 로그인 중 취소해도 늦게 온 응답이 세션을 덮어씀 | 수용 | login_screen.dart가 응답 뒤 mounted 확인 전에 signIn을 불렀다. 검사로 재현됨(닫히는 애니메이션 동안 mounted가 true인 경우까지) | PopScope로 닫힘(_left) 기록, '!mounted \|\| _left'면 결과 버림. 같은 원리로 S03에 _here 추가(닫히는 중 응답이 S02를 닫던 문제). 회귀 검사 2개 |
| 1 | [중간] 권한 없음 뒤 단계를 왕복하면 재로그인 안내 없이 버튼만 막힘 | 수용 | _goTo가 안내만 지우고 막힘은 남김 | 막힌 팁은 안내를 다시 보이게 함. 검사 추가 |
| 1 | [중간] 재로그인 화면을 취소해도 막힘이 풀림 | 수용 | 로그인 결과를 보지 않고 세션 존재만 확인 | LoginScreen이 true를 돌려줄 때만 해제(S03도 같게). 검사 추가 |
| 2 | [중간] S06에서 탭을 오가면 막힘이 풀림 | 수용 | 막힘이 화면 State에 있어 탭 전환 때 사라짐 | 막힘을 AppController(세션 단위)로 옮기고 로그인·로그아웃 때 비움. 검사 추가 |
| 2 | [중간] 재로그인 뒤 도착한 앞 세션의 401이 새 세션을 다시 막음 | 수용 | 응답이 요청 당시 세션인지 보지 않음 | 세션 세대 번호를 요청 때 기록하고 달라졌으면 무시. 검사 추가(고치기 전 실패 확인) |
| 3 | (서버 계약 camelCase 맞춤) 지적 없음·승인. 제안: 서울 날짜 경계 검사 보강 | 수용 | 자정 직전·정각, 월말·연말, +09:00 오프셋 검사가 없었다 | repository_test.dart에 경계 검사 추가 |
| 4 | [중간] 앞 세션의 상태 변경 성공 응답이 새 세션 목록의 mine을 덮음 | 수용 | 성공 경로가 세션 세대를 보지 않음(mine을 쓰게 되며 생긴 문제) | 성공 응답도 세대가 다르면 버림. 지연을 바꿔 순서를 재현하는 검사 추가(고치기 전 실패 확인) |
| 4 | [중간] 만료 토큰으로 공개 팁 조회가 401을 계속 받고 복구되지 않음 | 수용 | S02가 401을 일반 실패로만 처리, 다시 시도도 같은 토큰 | AppController.sessionExpired(요청 당시 세션일 때만 로그아웃) → S02는 익명으로 다시 읽음, S06은 로그인 안내. 'Logged out' 알림. 검사 추가 |
| 4 | [중간] 날짜 형식·모르는 상태값 응답이 RepositoryException이 되지 않음 | 수용 | _read가 TypeError만 바꿈 | 파싱 중 모든 예외를 server로. 409·415 매핑 검사도 추가 |
| 5 | [중간] 계정을 바꾼 뒤 늦게 끝난 S03 등록이 새 계정 목록에 mine=true로 들어감 | 수용 | 등록 성공이 세션 세대를 보지 않고 목록에 바로 넣음 | 올린 세션의 세대를 함께 알리고, 지금 세션과 다르면 S02가 목록을 다시 읽음. 검사 추가(고치기 전 실패 확인) |
| 5 | [중간] 형식이 틀린 오류 본문(code가 숫자 등)에서 TypeError가 나 S03·S04가 처리 중으로 멈춤 | 수용 | fromErrorResponse가 code를 String으로 강제 변환 | 타입을 확인해 읽고 상태 코드로 분류. 검사 추가 |
| 5 | [중간] S03 등록이 401이어도 만료 세션을 유지 | 수용 | sessionExpired를 S03에 적용하지 않음 | S03 401 → 요청 당시 세션이면 로그아웃(입력값 유지). 같은 원리로 상태 바꾸기 401도 로그아웃(403만 막힘·다시 로그인 안내). 검사 추가 |

기각·보류: 없음. 1·2회차는 화면 구현, 3회차는 camelCase 맞춤, 4·5회차는 명세 맞춤 2단계(HTTP 경로·파싱·오류, 서버 mine)의 리뷰다. 5회차 수정 뒤 추가 리뷰는 받지 않았다(같은 변경 최대 2회, 이후는 사용자 판단).

## 5. 10장·고도화 뒤 바뀐 점 (2026-10-21, 5장 문서 동기화 K-01·K-05·K-06)

위 1~4절은 9장 기록이라 그대로 두고 그 뒤 바뀐 점만 적는다. 자세한 기록은 reports/app-integration.md(10장)와 reports/upgrade-log.md(고도화)에 있다.

- 권한 없음 문구(1절 '권한 없음 문구' 행, K-01): 10장 결정으로 'Only the person who posted this tip can change it. If you logged in with another account, log in again. / 이 팁은 올린 사람만 바꿀 수 있어요. 다른 계정으로 로그인했다면 다시 로그인하세요.'로 바꿨다. [다시 로그인]과 그 팁 버튼 막힘은 그대로다.
- '글자 2배 이상' 행(1절): 고도화 P02에서 본문 16 기준 1.7배로 바꿨다(이전·다음을 본문 끝으로, '전체 단계'는 1.3배부터 아래 줄). 근거는 reports/upgrade-log.md 0절 결정 5와 2절.
- 추가한 문구(1절, K-05): 10장에서 postUnknown(시간 초과로 결과를 모름, 노란 상자), checkTips('팁 목록 확인'), postFound(같은 팁이 이미 있음, 하단 알림)를, 고도화에서 noSteps·myTipsLoading·slowConnection·errCheckField를 더했다. version 문구는 '학생 실습 프로젝트'로 바뀌었다.
- 3절 표의 실패 처리(K-06):
  - createTip: 400은 칸 이름(title·location·note)만 오면 그 칸 아래 오류, 칸이 아닌 이름(route·stepNo 등)이 섞이거나 이름이 없으면 '올리지 못했어요' 상자(고도화 P03. 그 전 10장은 늘 상자). 15초 시간 초과는 결과 모름 상자 + [팁 목록 확인](10장).
  - updateTipStatus: 403은 그 카드 권한 없음 알림 + 다시 로그인·버튼 막힘, 401은 로그아웃(하단 알림 'Logged out'), 그 밖(시간 초과 포함)은 '상태를 바꾸지 못했어요' + 다시 시도.
  - 읽기(fetchRoutes 등): offline 안내는 기기에 망이 없다고 확인될 때만 쓰고, 서버 꺼짐 같은 그 밖의 연결 실패와 시간 초과는 '불러오지 못했어요'다.
- 로그인 유지(3절 '로그인 결과'): 10장에서도 메모리에만 둔다. 기기 저장은 아직 정하지 않았다(docs/upgrade-gap.md 질문 22).
