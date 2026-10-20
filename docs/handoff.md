# 10장으로 넘길 화면과 API 연결 기록 (docs/handoff.md)

문서 정보: 2026-10-20 · 작성 Claude Code(9장 구현 세션) · 내 5장 디자인 사용(ICN Subway Steps v03) · 확인: (본인 이름)

비밀번호와 토큰은 적지 않는다. 직접 확인하지 않은 칸은 '미확인'으로 둔다.

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
loadError(원인 모를 읽기 실패), loadingSteps, postError(올리기 실패·값 유지), postErrorClosed(화면을 떠난 뒤 실패), sessionEnded(로그인 끝남·값 유지), loginError(연결 등), loginLeadGeneral, loginAgain, restartFor·stepsCount(낭독 이름), version 문구.

### 이번에 만들지 않은 것
지도·시간표·결제·푸시·소셜 로그인·회원가입(범위 밖), S03 사진 첨부(미정이라 숨김), 중국어·일본어.

## 2. 서버 자료 위치

| 자료 | 원본 | 사본(이 앱) | 복사한 날짜 |
| --- | --- | --- | --- |
| API 계약 | C:\dev\projects\icn-subway-server\docs\api-spec.yaml (서버 세션 작성) | 아직 복사 안 함(10장 시작 때 복사) | — |
| 데이터 모델·인증 | 같은 폴더 data-model.md, auth-design.md | 아직 복사 안 함 | — |

- 앱의 저장소 약속은 지시대로 docs/ui-handoff.md의 '화면별 API 요구 목록' 후보(snake_case)로 만들었다.
- 서버 세션이 남긴 메모(2026-10-20, 서버는 camelCase로 만듦)에 따르면 아래가 다르다. **어느 쪽에 맞출지는 사용자 결정**이며, 9장에서는 앱 모델을 바꾸지 않았다. 10장 시작 때 api-spec.yaml로 다시 대조한다.

| 대상 | 앱(fromJson이 읽는 키) | 서버 메모의 응답 | 맞출 때 할 일(앱 쪽으로 맞춘다면) |
| --- | --- | --- | --- |
| 경로 | code, origin, name{en,ko}, summary{en,ko}, sign_ko, sign_en, step_count, available | code, name, summary, available, stepCount (origin·sign 없음) | origin·표지판 병기를 서버에 넣거나 앱이 code로 정함 |
| 단계 | step_no, role, icon, sign_ko, sign_en, title, actions, photo_url, photo_credit, elevator_status | stepNo, role, icon, photoKey, sign{ko,en}, title, instructions{en[],ko[]}, elevator({en,ko} 또는 null) | photoKey → 앱 사진 경로·출처 표 필요(서버는 출처를 주지 않음) |
| 팁 | step_no, owner_id, verified_at(YYYY-MM-DD), is_example | stepNo, ownerId, verifiedAt(UTC ISO 시각), createdAt, mine, example | verifiedAt은 Asia/Seoul 날짜로 바꿔 배지에 표시, '내가 올림'은 mine 사용 가능 |
| 팁 등록 본문 | route, step_no, title, location, note | route, stepNo, title, location, note | 이름만 다름 |
| 내 팁 | GET /api/tips/mine | GET /api/me/tips | 경로만 다름 |
| 로그인 응답 | user_id, username, 토큰 | {accessToken, tokenType, expiresIn, user{id, username}} | UserSession을 이 모양에서 채움. 401이면 토큰을 버리고 다시 로그인 |
| 오류 | 코드 종류만 사용 | {code, message, errors{항목: 한국어 문구}} | 영어 화면은 errors의 키(title·location·note)만 보고 앱 문구를 씀 |

같은 것: role HERE/FIND, icon PLANE/ESCALATOR/TRAIN, status VERIFIED/OUTDATED 값, 글자 수(앞뒤 공백 제거 후 코드 포인트). 서버는 메모(note)도 공백 제거 뒤 검사한다 — 앱은 시안대로 메모를 입력 그대로 센다(150자 경계에서 공백이 붙으면 앱만 거절할 수 있음).

## 3. 10장에서 바꿀 곳

### 저장소 메서드와 API 후보

| 메서드(lib/repositories/subway_repository.dart) | 요청 후보 | 보내는 값 | 받는 값 | 로그인 | 실패 처리(RepositoryErrorCode) |
| --- | --- | --- | --- | --- | --- |
| fetchRoutes() | GET /api/routes | — | [{code, origin, name{en,ko}, summary{en,ko}, sign_ko, sign_en, step_count, available}] | 아니요 | offline → S01 '인터넷에 연결되지 않았습니다', 그 밖 → '불러오지 못했어요' |
| fetchSteps(code) | GET /api/routes/{code}/steps | — | [{step_no, role HERE/FIND, icon, sign_ko, sign_en, title{en,ko}, actions{en[],ko[]}, photo_url, photo_credit, elevator_status}] | 아니요 | S02 전체 안내 + 다시 시도 |
| fetchTips(route, stepNo) | GET /api/tips?route=&step= | route, step_no | [Tip] | 아니요 | 팁 영역만 '불러오지 못했어요' |
| fetchMyTips(session) | GET /api/tips/mine (후보, 핸드오프에 없음) | — | [Tip] | 예 | S06 안내 + 다시 시도 |
| createTip(draft, session) | POST /api/tips | route, step_no, title, location, note(빈 값 null) | Tip(id·status VERIFIED·owner_id·verified_at) | 예 | 400 validation, 401 → '로그인이 끝났어요'(값 유지), 그 밖 → '올리지 못했어요'(값 유지) |
| updateTipStatus(id, status, session) | PATCH /api/tips/{id}/status | {status} | Tip | 예(올린 사람) | 403·401 → '지금은 바꿀 수 없어요' + 다시 로그인, 그 밖 → '상태를 바꾸지 못했어요' + 다시 시도 |
| login(username, password) | POST /api/auth/login | username, password | user_id, username, 로그인 확인 값(토큰) | — | 불일치 → invalidCredentials(아이디 유지·비밀번호 비움), 그 밖 → loginError |

Tip JSON: id, route(EXPRESS/LOCAL), step_no, title, location, note, status(VERIFIED/OUTDATED), owner_id, verified_at(YYYY-MM-DD), is_example.

### 서버와 맞춰 볼 질문
1. 경로·단계 안내를 서버가 두 언어({en, ko})로 함께 주는가, `lang` 파라미터로 하나만 주는가. 앱은 두 언어를 함께 받는 형식으로 만들었다.
2. 사진은 서버 URL인가 앱 안 파일인가. 지금 photo_url은 'assets/...' 경로이고, http로 시작하면 Image.network로 읽는다.
3. verified_at의 뜻: 앱은 '작성자가 상태를 마지막으로 정한 날'(확인함·오래됨 모두)로 쓴다. 이름을 status_changed_at 등으로 바꿀지.
4. '내가 올린 팁인지'는 owner_id와 로그인 user_id를 비교한다. 서버가 is_mine을 따로 줄지.
5. 내 팁 목록 경로(GET /api/tips/mine 후보)와 응답에 경로 이름·단계 수를 함께 줄지(지금은 경로 목록을 따로 읽어 이름을 붙임).
6. 글자 수 단위: 앱은 코드 포인트로 센다(이모지 1개 = 1자). 서버 검증 단위와 같아야 한다.
7. 오류 응답 형식(코드·메시지)과 연결 끊김 판별: 앱은 offline/server/unauthorized/forbidden/validation으로 나눈다.
8. 예시 팁(is_example)을 서버 자료로 둘지, 앱에서 뺄지.

### 바꿀 파일 / 그대로 둘 파일
- 바꿀 것: lib/repositories/http_subway_repository.dart(실제 요청), lib/main.dart(FakeSubwayRepository → HttpSubwayRepository), pubspec.yaml(http 패키지, 승인 후), android/app/src/main/AndroidManifest.xml(INTERNET 권한, http:// 개발 주소면 cleartext 허용).
- 로그인 결과: UserSession(user_id·username·accessToken)을 서버 응답으로 채운다. 지금은 앱 메모리에만 두고 기기에 저장하지 않는다(앱을 끄면 로그아웃). 기기에 남길지는 10장에서 정한다.
- 그대로 둘 것: lib/theme, lib/widgets, lib/screens, lib/l10n, lib/validation(서버 규칙과 같으면).
- 401·403·통신 실패 때 입력 유지: S03은 실패해도 값을 지우지 않고(401이면 다시 로그인 후 같은 화면으로 돌아옴), 위젯 검사 add_tip_test.dart에 실패 경우가 있다. 실제 서버 응답으로 다시 확인한다.

### 아직 실행하지 않은 플랫폼과 이후 검사
- Chrome(웹), 실기기, iOS: 미확인.
- TalkBack 실제 낭독(제목 초점 이동, 단계 제목 live region, 혼합 언어 구절의 목소리 전환): 미확인.
- 한글 낱말 단위 줄바꿈(4차 VIS-05): Flutter는 keep-all을 지원하지 않아 음절 단위로 끊길 수 있다. 미확인.

## 4. Codex 반박 리뷰 판정 (C:\dev\CLAUDE.md 규칙, 2회)

| 회차 | 지적 | 판정 | 이유 | 조치 |
| --- | --- | --- | --- | --- |
| 1 | [높음] 로그인 중 취소해도 늦게 온 응답이 세션을 덮어씀 | 수용 | login_screen.dart가 응답 뒤 mounted 확인 전에 signIn을 불렀다. 검사로 재현됨(닫히는 애니메이션 동안 mounted가 true인 경우까지) | PopScope로 닫힘(_left) 기록, '!mounted \|\| _left'면 결과 버림. 같은 원리로 S03에 _here 추가(닫히는 중 응답이 S02를 닫던 문제). 회귀 검사 2개 |
| 1 | [중간] 권한 없음 뒤 단계를 왕복하면 재로그인 안내 없이 버튼만 막힘 | 수용 | _goTo가 안내만 지우고 막힘은 남김 | 막힌 팁은 안내를 다시 보이게 함. 검사 추가 |
| 1 | [중간] 재로그인 화면을 취소해도 막힘이 풀림 | 수용 | 로그인 결과를 보지 않고 세션 존재만 확인 | LoginScreen이 true를 돌려줄 때만 해제(S03도 같게). 검사 추가 |
| 2 | [중간] S06에서 탭을 오가면 막힘이 풀림 | 수용 | 막힘이 화면 State에 있어 탭 전환 때 사라짐 | 막힘을 AppController(세션 단위)로 옮기고 로그인·로그아웃 때 비움. 검사 추가 |
| 2 | [중간] 재로그인 뒤 도착한 앞 세션의 401이 새 세션을 다시 막음 | 수용 | 응답이 요청 당시 세션인지 보지 않음 | 세션 세대 번호를 요청 때 기록하고 달라졌으면 무시. 검사 추가(고치기 전 실패 확인) |

기각·보류: 없음. 2회차 수정 뒤 3회차 리뷰는 받지 않았다(규칙상 최대 2회, 이후는 사용자 판단).
