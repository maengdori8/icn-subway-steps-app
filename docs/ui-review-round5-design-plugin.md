# UI 검증 5차 · Design 플러그인 점검 (Flutter 앱 + 시안 v03)

사본 · 원본 C:\dev\chapter05-ai\docs · 복사 2026-10-21

문서 정보: 2026-10-21 · 작성 Claude Code · 검토: (본인 이름)

## 방법

Design 플러그인의 스킬 다섯 가지 관점으로 검토자 5명이 따로 봤다.

| 관점 | 쓴 스킬 | 대상 |
| --- | --- | --- |
| CRIT 디자인 비평 + 원칙 체크리스트 | design-critique, 사용자가 준 UI/UX 원칙 목록 | Flutter 캡처 27장, 시안 캡처, 화면 코드 |
| A11Y 접근성 | accessibility-review(WCAG 2.1 AA) | 색 토큰(밝게·어둡게), Semantics, 누름 영역, 글자 배율 |
| COPY 문구 | ux-copy | app_strings.dart(en·ko), 시안 문구 |
| DSYS 디자인 시스템 | design-system audit | design-system.json, 시안 CSS, app_colors.dart·app_theme.dart, tokens.json 초안 |
| HAND 인계 일치 | design-handoff | 시안 ↔ Flutter ↔ 5장 문서 |

- 지적마다 다른 검증자가 파일과 캡처를 직접 열어 반박을 시도했다. 대비 값은 다시 계산했다.
- 확정 결정(설정에서만 테마·언어, 하단 메뉴, 온라인 전용 등)과 부딪히는 지적은 기각하거나 권고를 고쳤다.
- 사용자 지시(2026-10-21 "반영 ㄴㄴ")에 따라 **Flutter 앱은 고치지 않았다.** 이 문서는 결과 보고만 한다.
- 디자인 문서 쪽 지적(B절)은 같은 날 진행한 문서 갱신 작업(DEC-01 해소)에서 처리한다.
- 시안 v03은 2026-10-20 상태로 고정했다. 이후 기준은 5장 문서와 실제 Flutter 앱이다.

## 숫자로 본 결과

| 관점 | 지적 | 확인 | 일부 확인 | 기각 |
| --- | --- | --- | --- | --- |
| CRIT | 17 | 10 | 7 | 0 |
| A11Y | 14 | 6 | 5 | 3 |
| COPY | 21 | 11 | 9 | 1 |
| DSYS | 18 | 9 | 9 | 0 |
| HAND | 21 | 13 | 7 | 1 |
| 합계 | 91 | 49 | 37 | 5 |

- 치명(critical)은 0건이다. 검증 뒤 중간(major)은 Flutter 1건(CRIT-01), 문서 5건(HAND-01·02·04·05·11)이다.
- 대비: 글자 대비는 밝게·어둡게 모두 4.5:1 이상이다(가장 낮은 값 4.69:1). 누르는 곳은 모두 48dp 이상이다.
- 디자인 시스템 점수: 58/100
  - 토큰 값 일관성 22/25: 색 20개 키가 4곳에서 모두 같다.
  - Flutter의 토큰 사용 13/25: 글자·간격·모서리를 숫자로 직접 쓴 곳이 많다.
  - 컴포넌트 상태 완성도 15/25
  - 문서·이름 규칙 8/25

## 원칙 체크리스트 결과 (사용자 제공 목록, 첫 정식 점검)

| 묶음 | 원칙 | 결과 | 근거 지적 |
| --- | --- | --- | --- |
| UI 핵심 | 계층 구조 | 부분 | CRIT-02·04, CRIT-07 |
| UI 핵심 | 일관성 | 부분 | CRIT-08, COPY-04·05·07, DSYS-15 |
| UI 핵심 | 명료함·간결성 | 부분 | CRIT-10, COPY-15·16 |
| UI 핵심 | 가독성·대비(44pt) | 부분 | 글자 대비·누름 영역은 통과, 다크 칩 1.05:1(DSYS-09·CRIT-06), '올리는 중' 2.59:1(DSYS-01) |
| 닐슨 | 시스템 상태의 가시성 | 부분 | CRIT-01·09, A11Y-06 |
| 닐슨 | 실세계와의 일치 | 통과 | '승강장에 왔어요', 한·영 표지판 병기 |
| 닐슨 | 사용자 제어와 자유 | 부분 | CRIT-05('처음부터'·로그아웃 되돌리기 없음) |
| 닐슨 | 오류 예방 | 부분 | 버리기 확인창은 좋음, COPY-08·CRIT-15 |
| 닐슨 | 기억보다 직관 | 부분 | CRIT-12, COPY-20 |
| UX 법칙 | 피츠 | 통과 | 하단 고정 이전·다음, '다음'이 더 넓음 |
| UX 법칙 | 제이콥 | 부분 | Android 표준 하단 메뉴는 통과, CRIT-03·12 |
| UX 법칙 | 테슬러 | 통과 | 경로·단계 미리 채움, 진행 저장, 로그인 뒤 원래 단계로 |
| UX 법칙 | 게슈탈트 | 부분 | CRIT-03('현재 위치'와 '찾을 표지판' 칩이 같은 모양), CRIT-11 |

## 나중에 앱을 고친다면 먼저 할 것 (같은 문제를 여러 관점이 낸 것을 묶음)

1. **단계를 넘기면 맨 위로 스크롤(CRIT-01, 중간):** 지금은 앞 단계의 스크롤 위치가 남아서 새 단계의 사진·진행 표시가 가려진 채 열린다.
2. **큰 글자 규칙이 실제 Android 배율에서 작동하지 않음(A11Y-01·HAND-08·CRIT-14):** 글자 2배일 때 이전·다음을 본문 끝으로 옮기는 규칙이 캡처에서 작동하지 않았다.
3. **'현재 위치' 칩과 '찾을 표지판' 칩 모양 구분(CRIT-03·DSYS-10):** 현재 위치 칩을 테두리형으로 바꾼다.
4. **다크 모드 칩 대비(DSYS-09·CRIT-06):** 칩 바탕과 화면 바탕의 대비가 1.05:1이다. 4차 VIS-03이 아직 남아 있다.
5. **처리 중 상태(DSYS-01·CRIT-09·A11Y-06):** '올리는 중…' 글자가 2.59:1로 흐리다. 진행 표시와 낭독 공지가 필요하다.
6. **S01 '5/5' 진행 중·완료 구분(COPY-01·CRIT-04)**
7. **한국어 말끝 통일(COPY-04·CRIT-16):** '해요'체로 맞춘다.
8. **서버 입력 오류(400)를 칸별 오류로(기능 명세서 Codex 반박 1번):** 지금은 일반 실패로만 보인다.

## 검증을 통과한 지적

### A. Flutter 앱 (반영 보류) (61건)

| ID | 심각도 | 판정 | 화면 | 문제 | 고칠 방법 |
| --- | --- | --- | --- | --- | --- |
| CRIT-01 | 중간 | 확인 | S02 | S02에서 다음·이전을 눌러도 화면이 맨 위로 돌아가지 않아, 새 단계의 사진·칩·진행 표시를 놓칩니다(시안보다 나빠짐) | ScrollColumn에 ScrollController를 넘길 수 있게 하고, _goTo에서 단계가 바뀌면 controller.jumpTo(0)을 부릅니다(애니메이션을 켠 기기면 짧은 animateTo). 사진을 밀어 넘길 때와 완료 화면으로 갈 때도 똑같이 합니다. 위젯 검사에 '팁 영역까지 스크롤 → 다음 → offset 0'을 넣습니다. 지금은 팁이 1개뿐이라 20~90px 정도 밀리지만, 서버에서 팁이 늘면 다음 단계의 팁 목록부터 보이게 됩니다. |
| A11Y-01 | 낮음 | 일부 확인 | S02 | 큰 글자에서 이전·다음을 본문 끝으로 옮기는 규칙이 Android 실제 글자 배율에서는 작동하지 않습니다 | 먼저 정할 것은 '200%에서 정말 본문 끝으로 옮길지'입니다. 세로 200% 캡처에서는 고정 바도 쓸 만하므로, 둘 중 하나를 고릅니다. (가) 지금처럼 고정 바를 두기로 하면 handoff.md:33을 실제 동작('Android 비선형 배율에서는 고정 유지')에 맞게 고칩니다. (나) 원래 의도대로 옮기려면 판정을 `MediaQuery.textScalerOf(context).scale(10) / 10 >= 2.0`(StepProgress와 같은 방식)으로 바꿉니다. 또는 LayoutBuilder로 실제 남는 본문 높이를 보고 판단합니다. 어느 쪽이든 위젯 검사에 16→28을 돌려주는 사용자 TextScaler를 MediaQuery로 넣은 경우를 추가합니다. 가로 화면 검사는 선택 사항입니다. |
| A11Y-02 | 낮음 | 확인 | 전체 | 키보드 초점이 거의 보이지 않고, 화면 제목이 보이지 않는 Tab 정지점이 됩니다 | FocusHeading의 Focus에 `skipTraversal: true`를 줍니다. 화면을 열 때의 requestFocus는 그대로 동작합니다. 테마의 FilledButton·TextButton style에 `side: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.focused) ? BorderSide(color: c.textPrimary, width: 3) : null)`를 넣습니다. 경로 카드·테마·언어·단계 목록의 InkWell 카드는 초점일 때 Material shape의 side를 3px로 바꿉니다. DS flutterAdaptations.rules에는 '초점 윤곽 3px, 바탕과 3:1 이상'을 추가합니다. AA 미충족이지만 여행 중 외부 키보드 사용은 드물어 minor로 둡니다. |
| A11Y-03 | 낮음 | 일부 확인 | S02 | 단계를 넘길 때 화면 낭독기가 '찾을 표지판'을 알리지 않습니다(4차 A11Y-03이 앱에 남음) | WCAG 미충족이 아니라 개선 권고로 다룹니다. 단계 제목의 낭독 라벨에 표지판을 붙이는 안('Step 2 of 5: …. Look for this sign: 교통센터 · 공항철도, Transportation Center · Airport Railroad', 표지판 부분은 attributedLabel의 LocaleStringAttribute)을 S02 명세에 적고 그대로 구현합니다. |
| A11Y-04 | 낮음 | 확인 | S02 | '전체 단계' 목록 항목에 누르기 동작 정보가 없고, 펼침 상태가 버튼에 붙지 않습니다 | _StepListItem의 Semantics에 `onTap: onTap`을 넣습니다. 또는 excludeSemantics 대신 MergeSemantics로 묶고, 숫자·제목 Text만 ExcludeSemantics로 뺍니다. 펼침 버튼은 `MergeSemantics(child: Semantics(expanded: _showAll, child: TextButton(…)))`로 묶습니다. 위젯 검사에 `tester.getSemantics(...)`로 tap 동작과 펼침 상태를 확인하는 항목을 추가합니다. 이전·다음이라는 대안이 있어 minor입니다. |
| A11Y-05 | 낮음 | 일부 확인 | 전체 | 하단 알림이 3초 뒤 저절로 사라지고, 오류 알림도 똑같이 사라집니다 | 오류 알림 세 가지(postErrorClosed, 화면 밖 상태 바꾸기 실패·권한 없음, loggedOut)에만 SnackBarAction('OK' 등)을 달거나 `persist: true`를 줍니다. 그러면 사용자가 닫을 때까지 남습니다(이 Flutter 버전은 TalkBack과 관계없이 유지). 'Tip posted' 같은 성공 알림은 지금처럼 자동으로 닫히게 두되, 4~5초로 늘리는 것은 선택 사항입니다. DS의 '약 2초'는 같은 기준으로 고칩니다. |
| A11Y-06 | 낮음 | 확인 | S03·S04·S02·S06 | '올리는 중…'·'저장 중…'·로그인 중 상태를 알리지 않고, 그 글자도 흐립니다 | 올리기·로그인·상태 바꾸기를 시작할 때 `SemanticsService.announce(s.posting, TextDirection.ltr)`로 알립니다. 또는 버튼 옆에 Semantics(liveRegion) 상태 줄을 둡니다. 진행 표시에는 semanticsLabel(예: 'Logging in…' 문구 추가)을 줍니다. 처리 중 버튼은 바탕색을 primary 그대로 두고 진행 표시만 덧붙여 4.5:1을 지킵니다. 시안은 #srLive에 메시지를 넣습니다. |
| A11Y-07 | 낮음 | 확인 | S01 | '처음부터'를 누르면 그 버튼이 사라져 낭독 초점을 잃고, 무엇이 바뀌었는지 알리지 않습니다 | 누른 뒤 그 경로 카드의 FocusNode로 초점을 옮기고 `SemanticsService.announce('Express Train: start over')`로 알립니다. 또는 'Progress reset' 알림에 '되돌리기' 동작을 답니다. 확인 없이 지워지는 점도 함께 보완할 수 있습니다. |
| A11Y-08 | 낮음 | 일부 확인 | S02·S06 | 팁 본문(사용자 글)에 언어 표시가 없어, 한국어 화면에서 영어 팁을 한국어 목소리로 읽습니다 | 서버 계약은 바꾸지 않습니다. 앱 안에서만 팁 제목·메모·위치 글자에 한글이 있으면 ko, 없으면 en으로 판별합니다. 그다음 Text.rich(TextSpan(locale: …))로 그립니다. 'T-money'는 고유명사라 표시하지 않아도 됩니다. |
| A11Y-10 | 낮음 | 확인 | S01 | S01의 'From T2 arrivals' 묶음 머리말이 제목(heading)이 아닙니다 | `Eyebrow(s.t2, header: true)`로 바꿉니다. 시안은 `<h2 class="eyebrow">`로 바꿉니다. |
| COPY-01 | 낮음 | 확인 | S01 | S01 경로 카드에서 '진행 중'과 '완료'가 같은 큰 숫자 '5/5'로 보여, 아직 5단계를 안 끝낸 사람도 다 끝난 것처럼 읽힌다 | 권고대로 진행 중에는 분수를 쓰지 않는다. 큰 글자는 en 'Step 5' / ko '5단계', 작은 글자는 en 'continue' / ko '부터 이어 보기'(결정 9번의 '부터'를 살림). 완료는 지금처럼 '5/5' + done/완료로 둔다. |
| COPY-02 | 낮음 | 일부 확인 | S01, S02, S06 | 경로·단계·내 팁을 못 불러올 때 제목이 'Couldn't load this. Try again.'뿐이라 무엇을 못 불러왔는지, 그동안 어떻게 가야 하는지 알려 주지 않는다 | 화면별 제목과 대체 행동 본문은 권고대로 둔다. S01 'Couldn't load the routes'/'경로를 불러오지 못했어요', S02 'Couldn't load the steps'/'단계 안내를 불러오지 못했어요', S06 'Couldn't load your tips'/'내 팁을 불러오지 못했어요'. 제목에서 'Try again'은 빼고, S01·S02 본문에 '공항철도 Airport Railroad' 표지판 안내를 넣는다. offline 제목 변경은 10장에서 전송 계층이 연결 실패를 어떻게 나누는지 정할 때 함께 판단한다. 지금 바꿀 일은 아니다. |
| COPY-03 | 낮음 | 확인 | S02, S06, S03 | 로그인이 저절로 끝났을 때 이유 없이 'Logged out' 알림만 뜨고, 같은 일을 S03에서는 'Your login has ended'라고 다르게 부른다 | 자동 로그아웃용 키를 따로 만들고(sessionExpiredNotice), 직접 로그아웃(loggedOut)과 구분한다. en 'Your login expired. Log in again to add or change tips.' / ko '로그인 시간이 끝나 로그아웃됐어요. 팁을 올리거나 바꾸려면 다시 로그인하세요.' SnackBar에 'Log in'/'로그인' 동작 버튼을 달고 표시 시간을 늘린다. S03 문구도 같은 낱말로: en 'Your login expired. What you typed is kept. Log in again to post it.' / ko '로그인 시간이 끝났어요. 입력한 내용은 그대로 있어요. 다시 로그인한 뒤 올리세요.' |
| COPY-04 | 낮음 | 확인 | 전체 | 한국어 말끝이 '~합니다'와 '~해요'로 섞여 있고, 한 안내 안에서도 바뀐다 | 앱 문구는 친근한 해요체 하나로 맞춘다. 예: '입국장에서 서울역행 열차에 탈 때까지 안내해요', 'T2 안내는 준비 중이에요', '인터넷에 연결되지 않았어요', '아직 경로가 없어요', '경로가 추가되면 여기에 보여요', '팁을 올렸어요', '입력한 내용이 사라져요', '로그아웃했어요', '로그인하면 보던 단계로 바로 돌아와요'. 지시는 '~하세요'로 통일. 단계 안내 문장은 서버 자료이므로 서버 시드에서 '~하세요'형(예: '짐을 찾고 도착 출구로 나오세요')으로 바꾸도록 요청한다. |
| COPY-05 | 낮음 | 일부 확인 | S02, S03, S04, S05, S06 | 팁을 남기는 동작을 '등록'과 '올리기'(en 'Add'와 'Post')로 섞어 부른다 | 동작을 가리키는 말은 en 'post' / ko '올리기'로 맞춘다. 진입 버튼은 '+ Post a tip'/'+ 팁 올리기', 오류 문구는 'Please post it again'/'다시 올려 주세요', 'Log in to post a tip'으로 한다. S03 화면 제목만은 버튼과 겹치지 않게 명사로 둔다(en 'New tip' / ko '새 팁'). DS:144와 S03 명세:11도 함께 고친다. |
| COPY-06 | 낮음 | 확인 | S02 | 접힌 팁 묶음을 'older tips/지난 팁'이라고 부르지만 실제로는 '오래됨(out of date)' 표시된 팁만 들어 있다 | 묶음 이름을 배지와 같은 낱말로: en 'Show $n out-of-date tip(s)' / 'Hide out-of-date tips', ko "'오래됨' 팁 $n개 보기" / "'오래됨' 팁 접기". 확인된 팁이 없고 오래됨 팁만 있을 때는 한 줄을 더한다: en 'No up-to-date tips for this step yet.' / ko '이 단계에는 아직 최신 팁이 없어요.' |
| COPY-07 | 낮음 | 확인 | S02, S06 | 한국어 상태 바꾸기 버튼 낱말이 배지와 다르다('정보 오래됨'↔'오래됨', '확인함'↔'확인') | 배지의 '표시'와 같은 동사로 맞춘다. markOld ko "'오래됨'으로 표시", markOk ko "'확인'으로 표시". 배지 문구(작성자 확인 · 날짜)는 확정 사항이므로 그대로 둔다. 영어는 바꾸지 않아도 된다. |
| COPY-08 | 낮음 | 확인 | S03 | S03에서 필수 칸을 비우면 두 칸 모두 'Enter 1–80 characters.'만 떠서, 무엇이 빠졌는지 말하지 않는다 | 빈 칸 오류를 칸별 키로 나눈다. 제목: en 'Add a title for your tip.' / ko '팁 제목을 입력하세요.' 위치: en 'Add where it is (e.g. B1, next to ticket machines).' / ko '위치를 입력하세요. (예: B1, 발매기 옆)'. 길이 초과 문구('Use 80 characters or fewer.')는 유지. S03-screen-spec.md:16 validation 문구도 함께 고친다. |
| COPY-09 | 낮음 | 일부 확인 | S06 | S06 '내 팁 없음' 빈 상태에 제목·시작 버튼이 없고, 화면에 없는 이름('Tips section/팁 영역')을 가리킨다 | 문구만 고친다. 제목 en 'No tips yet' / ko '아직 올린 팁이 없어요', 본문은 화면에 실제로 보이는 버튼 이름을 그대로 인용한다(en "Open any step and tap '+ Add a tip'." / ko "단계 화면에서 '+ 팁 등록'을 누르세요.", COPY-05를 따르면 바뀐 이름으로). '경로 보기' 버튼은 하단 메뉴와 겹치므로 넣지 않아도 된다. |
| COPY-10 | 낮음 | 확인 | S03, S04 | 팁 올리기·로그인 실패 문구가 원인을 가리지 않아, 다시 해도 안 되는 경우에도 'Try again'만 권한다 | 원인별로 나눈다. 연결 끊김: en "Couldn't post — no internet connection. What you typed is kept. Connect to Wi-Fi, then tap Try again." / ko '인터넷에 연결되지 않아 올리지 못했어요. 입력한 내용은 그대로 있어요. 와이파이에 연결한 뒤 다시 시도하세요.' 입력 검사 실패: fieldErrors로 해당 칸 아래에 COPY-08 문구를 띄운다. 서버 오류: en "Couldn't post your tip right now. What you typed is kept. Try again in a moment." / ko '지금은 팁을 올릴 수 없어요. 입력한 내용은 그대로 있어요. 잠시 뒤 다시 시도하세요.' 로그인 서버 오류: en "Couldn't log in right now. Try again in a moment." / ko '지금은 로그인할 수 없어요. 잠시 뒤 다시 시도하세요.' |
| COPY-11 | 낮음 | 일부 확인 | S02, S05 | 사진 출처 줄의 'Photo:'가 한국어 화면에서도 영어로 나오고, 같은 라이선스를 '공공누리 1유형'과 '공공누리 제1유형'으로 다르게 적는다 | 'Photo:'를 AppStrings로 옮긴다(en 'Photo:' / ko '사진:'). 라이선스 이름은 정식 명칭 '공공누리 제1유형'으로 통일한다. 영어 기관명은 덧붙이려면 S05 설정의 출처(creditArrivals)에만 넣고, 사진 아래 한 줄 출처는 짧게 둔다. |
| COPY-12 | 낮음 | 일부 확인 | S02 완료 | 완료 화면 주 버튼 'Step 5 again'에 동사가 없다 | 바꾼다면 짧은 동사형 en 'Review step $n'으로 한다(약 13자, 360dp에서도 한 줄). ko '$n단계 다시 보기', 버튼 위치와 위계는 그대로 둔다. 우선순위는 낮다. |
| COPY-13 | 낮음 | 일부 확인 | S04 | 로그인 실패 문구가 무엇이 틀렸는지만 말하고, 비밀번호 칸이 비워졌으니 다시 넣으라는 안내가 없다 | 선택 사항으로 둔다. 바꾼다면 짧게 한다. en "Username or password doesn't match. Enter your password again." / ko '아이디 또는 비밀번호가 맞지 않아요. 비밀번호를 다시 입력하세요.' |
| COPY-14 | 낮음 | 확인 | S01 | S01 '경로 없음' 빈 상태가 관리자 시점 설명뿐이고, 여행객이 할 수 있는 행동이 없다 | 제목 en 'No routes to show' / ko '지금은 보여 줄 경로가 없어요', 본문 en 'Try again in a moment. Meanwhile, follow the Airport Railroad (공항철도) signs.' / ko "잠시 뒤 다시 시도하세요. 그동안 '공항철도' 표지판을 따라가세요." 버튼 'Try again'/'다시 시도'(_retry 재사용)를 단다. |
| COPY-15 | 낮음 | 확인 | S01 | T2 카드에서 'coming soon'이 두 번, 'T2'가 세 번 반복되고, T1·T2 머리말 표현도 다르다 | 설명 줄은 배지와 다른 정보를 주게 바꾼다: en 'For now, this guide covers Terminal 1 only.' / ko '지금은 제1여객터미널 안내만 있어요.'(누르면 뜨는 알림도 같은 문구로). 머리말은 en 'From T2 arrivals hall'로 T1과 맞춘다. |
| COPY-16 | 낮음 | 일부 확인 | S04, S06 | 설정·내 팁에서 들어간 로그인 화면과 S06 로그인 안내에서 상단 제목과 같은 말이 본문 제목으로 반복된다 | S06 로그아웃 상태만 고친다. 제목 en 'Log in to see your tips' / ko '로그인하면 내 팁을 볼 수 있어요', 본문 en "You don't need an account to follow the steps." / ko '길 안내는 계정 없이도 볼 수 있어요.'로 한다. S04 일반 목적 제목은 4차 REG-08대로 'Log in/로그인'을 둔다. |
| COPY-17 | 낮음 | 확인 | S05 | 설정 '정보'의 버전 문구가 '아직 서버에 연결하지 않음'으로 고정돼 있어 10장에서 서버 저장소로 바꾸면 틀린 말이 된다 | 버전과 데이터 상태를 나눠, 데이터 상태는 쓰는 저장소에 따라 보인다. 기본: en 'Version 1.0.0 · student project' / ko '버전 1.0.0 · 학생 실습 프로젝트'. 가짜 저장소일 때만 en 'Demo data' / ko '시연용 데이터'를 덧붙인다. |
| COPY-18 | 낮음 | 확인 | S05 | 한국어 계정 줄이 '(으)로' 괄호 조사를 그대로 보여 기계 번역처럼 읽힌다 | 조사가 필요 없는 형태로: ko '로그인한 계정: $user'. en 'Logged in as $user'는 유지. |
| COPY-19 | 낮음 | 일부 확인 | S02, S03 | 비원어민에게 어렵거나 어색한 영어 문장이 몇 군데 있다 | 두 곳만 고친다. forbidden en "You can't change this tip right now. Log in again, then try again.", sessionEnded en 'Your login expired. What you typed is kept. Log in again.' 'Where exactly'와 memoPh는 그대로 두어도 된다(바꾼다면 memoPh만 'What would help someone new here?'). |
| COPY-20 | 낮음 | 일부 확인 | S02, S06 | 팁 카드에서 위치가 이름표 없이 작성자와 점(·)으로만 이어져 있어, 그 줄이 '위치'라는 것을 알기 어렵다 | 위치 앞에 핀 아이콘(또는 en 'Where:' / ko '위치:')을 붙이고, 작성자는 다른 줄이나 다른 조각으로 나눈다. 작성자 표기는 지금 규칙(예시 팁 '샘플', 내 팁 '내가 올림', 그 밖 '여행객')을 그대로 쓴다. |
| CRIT-02 | 낮음 | 일부 확인 | S02 | S02 화면 위쪽 1/3을 사진(사진이 없으면 빈 칸)이 차지해, 표지판 칩과 행동 안내가 화면 아래쪽으로 밀립니다 | 읽는 순서(진행 → 사진 → 칩 → 제목)와 4:3 칸은 명세·VIS-06 결정대로 둡니다. 자리표시 글자만 textSecondary·w500 정도로 낮춰 단계 제목보다 약하게 하는 것은 해도 됩니다. 사진을 채운 뒤 작은 화면(360dp 너비)에서 칩과 제목이 첫 화면에 보이는지 다시 캡처합니다(4차 '사진을 채운 뒤 할 것'과 같은 순서). |
| CRIT-03 | 낮음 | 확인 | S02 | '현재 위치(YOU ARE HERE)' 칩과 '이 표지판을 찾으세요' 칩이 모양이 똑같아, 1단계에서 이미 서 있는 곳을 찾아야 할 표지판으로 오해하기 쉽습니다 | role == here일 때는 칩을 테두리형(surface 바탕, signage 2px 테두리, signage 글자)으로 바꾸고 아이콘도 위치 핀(Icons.place)으로 구분합니다. 찾을 표지판만 남색으로 채운 '실제 표지판 모양'으로 남겨 두면, 채운 칩 = 찾을 것이라는 규칙이 생깁니다. |
| CRIT-04 | 낮음 | 확인 | S01 | S01 경로 카드에서 가장 큰 글자가 고를 때 쓸모없는 '5 steps'이고, 진행 중 '5/5'와 완료 '5/5'가 같은 큰 숫자로 보입니다 | 단계 수를 작게, 차이 설명을 본문색으로 키우는 부분은 그대로 갑니다. 진행 중 표시는 v03 할 일 9의 '4/5부터 이어 보기'(숫자 = 이어서 볼 단계)를 유지합니다. 끝낸 단계 수(4/5 done)로 뜻을 바꾸지 말고 두 번째 안을 씁니다. 예: 'Step 5 · Continue' / '5단계부터 이어 보기'. 완료는 '✓ Done'처럼 숫자 모양을 다르게 합니다. |
| CRIT-05 | 낮음 | 일부 확인 | S01, S05 | '처음부터(Start over)'와 '로그아웃'이 한 번 누르면 바로 실행되고 되돌릴 수 없습니다. Start over는 카드 바로 밑에 붙어 있어 잘못 누르기 쉽습니다 | 카드와 처음부터 사이에 Gap(8)만 두어 누름 영역이 맞닿지 않게 합니다(버튼은 오른쪽 정렬이라 위 카드에 붙어 보이는 그룹은 유지됨). 되돌리기는 SnackBar '진행을 지웠어요 [되돌리기]' 정도면 충분합니다. 로그아웃 확인창은 넣지 않아도 됩니다. |
| CRIT-06 | 낮음 | 확인 | S02, 전체(다크) | 다크 모드에서 표지판 칩과 상단 바가 화면 바탕에 묻혀 '칩 > 제목' 위계가 약해집니다 | 다크 signage를 #3B66AB 근처로 밝힙니다. 계산하면 바탕 대비 3.05:1이고 흰 글자 5.71:1이 유지됩니다. 상단 바까지 바꾸기 싫다면 칩에만 쓸 signageChip 토큰을 따로 두거나, 테두리를 outline(#7D8BA5) 2px로 바꿉니다. design-system.json colorsDark에도 같은 값을 넣습니다. |
| CRIT-07 | 낮음 | 확인 | S02, S06 | 팁에서 가장 쓸모 있는 '위치'와 상태 배지 날짜가 12px 회색이라, 서서 보는 여행객에게 작습니다 | 위치는 14~16 본문색에 위치 아이콘을 붙여 따로 한 줄로 두고, 작성자만 12 보조 글자로 남깁니다. 상태 배지는 13 이상으로 올립니다. DS typography에 tipLocation(14, textPrimary)을 추가합니다. |
| CRIT-08 | 낮음 | 일부 확인 | 전체(S01, S02, S06) | 모든 텍스트 버튼(링크)이 일반열차 경로색을 써서, DS의 '역할을 섞지 않는다' 규칙과 어긋나고 직통 화면에서 색 신호가 헷갈립니다 | 링크에 경로색을 쓰지 않습니다. DS secondaryButton대로 텍스트 버튼 글자를 textPrimary(필요하면 밑줄이나 w700)로 하거나, 경로색과 겹치지 않는 중립 link 토큰을 DS colors·colorsDark에 새로 두고 대비 4.5:1을 다시 잽니다. app_colors.dart의 link getter 한 곳만 바꾸면 전체에 적용됩니다. |
| CRIT-09 | 낮음 | 확인 | S03 | S03 '올리는 중' 상태가 흐린 버튼 글자(2.59:1)뿐이고 진행 표시가 없어, 진행 표시가 있는 S04 로그인과 다르게 보입니다 | S03 주요 버튼도 S04처럼 16px 진행 표시와 'Posting…'을 함께 보입니다. 처리 중에는 비활성 색 대신 원래 primary 색을 유지하고 탭만 무시하게 합니다(예: onPressed는 두되 _posting이면 return). 두 화면이 같은 BusyButton 위젯을 쓰게 하면 이후에도 어긋나지 않습니다. |
| CRIT-10 | 낮음 | 확인 | S05 | S05 사진 출처에 긴 주소 6줄이 그대로 나열돼 설정 화면의 절반을 차지하고, 낱말 중간에서 끊깁니다(시안보다 복잡해짐) | 'Photo credits & licenses' 한 줄(ListTile, 오른쪽 화살표)을 두고, 눌렀을 때 별도 화면이나 ExpansionTile에서 주소를 보입니다. 주소마다 '복사' 아이콘 버튼(48dp)을 붙이면 길게 누르기를 몰라도 됩니다. 화면에는 'CC BY-SA 4.0'처럼 라이선스 이름을 링크 모양으로 보이고, 전체 주소는 펼쳤을 때만 보입니다. |
| CRIT-11 | 낮음 | 일부 확인 | S06, S02 | 팁 카드에서 '이 단계 보기'(이동)와 '오래됨으로 표시'(공개 상태 변경)가 똑같은 파란 텍스트로 나란히 있습니다 | S06에서만 두 버튼의 모양을 구분합니다(예: 상태 바꾸기를 아이콘이 붙은 OutlinedButton으로, 또는 카드 전체를 눌러 단계로 가게 하고 'Open this step' 빼기). 되돌리기 SnackBar는 넣지 않아도 됩니다(토글이라 같은 버튼으로 되돌릴 수 있음). |
| CRIT-12 | 낮음 | 일부 확인 | S01 | S01 경로 카드에 '누르면 이동한다'는 표시(화살표·버튼)가 없고, 오른쪽 자리에 정보(단계 수)만 있습니다 | 하고 싶다면 이용 가능한 경로 카드에만 Icons.chevron_right(textSecondary)를 단계 수 옆에 둡니다. 꼭 할 일은 아닙니다. |
| CRIT-13 | 낮음 | 확인 | S05 | 다크 모드 S05 테마 선택에서 선택한 칸이 바탕 트랙보다 더 어두워 눌려 들어간(꺼진) 것처럼 보입니다 | 선택 칸 바탕을 primary 16%(c.primary.withValues(alpha: 0.16))로 바꿔 하단 메뉴 선택 알약과 맞춥니다. 언어 목록 선택 줄에도 같은 바탕을 쓰면 S05 안의 단일 선택 두 가지가 같은 모양이 됩니다. |
| CRIT-14 | 낮음 | 일부 확인 | S02 | '글자 2배 이상이면 이전·다음을 본문 끝으로' 규칙이 Android 최대 글자 크기에서도 동작하지 않아, 인계 문서와 실제 화면이 다릅니다 | handoff.md:33에 'Android 14 이상 최대 글꼴에서는 본문이 약 1.75배라 바가 고정으로 남음(screen-check.csv 참고)'을 덧붙입니다. 조건을 '본문에 남는 높이' 기준으로 바꿀지는 그다음에 정합니다. |
| CRIT-15 | 낮음 | 일부 확인 | S03 | S03에서 제목·위치를 비워 두면 'Enter 1–80 characters.'라고만 나와, 무엇을 써야 하는지 알기 어렵습니다 | 빈 칸 오류를 칸마다 따로 둡니다. 'Enter a tip title.' / 'Enter where it is (e.g. B1, next to the gates).', 한국어는 '팁 제목을 입력하세요.' / '위치를 입력하세요.'입니다. 80자 초과일 때만 '80자 이하로…'를 씁니다. |
| CRIT-16 | 낮음 | 확인 | 전체(한국어) | 한국어 문구가 '합니다'체와 '해요'체를 섞어 쓰고, 한 문장 안에서도 바뀝니다 | 이미 대부분인 '해요'체로 통일합니다. 예: '안내해요', '준비 중이에요', '팁을 올렸어요', '로그아웃했어요', '돌아와요', '인터넷에 연결되지 않았어요'. 버튼·라벨(명사형)은 그대로 둡니다. |
| DSYS-01 | 낮음 | 일부 확인 | S03, S04 | '처리 중' 상태가 '비활성' 모양을 그대로 써서 '올리는 중…' 글자가 거의 보이지 않습니다 | '처리 중' 버튼 모양을 따로 둡니다. onPressed는 null로 두어 비활성 의미(낭독)는 유지하되, 처리 중일 때만 disabledBackgroundColor=primary(불투명)와 disabledForegroundColor=onPrimary를 쓰는 별도 스타일을 넘깁니다. S03·S04 모두 '16px 진행 원 + 동작 글자(Posting…/Logging in…)' 한 방식으로 맞춥니다. design-system.json primaryButton.states의 '처리 중'에 이 색·글자 규칙을 한 줄 적습니다. 시안 CSS 수정은 선택입니다. |
| DSYS-04 | 낮음 | 확인 | 전체 | Flutter 화면이 글자 토큰(TextTheme)을 거의 쓰지 않고 크기를 숫자로 직접 씁니다 | 자주 쓰는 조합을 이름 붙은 스타일로 만듭니다(AppText.caption, small, routeName, stepNumber, sign, statusTitle 또는 TextTheme의 bodySmall·labelSmall·titleSmall 등에 연결). 화면에서는 Theme.of(context).textTheme.x.copyWith(color: …)만 쓰고, 'small'을 13과 14 중 하나로 정해 통일합니다. flutter analyze용 lint나 grep 검사로 'fontSize: [0-9]'가 screens/widgets에 새로 생기지 않게 막습니다. |
| DSYS-06 | 낮음 | 일부 확인 | S02, S05 | Flutter에서 고친 값이 시안·tokens.json에 되돌려 적히지 않아, 4곳 중 어느 것이 기준인지 알 수 없습니다 | handoff.md '시안과 다르게 둔 것' 표에 빠진 '안내 줄 13→14' 한 줄을 추가합니다. 공식 출처인 design-system.json에 이번 변경 세 가지(테마 선택 표시, 역할 라벨 14 본문색, signEn 21 불투명)를 반영합니다. 시안 CSS는 고치지 않아도 되고, 고친다면 선택 사항입니다. tokens.json은 대상이 아닙니다. |
| DSYS-07 | 낮음 | 일부 확인 | S02, S05, S06 | 링크 색이 일반열차 경로색(routeLocal)을 빌려 써서, 직통열차 화면에 파란 버튼이 섞입니다 | colors/colorsDark에 link 키를 따로 두되, 값은 지금 파랑(밝게 #0B6FA8, 어둡게 #5CB8F0)을 그대로 씁니다. 토큰 역할만 분리하고 보이는 색은 바꾸지 않습니다. app_colors.dart의 link getter를 이 키로 바꾸고, design-system.json:236 규칙에 'link는 글자 링크 전용'을 적습니다. primary(남색)로 바꾸는 안은 본문과 구별이 안 되므로 쓰지 않습니다. |
| DSYS-08 | 낮음 | 일부 확인 | S03 확인창 | 확인창 제목이 완료 화면용 headlineSmall(26)을 물려받아 상단 바 제목보다 큽니다 | dialogTheme에 titleTextStyle(19~20/700, textPrimary)과 contentTextStyle(bodyMedium, textSecondary)을 지정합니다. 완료 제목은 step_guide_screen.dart:308에서만 쓰는 이름 붙은 스타일로 분리하고 headlineSmall은 되돌리거나 그대로 둡니다. 모서리 18은 상수로 만듭니다. 이유는 '위계'가 아니라 '토큰 한 개를 두 용도로 쓴 부작용과 시안 불일치'로 적습니다. |
| DSYS-09 | 낮음 | 확인 | S02(어둡게) | 어두운 테마의 표지판 칩 바탕이 화면 바탕과 거의 같아(1.05:1) 칩 모양이 사라집니다(4차 VIS-03 남아 있음) | 칩 전용 토큰 signChip/onSignChip을 따로 둡니다. 예: 어둡게 #3B66AB 바탕(바탕 대비 3.05:1, 흰 글자 5.71:1). 또는 칩에 2px outline(#7D8BA5, 5.08:1) 테두리를 줍니다. 상단 바는 signage를 그대로 쓸 수 있습니다. |
| DSYS-10 | 낮음 | 확인 | S02 1단계 | 표지판 칩에 '현재 위치'와 '찾을 표지판'의 모양 차이가 없습니다 | SignChip에 variant(here/find)를 둡니다. find는 지금처럼 signage 채움, here는 surfaceContainer 바탕+signage 2px 테두리+본문색 글자로 합니다. 같은 규칙을 DS components.signChip과 시안 CSS(.sign.here)에 적습니다. 칩 문구는 결정 3대로 둡니다. |
| DSYS-11 | 낮음 | 확인 | 전체 | 간격 토큰이 있는데도 화면 코드에 간격 숫자가 73건 있고, AppSpace.card는 카드 안쪽 여백에 한 번도 쓰이지 않습니다 | AppSpace에 gutter(10), cardInline(14), xs(4), sm(6/8)을 추가하고 DS spacing에도 같은 이름으로 적습니다. 카드·알림·요약 줄의 안쪽 여백은 EdgeInsets.symmetric(horizontal: AppSpace.cardInline, vertical: AppSpace.card) 한 상수로 묶습니다. |
| DSYS-12 | 낮음 | 확인 | 전체 | 모서리 토큰이 있는데도 숫자 모서리가 13건 있고, AppRadius.button은 한 번만 쓰입니다 | 용도 이름이 아닌 크기 이름으로 바꾸거나 둘 다 둡니다(radius.sm=10, md=12, lg=14, xl=18, pill=999). 칩·단계 목록은 sm, 팁 카드·알림·설정 칸·하단 알림은 md, 경로 카드·사진은 lg, 확인창은 xl로 정리하고 숫자를 모두 상수로 바꿉니다. |
| DSYS-14 | 낮음 | 일부 확인 | 전체 / 토큰 4곳 | 같은 색을 4개 출처가 서로 다른 이름 체계로 부릅니다 | DS tokenEvidence에 빠진 색 10개의 시안 CSS 이름 대응(surfaceContainer=--surface-2, error=--err, statusText=--ok, statusSurface=--ok-soft, warningText=--warn, warningSurface=--warn-soft, errorSurface=--err-soft, onPrimary=--on-cta, onSignage=--on-navy, errorBorder=--err)을 추가하는 것으로 충분합니다. 시안 CSS 이름 바꾸기와 Flutter 클래스 이름 바꾸기는 선택 사항이고, tokens.json은 대상에서 뺍니다. |
| DSYS-15 | 낮음 | 확인 | 전체 | 'primary', 'chip', 배지처럼 한 이름이 여러 뜻으로 쓰이거나, 한 컴포넌트에 이름이 여러 개입니다 | 컴포넌트 이름표를 하나로 정합니다(primaryButton / routeButton / ghostButton / textButton, statusBadge, signChip, routeCard, tipCard). 시안 CSS는 .btn.route·.btn.primary·.badge 하나로, Flutter는 Pill→StatusBadge로 맞춥니다. 모서리 토큰 chip은 pill로 바꿔 '표지판 칩'과 헷갈리지 않게 합니다. |
| DSYS-16 | 낮음 | 일부 확인 | S01, S02, S06 | 배지 변형이 토큰으로 정의되지 않아 '준비 중'과 '오래됨'이 똑같이 보이고, '예시'는 글자색을 바탕으로 씁니다 | '준비 중'은 DS:185 규칙대로 warning 색을 유지합니다. 예시 배지만 이름 붙은 토큰(예: badgeExampleSurface=지금 textSecondary 값, badgeExampleText=surface 값, 대비 밝게 7.14·어둡게 8.52)으로 분리합니다. DS statusBadge의 예시 설명을 '테두리만'에서 '채움'으로 고칩니다(DSYS-03과 함께 처리). |
| DSYS-17 | 낮음 | 확인 | S05, 전체 | 눌림·초점·선택 상태의 토큰이 없어, 어두운 테마에서 선택된 칸이 오히려 들어가 보입니다 | DS에 focusRing(경로와 무관한 primary, 2~3px), pressedOverlay(textPrimary 8~12%), selectedSurface(밝게 surface, 어둡게 surfaceContainer보다 밝은 값 예: #24324A)를 추가합니다. Flutter는 ThemeData.focusColor·splashColor·FilledButton overlayColor로 한곳에서 연결합니다. |
| DSYS-18 | 낮음 | 확인 | 전체 | 정의만 있고 쓰이지 않는 토큰·변형이 있고, 쓰이는 곳도 엉뚱한 토큰을 씁니다 | Flutter에서 쓰이지 않는 NoticeKind.info와 margin 0 줄을 지웁니다. 시안의 --express-soft·--local-soft는 쓸 계획이 없으면 그대로 두거나 지워도 되고(끝난 시안이라 선택), tokens.json은 대상이 아닙니다. |
| HAND-08 | 낮음 | 일부 확인 | S02 | 큰 글자 조건(DEC-07)이 명세에는 없습니다. Flutter 문서는 '글자 2배면 이전·다음을 본문 끝으로'라고 하지만, 2배 캡처에서는 바가 그대로 하단에 고정되어 있습니다. | 먼저 handoff.md:33을 실제 동작으로 고칩니다: 'Android 200%에서도 바는 한 줄이라 하단 고정 유지, 본문 끝 이동은 실효 2배 이상일 때만'. 문턱을 바꿀지는 사용자가 정합니다. 바꾸지 않는다면 바가 두 줄 이상으로 접힐 때만 본문 끝으로 옮기는 기준이 결정 #6과 맞습니다. 두 문턱은 같은 기준 글자(16)로 맞추고, S02 명세 states에 '큰 글자' 행을 추가합니다. |
| HAND-18 | 낮음 | 확인 | 전체 | Flutter handoff.md의 '시안과 다르게 둔 것' 표와 [추가] 문구 목록에 빠진 항목이 있고, 디자인 문서가 낡았다는 경고가 없습니다. | handoff.md:18-35 표에 위 다섯 행을 이유와 함께 추가합니다(언어 기억: 재실행 때 다시 고르지 않게, 밀기 완료 막음: 4차 REG-10, 1:1 바: DEC-09, 눈 버튼: A11Y-10, 14: 가독성). :38 [추가] 목록에 출처 네 키를 넣고 app_strings.dart:129-132에도 [추가]를 표시합니다. :11 뒤에 '디자인 문서는 DEC-01이 남아 있어 시안 v03과 이 표가 우선'이라는 한 줄을 넣습니다. |

### B. 디자인 문서 (문서 갱신 작업에서 처리) (20건)

| ID | 심각도 | 판정 | 화면 | 문제 | 고칠 방법 |
| --- | --- | --- | --- | --- | --- |
| HAND-01 | 중간 | 일부 확인 | S01·S02·S05 | 언어·테마를 바꾸는 곳이 문서마다 확정 결정과 반대로 적혀 있습니다(언어는 S01·S02 어디서나, 테마는 S01). | 권고는 그대로 따르되 design-system.json:18은 고쳐 쓰지 않습니다. 그 행 끝에 '(v03에서 S05 설정으로 옮김)'만 덧붙입니다. 현재 규칙인 235행은 '설정(S05) 화면 테마'로 바꾸고, 231행의 '(언어 전환 버튼 포함)'은 지웁니다. R03 문구는 서버 requirements.md:18에 이미 고쳐진 문장을 그대로 가져와 세 폴더(chapter05-ai, 앱 docs, 서버 docs의 사본)를 맞춥니다. |
| HAND-02 | 중간 | 일부 확인 | S04·S05·S06·하단 메뉴 | S04 로그인·S05 설정·S06 내 팁과 하단 메뉴가 명세·흐름표·요구사항표 어디에도 없습니다. | 10항목 명세 세 개를 새로 쓰기보다, 서버 functional-spec.md의 F06·F08·F09와 requirements.md의 R07·R08을 5장 ui-requirements.csv와 앱 docs로 옮기거나 그 위치를 ui-handoff.md '읽을 파일'에 적습니다. screen-flow.csv에는 빠진 흐름만 행으로 추가합니다: 메뉴 이동, S05/S06→S04→복귀, 로그아웃, S06 '이 단계 보기'→S02, S01 이어 보기·처음부터·완료 경로. ui-handoff.md:25는 '여섯 화면'으로 고칩니다. |
| HAND-04 | 중간 | 확인 | S02·S03 | S02·S03 화면명세가 v01 내용이라 v03의 요소·상태·문구가 빠지거나 틀립니다. | S02-screen-spec.md:14 elements에 역할 라벨, 4:3 사진(사진 없으면 같은 칸 자리표시와 칸 아래 설명), 엘리베이터 줄, 전체 단계 목록, 하단 고정 이전·다음(1:1.4)을 넣습니다. 15·17행에는 마지막 버튼 '승강장에 왔어요', 완료 화면 버튼 '경로 목록으로'(보조)·'n단계 다시 보기'(주요), 팁 상태 6가지(불러오는 중·없음·못 불러옴·저장 중·못 바꿈·권한 없음+다시 로그인), 지난 팁 접기, 배지 '작성자 확인 · 날짜'를 적습니다. S03-screen-spec.md:14에서 사진 칸을 빼고 '미정이라 숨김'으로 적습니다. 15행은 '작성자 확인 · 오늘 날짜'로 고치고, 17행 states에 버리기 확인창(초점·뒤로·바깥 누름=계속 쓰기)과 로그인 만료(값 유지+다시 로그인)를 추가합니다. |
| HAND-05 | 중간 | 확인 | 전체 | design-system.json의 components가 옛 결정을 담고 있고, v03에 생긴 부품(표지판 칩, 진행 표시, 하단 메뉴, 확인창)이 없습니다. | design-system.json:134의 behavior를 '마지막 단계 다음 → 승강장에 왔어요, 완료 화면 주요 버튼 n단계 다시 보기'로 고칩니다. 176은 'T2는 준비 중 배지, 누르면 하단 알림만', 182-185 labels는 ['작성자 확인 · {날짜}','작성자가 오래됨 표시 · {날짜}'], 예시 배지는 '채움(textSecondary 바탕·surface 글자) Example'로 바꿉니다. 200은 'Connect to the airport's free Wi-Fi, then try again', 207은 '작성자 확인'으로 바꿉니다. components에 signChip(역할 라벨 14 본문색, 칩 21, 영어 불투명), stepProgress, photoPlaceholder, bottomNav, confirmDialog를 추가합니다. tokens의 키 구조는 9장 도구가 읽으므로 바꾸지 말고(000_읽는순서.md:12), 새 글자 크기는 components에 적거나 도구가 새 키를 받는지 먼저 확인합니다. |
| HAND-11 | 중간 | 확인 | S01·S02·S03·S04·S06 | 느린 연결과 시간 초과 규칙이 어디에도 없습니다. 온라인 전용인데 약한 공항 와이파이에서 자리표시가 끝없이 돌 수 있습니다. | ui-handoff.md API 표에 '시간 초과' 열을 넣습니다. 예: 읽기 10초, 쓰기 15초. 넘으면 읽기는 offline/loadError + 다시 시도, S03은 값 유지 + 다시 시도입니다. 공통 규칙으로 '5초가 지나도 응답이 없으면 불러오는 중 문구 아래에 "연결이 느려요. 공항 무료 와이파이를 확인하세요" 한 줄 추가'를 적습니다. Flutter handoff.md 3절 '연결할 때 주의'에는 ApiTransport에 같은 시간 초과 값을 넣을 것을 적습니다. |
| A11Y-14 | 낮음 | 일부 확인 | component-rules.md, design-system.json | 디자인 문서에 접근성 규칙이 빠졌거나 다른 앱의 규칙이 남아 있습니다 | component-rules.md는 이미 수업 예제로 표시되어 있으니 그대로 둡니다. 9장 인계 목록에서 빠져 있는지만 확인합니다. design-system.json flutterAdaptations.rules에만 두 줄을 더합니다. ① 키보드 초점 표시는 두께 3px, 바탕과 3:1 이상. ② 오류 알림은 사용자가 닫을 때까지 남김. 큰 글자 판단 기준은 A11Y-01에서 (가)/(나) 중 무엇을 고르는지에 따라 적습니다. |
| CRIT-17 | 낮음 | 확인 | design-system.json, screen-flow.csv, S02-screen-spec.md | 디자인 기준 문서(DS·흐름표·S02 명세)에 확정된 결정과 다른 옛 내용이 아직 남아 있습니다 | DS components의 해당 behavior 문장과 flutterAdaptations 규칙 235행을 v03·앱 기준으로 고칩니다. 흐름표에 S05(테마·언어·로그인·로그아웃)와 S06(이 단계 보기·상태 바꾸기) 행을 넣고 6·21행을 고칩니다. S02 명세 action·states의 마지막 단계 문구도 맞춥니다. 여행객에게 직접 영향은 없지만 다음 장 작업이 옛 문서를 따라 결정을 되돌릴 위험이 있습니다. |
| DSYS-02 | 낮음 | 일부 확인 | 전체 / component-rules.md, design-system.json | 컴포넌트 명세 문서가 없습니다: component-rules.md는 분실물센터 예제 그대로이고, design-system.json에는 컴포넌트 6종이 빠졌습니다 | 둘 중 하나를 고릅니다. (가) ui-handoff.md:21대로 component-rules.md를 '수업 예제, 이 앱에서는 쓰지 않음'으로 표시해 제외합니다. (나) 이 앱 기준으로 짧게 다시 씁니다. 행은 주 버튼·경로색 버튼·고스트·텍스트 버튼, 입력칸, 표지판 칩, 배지, 팁 카드, 경로 카드, 하단 메뉴, 하단 고정 바, 알림, 확인창, 설정 선택칸으로 두고, 지금 Flutter 구현 값을 그대로 옮겨 적습니다. 어느 쪽이든 design-system.json components에 빠진 컴포넌트 키 이름과 사용하는 토큰만 추가하면 충분합니다. |
| DSYS-03 | 낮음 | 일부 확인 | S01, S02, S05 / design-system.json | design-system.json의 컴포넌트 정의가 확정된 결정·Flutter·시안과 서로 다릅니다 | statusBadge 문구와 변형(checked/outdated/soon/example 채움)을 결정대로 고치고, feedbackBanner의 '확인됨'을 '작성자 확인 · 날짜'로 바꿉니다. 235행의 테마 위치를 S05로 고칩니다. secondaryButton은 ghostButton(typography.button 16)과 textButton(typography.label 14) 두 항목으로 나눕니다. statusMessage 제목은 20으로, 알림 시간은 Flutter 값(3초) 하나로 정해 DS에 적습니다. |
| DSYS-05 | 낮음 | 확인 | S01, S02, 확인창 | design-system.json 글자 토큰에 표지판 칩·진행 숫자·경로 이름 등 7가지가 없습니다(4차 DEC-05 미반영) | design-system.json typography에 doneTitle(26), stepNumber(24), routeName(18), signKo(21/700), signEn(21/600, 불투명), appBarTitle(21), dialogTitle(19), eyebrow(12/600/0.1em)를 추가합니다. Flutter에서 바꾼 값(본문·안내 줄 13→14 등)은 flutterAdaptations.typography에 적습니다. tokens.json은 프로젝트 파일이 아니므로 대상에서 뺍니다. |
| DSYS-13 | 낮음 | 일부 확인 | design-system.json | DS의 간격·모서리·크기 토큰이 빠졌거나 같은 값에 이름이 두 개입니다 | spacing에 gutter(10), sizes에 buttonHeight(52)·menuItemMinHeight(60)·routeCardMinHeight(88)·optionRowMinHeight(56)를 추가합니다. inputHeight(CSS 값)와 flutterAdaptations.sizes.inputMinHeight(Flutter 값)는 수업 틀대로 둘 다 두고, minimumTap은 누름 영역 기준으로 따로 둡니다. hero는 card와 같다고 tokenEvidence에 적거나 지웁니다. NavigationBar 높이 68은 flutterAdaptations에 이유와 함께 적습니다. |
| HAND-03 | 낮음 | 확인 | 전체 | 결정 기록 문서에 새로 확정한 결정(설정에서만 바꾸기, 지구본 제거, 하단 메뉴, 눈 아이콘, S06)이 없고, '지구본 유지' 문구가 남아 있습니다. | ui-validation-decisions.md의 '사용자 결정' 표에 D5~D10을 추가합니다: 테마·언어는 S05에서만, 지구본 버튼 폐기(4차 VIS-09 기각 사유 무효), 하단 메뉴는 S01/S06/S05에만, 비밀번호 눈 아이콘 위치, S06 내 팁 신설, 회원가입은 강사 확인 대기, 폰 테두리는 미리보기 틀. ui-verify-round4-v03.md 맨 위에 '5행·87행의 지구본 관련 내용은 D6로 폐기됨' 한 줄을 넣습니다. src:291 패널 문구는 '지구본 버튼 제거, 언어는 설정에서만'으로 바꿉니다. |
| HAND-06 | 낮음 | 확인 | 전체 | 인계 문서들이 아직 v01 시안 파일을 기준으로 가리킵니다. 같은 문서가 두 폴더에 사본으로 있어 따로 놀 수 있습니다. | design-system.json:7·9·244-247을 docs/screens/ICN-subway-steps-v03.src.html과 그 sha256으로 바꾸고, revision에 v03 날짜를 남깁니다. ui-handoff.md:18 '선택한 시안' 행과 78행 복사 지시도 v03.src.html로, S02·S03 명세 3·5행도 v03로 고칩니다. ui-handoff.md '읽을 파일' 아래에 '원본은 chapter05-ai/docs, 앱 docs는 사본이며 고치면 둘 다 복사' 규칙을 한 줄 넣습니다. |
| HAND-07 | 낮음 | 일부 확인 | 전체 | component-rules.md가 아직 수업 예제 '교내 분실물센터' 규칙이라 이 앱과 맞지 않습니다. | 먼저 S02·S03 명세 25행과 000_읽는순서.md:6에서 component-rules.md를 가리키는 부분을 지우거나 '수업 예제, 읽지 않음'으로 표시합니다. 이 앱 기준으로 다시 쓰는 일은 선택이고, 다시 쓴다면 권고한 행 구성(주요·경로색·보조 버튼, #6E7C97 입력칸 등)을 따릅니다. |
| HAND-10 | 낮음 | 일부 확인 | S02·S04·S05·S06 | 화면별 상태(불러오는 중·빈 목록·오류·로그인 필요) 명세가 S01에만 있어, 나머지 화면의 상태는 앱이 임의로 정했고 화면마다 다릅니다. | '화면 × 상태' 표 권고는 유지합니다. 우선 할 일은 두 가지입니다. S06 불러오는 중에 'Loading your tips…' 같은 한 줄(live region)을 넣어 다른 화면과 맞춥니다. design-system.json:202의 '7장에서 정한다'를 loadError 문구로 확정합니다. |
| HAND-12 | 낮음 | 확인 | S02 | 단계를 옮길 때 초점과 낭독 방식이 명세에 없어, 시안과 앱이 서로 다르게 동작합니다. | S02-screen-spec.md에 '초점·낭독' 행을 추가합니다. '이전·다음·사진 밀기로 단계를 옮기면 초점은 누른 버튼에 남고, "Step n of N: 제목. 찾을 표지판: 칩 글자"를 한 번 낭독한다. 완료 화면에 들어갈 때와 처음 열 때만 제목에 초점. 읽는 순서는 진행 → 사진 → 역할 라벨+칩 → 제목 → 안내 → 엘리베이터 → 팁 → 하단 바.' 시안 go()와 앱 semanticsLabel을 이 규칙에 맞춥니다. |
| HAND-13 | 낮음 | 일부 확인 | 하단 메뉴·S01·S05·S06 | 하단 메뉴의 동작(다시 누름, 시스템 뒤로, 탭을 오갈 때 상태 유지, S06에서 연 S02의 뒤로)이 정해져 있지 않습니다. | bottomNav 규칙을 문서에 적을 때는 지금 앱 동작(같은 탭은 무시 또는 맨 위로, Android 뒤로는 경로 탭에서 앱 종료, S06 '이 단계 보기' 뒤로는 S01이고 그 이유는 흐름표 11행)을 그대로 적습니다. 상태 유지는 S01 스크롤 위치에만 적용하고, S06 목록은 들어갈 때마다 다시 읽는다고 적습니다. |
| HAND-14 | 낮음 | 확인 | S01·S02·S03·S06 | 이미 결정된 것이 문서에는 '미정'으로 남아 있고, ui-handoff.md API 표에 단계 조회·내 팁 API가 없습니다. | S02-screen-spec.md:19의 3·5번과 S03-screen-spec.md:19의 2·4번은 '결정됨(근거: v03 #7·#9·#1, 앱 동작)'으로 옮기고, S03의 1번은 '숨김 유지'로 적습니다. ui-handoff.md:42-43은 '확정한 것'으로 옮기고, 66-72 표에 'S02 단계 보기 GET /api/routes/{route}/steps', 'S06 내 팁 GET /api/me/tips' 행을 추가하고 S01 행의 '(미정)'은 지웁니다. design-system.json:146과 screen-flow.csv:21의 '미정'은 '버리기/계속 쓰기 확인'으로, ui-validation-decisions.md:32는 '코드 포인트, 앞뒤 공백 제외로 확정'으로 고칩니다. |
| HAND-17 | 낮음 | 확인 | 전체 | 애니메이션·전환·알림 시간 규칙이 없어, DS·시안·앱의 값이 서로 다릅니다. | design-system.json components에 motion 항목을 추가합니다: 하단 알림 3초(DS:205 수정), 화면 전환은 플랫폼 기본, 사진 넘김 250ms easeOut, 새 팁 스크롤 300ms와 강조 1.8초, 자리표시 반짝임 여부. '동작 줄이기(disableAnimations)면 모든 이동은 바로 점프, 반짝임 없음'도 적습니다. 앱은 ensureVisible도 disableAnimations를 보게 맞춥니다. |
| HAND-21 | 낮음 | 확인 | S03·S04 | 키보드가 올라왔을 때 S03·S04의 버튼 위치와 동작 규칙이 없습니다. | S03-screen-spec.md states에 '키보드' 행을 추가합니다: 키보드 완료/다음으로 제목→위치→메모 이동, 메모는 줄바꿈, 버튼은 고정하지 않고 스크롤로 닿음, 오류가 나면 첫 오류 칸에 초점과 스크롤. 23행의 '확인하지 못한 것'은 지웁니다. S04 명세(HAND-02에서 새로 쓰는 것)에도 '비밀번호 칸에서 완료 = 로그인'을 적습니다. |

### C. 시안 v03 (시안 고정 결정으로 고치지 않음) (5건)

| ID | 심각도 | 판정 | 화면 | 문제 | 고칠 방법 |
| --- | --- | --- | --- | --- | --- |
| A11Y-13 | 낮음 | 확인 | S02·S05 | 시안의 사진 출처와 S05 출처 문장에 lang이 없습니다(4차 DEC-08이 시안에는 반영되지 않음) | 시안을 디자인 기준으로 남길 것이라면 CREDIT과 S05 출처를 rich()({ko/…})로 감싸고, S05 문장을 T 사전 키로 옮겨 Flutter와 맞춥니다. |
| HAND-09 | 낮음 | 일부 확인 | S01·S02·S04·S05 | 디자인 기준인 v03 시안이 확정 결정과 앱보다 뒤처져, 시안을 보고 다시 만들면 고친 문제가 되돌아옵니다. | 시안 수정은 그대로 권합니다(T 사전 문구, reviewLast 함수, renderS04 목적별 제목, 라이선스 주소, 완료 dock 1fr 1fr, 796행 S.step < n-1, 선택 표시). 바로 고치지 못하면 새 표를 만들지 말고, handoff.md:16-35 표에 빠진 세 개(S04 목적별 제목, 1:1 완료 바, 마지막 단계 밀기)를 더하고 ui-handoff.md에서 그 표를 가리킵니다. |
| HAND-15 | 낮음 | 확인 | S03 | 메모 글자 수를 세는 방법이 시안과 앱에서 다르고, S03 명세에는 이 규칙이 없습니다. | 어느 쪽이 맞는지: 앱입니다(서버 계약). S03-screen-spec.md:16에 '세 칸 모두 앞뒤 공백을 뺀 뒤 유니코드 코드 포인트로 센다. 칸 아래 n/80·n/150도 같은 기준'을 추가하고, design-system.json:161 textField.behavior도 같게 고칩니다. 시안 src:543·659는 cp(v.trim())로 고칩니다. |
| HAND-19 | 낮음 | 확인 | S02 | 시안 캡처(v03-shots)가 마지막 src보다 먼저 찍혀, 고친 문제가 '디자인'처럼 보입니다. | src를 확정한 뒤 v03.e2e.js로 v03-shots를 다시 찍습니다. 찍기 전 진행·알림을 초기화하고 동작 줄이기를 켭니다(S01-light.png는 진입 애니메이션 중에 찍혀 흐리게 나옴). ui-handoff.md '선택한 시안' 행에 캡처 날짜와 src 날짜를 함께 적습니다. icn_subway_app/docs/screens/v03-shots 사본도 바꿉니다. |
| HAND-20 | 낮음 | 확인 | S02 | 시안의 1단계 안내에서 '공항철도'가 좁은 왼쪽 칸에 들어가 글자가 세로로 쪼개집니다. 앱은 정상입니다. | 어느 쪽이 맞는지: 앱입니다. 시안 src:527을 '<li><span>${rich(l)}</span></li>'로 바꿔 글이 한 칸에 들어가게 하고, 다시 찍은 캡처로 확인합니다. |

## 기각된 지적 (5건)

- **COPY-21** 설정 라벨 '시스템'·'정보'가 여행객에게 뜻이 흐리다 — 검토자 스스로 confidence를 low로 매겼고, 혼동을 보여 주는 근거가 없다. 'System'/'시스템'은 Android·Flutter(ThemeMode.system)에서 테마 선택지로 흔히 쓰는 표준 낱말이다. 화면에서도 '밝게/어둡게' 옆에 함께 놓여 뜻이 드러난다(S05-settings-ko-dark.png). 'About'/'정보'도 설정 화면의 표준 항목 이름이다. 주 사용자는 영어 화면을 쓰는 외국인 여행객이고, 이 화면은 이동 중에 볼 일이 거의 없어 여행객 상황에 비춰 봐도 문제가 아니다.
- **HAND-16** 긴 글(제목·위치 80자, 메모 150자, 서버가 주는 단계 문구) 표시 규칙이 없습니다. — '긴 글 표시 규칙이 없다'는 주장이 핵심인데, design-system.json:233에 '글자 확대를 막거나 고정 높이에 잘라 넣지 않는다'는 규칙이 이미 있습니다. 시안 .tip(src:156-161)과 앱 TipCard(실제 줄은 tip_card.dart:89·93·95, 인용한 413·417·419는 없는 줄)는 둘 다 이 규칙대로 자르지 않습니다. 시안·앱·DS가 서로 맞으므로 인계 불일치가 없습니다. '팁 영역이 매우 길어진다'는 추측입니다. 오래된 팁은 이미 접히고(step_guide_screen.dart:443-455), 길이 경계 시험도 하지 않았습니다. 캡처에서 본 S03 요약 줄 두 줄 꺾임과 칩 영어 3줄은 자르지 않고 줄바꿈하는 올바른 동작입니다. 4차가 DEC-07의 '규칙이 어디에도 없다'를 DS 일반 규칙을 근거로 과장이라 기각한 것과 같은 경우입니다.
- **A11Y-09** 단계를 넘길 때 '팁 불러오는 중' 공지와 배지 공지가 단계 제목 공지와 겹칠 수 있습니다 — 코드 사실(단계를 옮기면 제목 live region이 바뀌고 'Loading tips…' live region이 새로 나타남, 배지마다 liveRegion: true)은 맞습니다. 하지만 '공지가 끊기거나 묻힌다'는 핵심 피해는 지적 스스로 TalkBack에서 확인하지 않았다고 밝혔고(confidence low), 캡처나 기록 등 다른 증거도 없습니다. 게다가 '배지 liveRegion을 빼라'는 권고는 4차 검증이 통과시킨 A11Y-02의 권고('배지에 Semantics(liveRegion)를 줍니다')를 그대로 뒤집습니다. 새 증거 없이 지난 판단을 뒤집으므로 기각합니다. 실기기 TalkBack으로 단계 넘김 낭독을 한 번 확인하는 일은 handoff.md:86의 미확인 항목으로 이미 남아 있습니다.
- **A11Y-11** 같은 이름의 버튼이 카드마다 반복되고, '→' 기호가 그대로 읽힐 수 있습니다 — S06-my-tips-light.png에서 카드마다 'Open this step'과 'Mark as …'가 반복되는 것은 맞습니다. 하지만 WCAG 2.4.6은 라벨이 목적을 설명하라는 기준이지 서로 달라야 한다는 기준이 아닙니다. 'Open this step'은 목적을 설명하고, 지적 스스로 2.4.4는 맥락 안에서 통과한다고 인정합니다. 카드 안에서는 위치 줄 → 제목 → 배지 → 버튼 순으로 읽혀 맥락도 분명합니다. 그래서 AA 미충족이 아닙니다. '→'를 TalkBack이 '오른쪽 화살표'로 읽는다는 부분은 지적 스스로 추측이라고 적었고 확인 증거가 없습니다. 4차 A11Y-05에서 같은 종류의 화살표 추측을 이미 '낭독 다듬기'로 미뤘습니다.
- **A11Y-12** 설정에서 들어간 로그인 화면에서 'Log in'이 제목으로 두 번 읽힙니다 — general 목적일 때 AppBar 제목 'Log in'(login_screen.dart:120)과 본문 FocusHeading 'Log in'(124행)이 겹치는 것은 맞습니다. 하지만 같은 문구의 제목 두 개는 2.4.6·1.3.1 위반이 아닙니다. 두 제목 모두 주제를 정확히 설명합니다. 그 아래에는 목적을 알리는 안내 줄 loginLeadGeneral('You don't need an account to follow the steps.')도 있습니다. 게다가 지금 문구는 4차 REG-08이 통과시킨 권고('설정에서 들어오면 제목을 Log in/로그인으로 바꾸고 단계 복귀 문장을 뺀다')를 그대로 따른 결과입니다. 문구를 다듬는 정도의 선택 사항이라 AA 지적으로는 기각합니다.

## 관점별 잘 된 점

**COPY**

- 문구가 lib/l10n/app_strings.dart 한 곳의 추상 클래스에 모여 있어 en·ko가 같은 키를 빠짐없이 갖고, 시안에 없던 문구는 [추가]로 표시하고 handoff.md에 목록을 남겼다.
- 버리기 확인창이 모범적이다: 행동이 분명한 질문 제목('Discard this tip?'), 결과 설명('What you typed will be lost.'), 행동 이름 버튼('Discard'/'Keep writing', '버리기'/'계속 쓰기'), 기본 초점은 안전한 쪽(add_tip_screen.dart:153, S03-discard-confirm-light.png).
- 마지막 단계 CTA 'I'm on the platform'/'승강장에 왔어요'와 완료 제목 'You're at the platform'/'승강장에 도착했어요'가 맞물려, 누른 결과가 라벨과 같다(S02-step5-light.png → S02-done-light.png). 완료 안내는 결정대로 승차권 보관 한 문장이다.
- 실패 문구 상당수가 다음 행동과 안심 문장을 함께 준다: 오프라인 'Connect to the airport's free Wi-Fi, then try again.', 팁 못 불러옴 'The steps above still work.', 올리기 실패 'What you typed is kept.', 권한 없음은 DEC-10대로 '다시 로그인' 버튼까지 둔다.
- 단계 표기와 숫자가 언어별로 자연스럽다: 'Step 3 of 5' / '5단계 중 3단계', 복수형 처리('Show 1 older tip'/'tips'), 날짜는 두 언어 모두 헷갈림 없는 YYYY-MM-DD이고 서울 시간 기준(tip.dart:100).

**DSYS**

- 색 토큰 20개×2벌(밝게·어둡게)이 design-system.json·시안 :root/다크 블록·app_colors.dart·tokens.json 4곳에서 모두 같습니다(node 대조 결과 차이 0건).
- app_colors.dart가 ThemeExtension으로 밝게·어둡게 두 벌의 키를 똑같이 두고 lerp까지 구현했습니다. 화면·위젯 코드에 Color(0x..)는 하나도 없고, 직접 쓴 색은 Colors.transparent 3건뿐입니다.
- 경로색 위 글자를 onRoute 하나로 통일해 어두운 테마의 흰 글자 대비 미달(약 2.1:1)을 막았습니다(app_theme.dart:156-161).
- 버튼·텍스트 버튼·입력칸·알림·하단 메뉴·확인창 모양을 ThemeData 한곳에서 정합니다. 최소 터치 48과 버튼 높이 52도 테마에서 강제합니다(app_theme.dart:105-125).
- 입력칸 상태가 거의 다 있습니다: 기본·초점(primary 2px)·오류·초점+오류·읽기 전용(올리는 중)·글자 수 초과 강조(labeled_field.dart, app_theme.dart:126-140).

**HAND**

- Flutter docs/handoff.md:16-35에 '시안과 다르게 둔 것' 표가 있고, 행마다 4차 지적 ID나 사용자 결정(D4·DEC-09·DEC-10·REG-07 등)을 이유로 달았습니다. 시안에 없던 문구는 app_strings.dart에 [추가]로 표시하고 handoff.md:37-38에 목록으로 모았습니다.
- 하단 메뉴는 최상위 화면에만 있다는 결정이 코드에 정확히 들어갔습니다. home_shell.dart:80-81·136-156에서 S02~S04는 셸 위에 쌓여 메뉴를 가립니다. 시안 src:615-622, DS:190과도 같습니다.
- 지구본 언어 버튼은 Flutter 상단 바(home_shell.dart:123-130)에도, 시안 상단 바(src:237-240)에도 없습니다. 언어와 테마는 S05에서만 바꿉니다(settings_screen.dart:248-290).
- 비밀번호 보이기는 두 쪽 모두 입력칸 안 오른쪽 끝 눈 아이콘입니다(src:176-182, login_screen.dart:164-171, S04-fail-light.png).
- 예시 팁은 채운 'Example' 배지와 작성자 'Sample'로 시안과 앱이 같습니다(src:164·493, tip_card.dart:342, S02-step3-tips-light.png). 상태 배지 '작성자 확인 · 날짜'도 같습니다.

**CRIT**

- 피츠: S02 이전·다음 바가 화면 아래에 고정돼 있고, '다음'이 오른쪽에 더 넓게 있어(step_guide_screen.dart:516-535, 비율 10:14) 한 손 엄지로 누르기 쉽습니다. 모든 단계 캡처에서 같은 자리입니다.
- 사진 칸을 4:3으로 고정해(step_guide_screen.dart:351) 단계를 넘겨도 표지판 칩 높이가 거의 같습니다(1단계 y≈1125, 2단계 y≈1128). 4차 VIS-06의 칩 흔들림이 사라졌습니다.
- 누름 영역: TextButton 48×48, 주요 버튼 높이 52, 하단 메뉴 68, 경로 카드 88, 언어 줄 56입니다(app_theme.dart:111·121, route_list_screen.dart:218, settings_screen.dart:235). 모두 44pt 기준을 넘습니다.
- 글자 대비를 실제 색으로 재 보니 모두 4.5:1 이상입니다. 보조 글자 7.14:1, 확인 배지 4.69:1, 오래됨 배지 5.41:1, 직통 버튼 흰 글자 5.06:1, 다크 경로 버튼 8.80/8.40:1입니다.
- 오류 예방: 작성 중 나가면 [버리기]/[계속 쓰기]를 묻고, 안전한 쪽인 '계속 쓰기'를 채운 버튼으로 강조하고 초점도 둡니다(add_tip_screen.dart:150-156). 올리는 중에는 입력칸이 읽기 전용이 됩니다. 로그인에 실패하면 아이디는 남기고 비밀번호만 비웁니다.

**A11Y**

- 글자 대비 표(밝게/어둡게, 실제 토큰으로 계산) — 모두 4.5:1 통과. 본문 textPrimary/surface 17.24/15.53, 보조 글자 textSecondary 7.14(바탕)·6.55(카드)/8.52·7.44, 링크 버튼(routeLocal) 5.45·4.99(카드)/7.95·6.94, 직통 '다음' onRoute/routeExpress 5.06/8.80, 일반 '다음' onRoute/routeLocal 5.45/8.40, 주요 버튼 onPrimary/primary 13.01/10.51, 상단 바·표지판 칩 13.01/16.57, 오류 글자 6.54(바탕)·5.68(오류 상자)/7.64·7.05, 경고·'준비 중' 배지 5.41/8.71, '작성자 확인' 배지 4.69/7.69, 'Example' 배지 7.14/8.52, 하단 알림 17.24/15.53.
- 비텍스트 대비 표 — 3:1 통과. 입력칸 테두리 outline 4.21(읽기 전용 칸 3.85)/5.08(4.43), 입력 초점 테두리 primary 13.01/9.56, 오류 테두리 6.54/7.64, 테마·언어 선택 테두리 11.92/8.35, 현재 단계 테두리(경로색) 4.63~4.99/6.94~7.27, 진행 막대 채움과 빈칸 사이 3.30~3.56/4.62~4.84, 비밀번호 눈 아이콘 7.14/8.52. 하단 메뉴 선택 표시(1.35/1.41)와 빈 진행 막대(1.53/1.72)는 낮습니다. 하지만 채운 아이콘·굵은 글자·'1/5' 숫자가 같은 정보를 함께 주어 색에만 기대지 않습니다(1.4.1).
- 터치 영역이 넉넉합니다. TextButton 최소 48×48(app_theme.dart:121), 주요·보조 버튼 높이 52, 단계 목록·테마 칸 48, 언어 줄 56, 경로 카드 88, 하단 메뉴 68, 눈 아이콘 48입니다. text_scale_test.dart에서 48 이상인지 직접 잽니다. 한 손·짐 든 상황에 맞습니다(2.5.5).
- 부분 언어 표시를 Flutter에서 제대로 넣었습니다(3.1.2). 표지판 칩(step_widgets.dart:127-140), S01 병기 줄(route_list_screen.dart:256-268), 안내 줄의 {ko/…}/{en/…}(mixed_text.dart), 사진 출처(step_photos.dart:10), S05 출처·언어 이름에 TextSpan locale이 있습니다. Flutter는 부모 locale을 자식 조각에 물려주므로(text_span.dart:408) 표시 없는 부분도 화면 언어로 읽힙니다. 4차 DEC-08이 앱에서 해결되었습니다.
- 입력 오류 처리가 좋습니다(3.3.1·3.3.2·3.3.3). 칸 아래 오류 글자와 빨간 테두리를 함께 써서 색만으로 알리지 않습니다. 첫 오류 칸으로 초점을 옮깁니다(add_tip_screen.dart:79-84, login_screen.dart). Flutter InputDecorator가 errorText를 입력칸 낭독 힌트로 붙입니다. 실패하면 아이디는 남기고 비밀번호만 비웁니다. 입력값은 지키고, '(optional)'로 선택 칸을 구분합니다. 보이는 라벨과 낭독 이름이 같고(2.5.3), autofillHints로 입력 목적을 알립니다(1.3.5).

## 10장·고도화 뒤 바뀐 점 (2026-10-21 문서 동기화)

이 점검 기록은 그대로 두고, 그 뒤 앱과 다른 문서가 바뀐 점만 적는다.

- COPY-19: forbidden 영어 문구는 이 제안 대신 10장 결정 문구로 바꿨다. 'Only the person who posted this tip can change it. If you logged in with another account, log in again. / 이 팁은 올린 사람만 바꿀 수 있어요. 다른 계정으로 로그인했다면 다시 로그인하세요.'(앱 reports/app-integration.md 6절). sessionEnded 제안은 반영하지 않았다.
- COPY-17: 버전 문구는 'Version 1.0.0 · student project / 버전 1.0.0 · 학생 실습 프로젝트'로 바꿨고, 가짜 저장소로 실행할 때만 ' · Demo data / · 시연용 데이터'를 붙인다(앱 고도화 P04, 결정 6).
