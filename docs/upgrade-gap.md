# 앱 고도화 차이표 (docs/upgrade-gap.md)

문서 정보: 2026-10-21 · 작성 Claude Code(조사 에이전트, 읽기만 함) · 확인: (본인 이름)
목적: 5장 최신판(5차 점검 반영본)과 지금 앱(10장 끝) 사이의 차이. prompts/upgrade/의 요청문이 이 표의 ID(C-15, S2-01 …)로 일을 가리킨다.
줄 번호는 5장 원본(C:\dev\chapter05-ai\docs) 기준이다. 앱 docs/의 .md 사본은 맨 위 사본 표시 2줄 때문에 2줄씩 밀려 있다(json·csv는 같음).

약어: DS=design-system.json, CR=component-rules.md, R5=ui-review-round5-design-plugin.md, UH=ui-handoff.md, SF=screen-flow.csv, UR=ui-requirements.csv, VD=ui-validation-decisions.md, S02~S06=S0x-screen-spec.md.
우선: 필수(명세 규칙·결정과 어긋남) / 권장(5차가 권했으나 명세에 없음) / 선택 / 반영됨 / 10장 충돌 / 미결정(애플식) / 결정 대기.

## 먼저 결론

- **필수 11건**: C-15, C-19, C-24, C-26, S2-01, S2-02, S2-03, S2-06, S3-01, S5-01, S6-01. 모두 lib·test 안에서 해결되고 서버 변경은 없다.
- 5차 A절 지적 61건은 앱에 거의 반영되지 않았다. 다만 최신 DS·명세가 지금 앱 값을 '현재 동작'으로 적은 곳이 많아, 5차 권고를 따르려면 문서부터 바꿔야 하는 항목이 많다(사용자 결정 필요).
- 5장 문서가 10장보다 먼저 갱신돼 403 문구·시간 초과·S03 시간 초과 흐름·오프라인 판정이 문서에서 낡았다. 앱이 맞고 문서를 고칠 일이다(2절).

## 1. 차이표

### 1-1 공통 요소

| ID | 요소 | 문서 근거 | 지금 앱 | 차이 | 우선 | 결정 |
|---|---|---|---|---|---|---|
| C-01 | 색 토큰 | DS:65-108 | lib/theme/app_colors.dart:51-95 | 20키 × 밝게·어둡게 값이 같음 | 반영됨 | — |
| C-02 | 글자 버튼(링크) 색 | R5 CRIT-08·DSYS-07, DS:310·541 | app_colors.dart:106-107 `link => routeLocal` | 일반열차 파랑을 링크에 빌려 씀. 5차는 같은 값의 link 토큰만 분리 권함 | 선택 | 예(C-05와 함께) |
| C-03 | 다크 표지판 칩 | R5 DSYS-09·CRIT-06, DS colorsDark.signage #0B1E3D | app_colors.dart:88, step_widgets.dart:116-119 | 칩 바탕과 화면 바탕 대비 1.05:1 | 권장 | 예(칩 전용 토큰/signage 변경/2px 테두리) |
| C-04 | 상단 바 색(애플식 1) | 비교 페이지만 있음. DS page.appBar는 signage 바탕(DS:504·541) | app_theme.dart:79-88 | 남색 → 배경색 안 | 미결정 | 예 |
| C-05 | 강조색 통일(애플식 2) | 5차 DSYS-07은 남색 링크 안을 쓰지 않음 | C-02와 같은 곳 | 남색 글자+연한 pill 안(5차와 반대 방향) | 미결정 | 예 |
| C-06 | 글자 스타일 토큰 | R5 DSYS-04, DS typography(DS:109-223), DS:534 | app_theme.dart:29-38(8개), 화면·위젯에 `fontSize: 숫자` 29곳 | 값은 같지만 이름 붙은 스타일이 없음 | 권장 | 아니요 |
| C-07 | 확인창 제목 | R5 DSYS-08, DS dialogTitle 26(DS:151-155) | app_theme.dart:147-150 | 앱=DS. 5차는 19~20 권함 | 선택 | 예 |
| C-08 | 간격 토큰 | R5 DSYS-11, DS spacing.gutter 10(DS:229) | app_theme.dart:7-12, 숫자 간격 70여 곳 | gutter 상수 없음. 4·8·14 등은 DS에 이름 없음 | 권장 | 예(Q21) |
| C-09 | 모서리 토큰 | R5 DSYS-12, DS radii.sign·box·dialog | app_theme.dart:14-19, 숫자 모서리 14곳 | DS 키에 맞는 앱 상수 없음 | 권장 | 예(Q21) |
| C-10 | 크기 토큰 | DS sizes(DS:244-247) | app_theme.dart:21-25·93, route_list_screen.dart:218, settings_screen.dart:235 | 값은 같고 상수 없음 | 권장 | 아니요 |
| C-11 | 주요 버튼 '처리 중' | R5 DSYS-01·CRIT-09·A11Y-06, DS:273-277 | add_tip_screen.dart(비활성 색, 진행 원 없음), login_screen.dart:190-204 | S03·S04 모양이 다르고 '올리는 중…' 대비 2.59:1, 낭독 공지 없음 | 권장 | 예(Q13) |
| C-12 | 키보드 초점 | R5 A11Y-02 | common.dart:48-56, 버튼 테마에 초점 테두리 없음 | 제목이 Tab 정지점, 초점 표시 약함 | 권장 | 예(Q15) |
| C-13 | 눌림·선택 상태 토큰 | R5 DSYS-17 | 없음 | — | 선택 | 예 |
| C-14 | 입력칸 | DS:316-335, CR:44-51 | labeled_field.dart | 같음 | 반영됨 | — |
| C-15 | 비밀번호를 보일 때 제안·자동고침 | CR:59, S04:16 규칙 | labeled_field.dart:64-65 `enableSuggestions: !obscureText` | 보이게 하면 제안·자동고침이 켜짐 | **필수** | 아니요 |
| C-16 | 팁 카드 위치 줄 | R5 CRIT-07·COPY-20, DS tipCard(DS:409) | tip_card.dart:67·95 | 위치가 12 회색, 작성자와 ' · '로 붙음 | 권장 | 예(DS 먼저) |
| C-17 | 배지 글자 13 이상 | R5 CRIT-07, DS badge 12 | common.dart:95 | 앱=DS | 선택 | 예 |
| C-18 | 배지 이름·예시 배지 토큰 | R5 DSYS-15·16, DS statusBadge | common.dart:79-98, tip_card.dart:18 | 앱=DS | 선택 | 아니요 |
| C-19 | 하단 메뉴 같은 탭 다시 누름 | DS:381, CR:163, S05:16, S06:16, SF:14 | home_shell.dart:26 `if (tab == _tab) return;` | 맨 위로 가지 않음 | **필수** | 아니요 |
| C-20 | 하단 메뉴 나머지 동작 | DS:379-383, SF:11-17 | home_shell.dart:25-89 | 같음 | 반영됨 | — |
| C-21 | 오류 하단 알림 유지 | R5 A11Y-05, DS snackBar 3초 | app_controller.dart:142-148 | 앱=DS. 5차는 오류 알림을 닫을 때까지 남기라고 권함 | 권장 | 예(Q14) |
| C-22 | 자동 로그아웃 알림 | R5 COPY-03, S02:18 | step_guide_screen.dart:134 등 | 직접 로그아웃과 같은 문구 | 선택 | 예 |
| C-23 | 안 쓰는 변형·줄 | R5 DSYS-18, DS:437 | common.dart:101·118, route_list_screen.dart:225 | 정리할 거리 | 선택 | 아니요 |
| C-24 | 동작 줄이기 → 새 팁 스크롤 | DS:510·546, CR:187 | step_guide_screen.dart:168(300ms 고정) | 동작 줄이기여도 애니메이션 | **필수** | 아니요 |
| C-25 | 15초 시간 초과 | UH:127 | http_api_transport.dart | 10장에서 넣음 | 반영됨 | — |
| C-26 | 8초 '느린 연결' 줄 | UH:127, CR:147, S02:18, S06:18 | lib 전체에 없음 | S01·S02(단계·팁)·S06 불러오는 중 화면에 없음 | **필수** | 아니요(와이파이 이름은 현장 확인) |
| C-27 | 한국어 말끝(해요체) | R5 COPY-04·CRIT-16 | app_strings.dart 합니다체 9곳 | — | 권장 | 예(Q7) |
| C-28 | '등록'과 '올리기' 섞임 | R5 COPY-05 | app_strings.dart 여러 곳 | 같은 동작을 두 낱말로 부름 | 권장 | 예(Q8) |

### 1-2 S01 경로 목록

| ID | 항목 | 문서 근거 | 지금 앱 | 차이 | 우선 | 결정 |
|---|---|---|---|---|---|---|
| S1-01 | 진행 중 카드 '5/5' | R5 COPY-01·CRIT-04 ↔ UR R01, DS:396 | route_list_screen.dart:188-192 | 진행 중과 완료가 같은 큰 분수 | 권장 | 예(Q9) |
| S1-02 | 카드 안 위계 | R5 CRIT-04 | route_list_screen.dart:199·246 | 단계 수가 이름보다 큼 | 선택 | 예 |
| S1-03 | 빈 목록 | R5 COPY-14 ↔ DS:452 | route_list_screen.dart:105-108 | 할 행동·다시 시도 없음 | 선택 | 예(Q10, 현장 확인) |
| S1-04 | 읽기 실패 제목 | R5 COPY-02 ↔ DS:451 | route_list_screen.dart:93-102 | 무엇을 못 불러왔는지 말하지 않음 | 선택 | 예(Q10) |
| S1-05 | T2 머리말 | R5 A11Y-10 | route_list_screen.dart:151 | 제목(heading)으로 읽히지 않음 | 권장 | 아니요 |
| S1-06 | T2 문구 반복 | R5 COPY-15 ↔ DS:257 | app_strings.dart | — | 선택 | 예 |
| S1-07 | 처음부터 | R5 CRIT-05·A11Y-07, SF:9 | route_list_screen.dart:139-146 | 누르면 버튼이 사라져 초점을 잃고 알림·되돌리기 없음 | 권장 | 예(Q19) |
| S1-08 | 카드 화살표 | R5 CRIT-12 | 없음 | — | 선택 | 아니요 |
| S1-09 | 8초 문구 | C-26 | route_list_screen.dart:81-90 | — | **필수** | — |
| S1-10 | 같은 탭 맨 위로 | C-19 | — | — | **필수** | — |
| S1-11 | 제목 키우기(애플식 3) | 비교 페이지만 있음 | route_list_screen.dart:133 | 새 크기는 DS 키 필요 | 미결정 | 예 |

### 1-3 S02 단계 안내

| ID | 항목 | 문서 근거 | 지금 앱 | 차이 | 우선 | 결정 |
|---|---|---|---|---|---|---|
| S2-01 | 단계를 옮기면 맨 위로 | S02:16 규칙, SF:23, R5 CRIT-01 | step_guide_screen.dart:179-198(_goTo), common.dart:210-220(ScrollColumn에 controller 없음) | 스크롤 위치가 그대로 남음 | **필수** | 아니요 |
| S2-02 | 큰 글자 문턱 | S02:18 규칙(본문 16 기준 1.3·1.7), R5 A11Y-01·CRIT-14 | step_guide_screen.dart:256 `>= 2.0`, step_widgets.dart:73 `scale(10)/10 >= 1.3` | Android 200%에서 본문은 약 1.75배라 바가 고정으로 남음. 검사는 선형 배율만 씀(test/helpers.dart:27) | **필수** | 예(Q5: handoff.md '글자 2배 이상' 행이 바뀜) |
| S2-03 | 단계 0개 | S02:18 규칙, UH:76 | step_guide_screen.dart:98(clamp → 바로 완료 화면) | 'No steps yet / 아직 단계가 없습니다' + 경로 목록으로 대신 완료 화면 | **필수** | 아니요 |
| S2-04 | 8초 문구 | C-26 | step_guide_screen.dart:259-269·439-446 | — | **필수** | — |
| S2-05 | 새 팁 스크롤(동작 줄이기) | C-24 | — | — | **필수** | — |
| S2-06 | 전체 단계 목록 낭독 | DS:314·494, CR:39 / R5 A11Y-04 | step_guide_screen.dart:570-575·333-339·456-462 | 항목에 탭 동작 정보 없음(excludeSemantics), 펼침이 MergeSemantics 없이 버튼을 감쌈 | **필수** | 아니요 |
| S2-07 | '현재 위치' 칩 모양 | R5 CRIT-03·DSYS-10, DS:343-349 | step_widgets.dart:113-120 | HERE·FIND 칩이 같은 남색 채움 | 권장 | 예(Q11) |
| S2-08 | 다크 칩 대비 | C-03 | — | — | 권장 | 예 |
| S2-09 | 단계 이동 낭독에 표지판 | R5 A11Y-03, S02 미결 6 | step_guide_screen.dart:389 | 'Step n of N: 제목'만 읽음 | 선택 | 예(Q16) |
| S2-10 | 사진 출처 'Photo:' | R5 COPY-11, S05:15 '제1유형' | lib/models/step_photos.dart:10-11 | 한국어 화면에도 'Photo:', '1유형' | 권장 | 아니요 |
| S2-11 | 사진 자리표시 글자 | R5 CRIT-02 ↔ DS:360 | step_widgets.dart:174-178 | 앱=DS | 선택 | 예(현장 확인) |
| S2-12 | 팁 위치 줄 | C-16 | — | — | 권장 | 예 |
| S2-13 | '지난 팁' 이름 | R5 COPY-06 | app_strings.dart | 실제로는 '오래됨' 팁만 들어 있음 | 선택 | 예(Q8) |
| S2-14 | 상태 버튼 한국어 | R5 COPY-07 | app_strings.dart | 배지 낱말과 다름 | 선택 | 예(Q8) |
| S2-15 | 'Step n again' | R5 COPY-12 | app_strings.dart | 동사 없음 | 선택 | 예(Q8) |
| S2-16 | 팁 글 언어 표시 | R5 A11Y-08 | tip_card.dart | locale 없음 | 선택 | 아니요 |
| S2-17 | 403 문구 | 10장 결정 ↔ S02:18, SF:36, UH:120 | app_strings.dart(forbidden) | 앱이 결정대로, 문서가 옛 문구 | 10장 충돌 | 결정됨(문서만 고침, K-01) |

### 1-4 S03 팁 등록

| ID | 항목 | 문서 근거 | 지금 앱 | 차이 | 우선 | 결정 |
|---|---|---|---|---|---|---|
| S3-01 | 서버 400 → 칸별 오류 | S03:17 규칙, UH:118, R5 먼저 할 일 8 | subway_repository.dart:35-56(fieldErrors 남김), add_tip_screen.dart(validation → 상자 하나) | 칸 이름을 받지만 화면이 쓰지 않음 | **필수** | 예(Q4: 칸 아래 문구. 서버 한국어 문구는 쓰지 않음) |
| S3-02 | 시간 초과 흐름 | S03:18 '올리기 실패와 같게' ↔ 10장 Codex 반박 수용 | add_tip_screen.dart(응답 없음 경고 → 팁 목록 확인) | 10장 방식이 문서와 다름 | 10장 충돌 | 예(Q3, 앱 유지 권장) |
| S3-03 | 처리 중 | C-11 | — | — | 권장 | 예 |
| S3-04 | 빈 칸 오류 문구 | R5 COPY-08·CRIT-15 ↔ S03:17 | app_strings.dart, tip_rules.dart:10 | 두 칸 모두 'Enter 1–80 characters.' | 권장 | 예(현장 확인) |
| S3-05 | 실패 원인별 문구 | R5 COPY-10 | add_tip_screen.dart | offline·server·400이 같은 상자 | 권장 | 예 |
| S3-06 | '로그인 끝남' 문구 | R5 COPY-03·19 | app_strings.dart | — | 선택 | 예 |
| S3-07 | 화면 제목·버튼 낱말 | C-28 | — | — | 권장 | 예 |
| S3-08 | 확인창 제목 크기·말끝 | C-07, C-27 | — | — | 선택 | 예 |

### 1-5 S04 로그인

| ID | 항목 | 문서 근거 | 지금 앱 | 차이 | 우선 | 결정 |
|---|---|---|---|---|---|---|
| S4-01 | 눈 아이콘을 눌러도 제안 끔 | C-15 | login_screen.dart:150-171 | — | **필수** | 아니요 |
| S4-02 | 처리 중 | C-11 | login_screen.dart:190-204 | 진행 원은 있음. 비활성 색, 공지 없음 | 권장 | 예 |
| S4-03 | 실패 문구 | R5 COPY-10·13 | app_strings.dart | 서버 오류에도 'Check your connection' | 선택 | 예 |

### 1-6 S05 설정

| ID | 항목 | 문서 근거 | 지금 앱 | 차이 | 우선 | 결정 |
|---|---|---|---|---|---|---|
| S5-01 | 버전 문구 | S05 미결 1('10장 서버 연결 뒤 바꾼다'), R5 COPY-17 | app_strings.dart 'not connected to a server yet', main.dart(기본이 서버) | 10장 뒤 사실과 다름 | **필수** | 예(Q6) |
| S5-02 | 같은 탭 맨 위로 | C-19 | — | — | **필수** | — |
| S5-03 | 다크 테마 선택 칸 | R5 CRIT-13 ↔ S05:15(#111A29) | settings_screen.dart:168 | 앱=명세 | 선택 | 예(Q20) |
| S5-04 | 사진 출처 접기·복사 | R5 CRIT-10 | settings_screen.dart:111-126 | 주소가 화면 절반 | 선택 | 예(링크 열기는 url_launcher 승인 필요) |
| S5-05 | '(으)로 로그인됨' | R5 COPY-18 | app_strings.dart | — | 선택 | 예(Q8) |

### 1-7 S06 내 팁

| ID | 항목 | 문서 근거 | 지금 앱 | 차이 | 우선 | 결정 |
|---|---|---|---|---|---|---|
| S6-01 | 불러오는 중 문구 | S06:18 규칙, CR:147, UH:81 | my_tips_screen.dart:113-118 | 자리표시만 있고 'Loading your tips…' 줄 없음 | **필수** | 아니요 |
| S6-02 | 8초 문구 | C-26 | — | — | **필수** | — |
| S6-03 | 같은 탭 맨 위로 | C-19 | — | — | **필수** | — |
| S6-04 | 빈 목록 | R5 COPY-09 | my_tips_screen.dart:133 | 제목 없음, 화면에 없는 'Tips section'을 가리킴 | 선택 | 예(Q10) |
| S6-05 | 로그인 전 제목 | R5 COPY-16 | my_tips_screen.dart:100-108 | 'My tips' 반복 | 선택 | 예(Q10) |
| S6-06 | 두 버튼 모양 구분 | R5 CRIT-11 | my_tips_screen.dart:156-161 | 이동과 상태 변경이 같은 파란 글자 | 선택 | 예 |
| S6-07 | '이 단계 보기'로 연 S02의 뒤로 | S06 미결 3 | home_shell.dart:32-39 | 지금은 S01로 감 | 결정 대기 | 예(Q17) |
| S6-08 | 탭을 바꿀 때 상태 유지 | S06 미결 4 | home_shell.dart:64-68 | 탭마다 새로 만듦 | 결정 대기 | 예(Q17) |

## 2. 10장과 충돌하는(낡은) 5장 문서 — 앱은 그대로, 문서를 고칠 것

| ID | 내용 | 문서 위치 | 실제(10장) |
|---|---|---|---|
| K-01 | 403 문구 | S02:18, SF:36, UH:120, R5 COPY-19, 앱 docs/handoff.md | app_strings.dart forbidden(10장 결정) |
| K-02 | '시간 초과 없음' | S02·S03·S04·S06 :18, UH:71·127, SF:5·43·56·69 | 15초(http_api_transport.dart). 8초 문구만 규칙으로 남김 |
| K-03 | S03 시간 초과 흐름 | S03:18, UH:78·127, SF:43 | 응답 없음 경고 → 팁 목록 확인 → 같은 팁 알림 |
| K-04 | 오프라인 판정 | UH:133 '연결 실패는 offline' | 기기 망 없음만 offline |
| K-05 | 10장 문구·상자가 문서에 없음 | S03:18, DS:436·468, 앱 docs/handoff.md | postUnknown·checkTips·postFound |
| K-06 | 앱 handoff.md 3절 표 | 앱 docs/handoff.md | 400은 상자, 401은 로그아웃 |
| K-07 | 로그인 유지 | S04 미결 2, UH:62 | 메모리에만 둠. 결정으로 적을지 정할 것(Q22) |
| K-08 | S05 버전 | S05 미결 1 | 앱도 고침(S5-01) |

## 3. 문서끼리 어긋난 곳

- 카드 사이 간격: S06:15는 12, DS:505는 gutter 10. 앱은 S06 12, S02 팁 10.
- 공공누리: UH:27·step_photos.dart는 '1유형', S05:15·app_strings.dart는 '제1유형'.
- 빈 칸 오류 문구: COPY-08과 CRIT-15가 다른 안.
- 시간 초과: HAND-11은 10·15·5초를 권했지만 문서는 15초·8초로 확정(문서를 따름).

## 4. 사용자 결정 질문

P02~P04 전에 필요한 것:
1. 마감(10-22) 전 범위: 권장은 P02~P04(필수 전부). 애플식 3가지는 마감 뒤로?
2. 10장과 충돌하는 5장 문서(K-01~K-08)를 누가·언제 고칠지(P00 쓰기 범위 밖)
3. S03 시간 초과는 10장 방식을 두고 S03 명세를 고칠까?(권장: 앱 유지)
4. S03 400 칸 오류 문구: (가) 앱 검증을 다시 돌려 종류를 고르고 없으면 새 일반 문구 / (나) COPY-08 칸별 문구. route·stepNo 오류는 상자로 둘까?
5. S02 큰 글자 문턱을 1.7로 바꾸며 handoff.md '글자 2배 이상' 행도 바꿀까?
6. S05 버전 문구: 'Version 1.0.0 · student project / 버전 1.0.0 · 학생 실습 프로젝트' + 가짜 저장소일 때만 'Demo data / 시연용 데이터'?

그 뒤에 필요한 것(권장·선택 묶음): 7 해요체 통일, 8 낱말 변경(등록→올리기 등), 9 S01 진행 표기, 10 빈 상태·오류 제목, 11 표지판 칩, 12 링크 색, 13 처리 중 공통 버튼, 14 오류 알림 유지, 15 초점 테두리 3px, 16 단계 이동 낭독, 17 S06 뒤로·탭 상태, 18 확인창 제목 크기, 19 '처음부터' 되돌리기, 20 S05 다크 선택 칸, 21 DS에 이름 없는 숫자, 22 로그인 메모리 유지 결정, 23 FAKE_SCENARIO 추가(slow·no-steps·post-400), 24 단계 안내 말끝(서버 시드).

## 5. 확인하지 못한 것

- 앱을 실행하지 않았다(analyze·test·에뮬레이터·TalkBack). 5차 대비·캡처 판정은 인용이고 1.05:1·2.59:1만 다시 계산했다.
- 애플식 비교 기록은 claude.ai 비교 페이지에만 있다.
- 서버 코드·시드는 읽지 않았다. 실제 역 정보(층수·표지판·엘리베이터·와이파이 이름)는 현장 확인 항목으로 남아 있다.
- SemanticsService.announce는 이 SDK에서 deprecated다(flutter/lib/src/semantics/semantics_service.dart:51-55). 공지는 Semantics(liveRegion)로 하는 것이 안전하다.
