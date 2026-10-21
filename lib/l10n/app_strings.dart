import 'app_language.dart';

// 화면 문구. 시안 v03의 T 사전(en/ko)을 옮겼다. 두 언어가 같은 항목을 빠짐없이 갖도록 추상 클래스로 둔다.
// [추가] 표시는 시안에 없어 이번에 더한 문구다(서버 실패·로그인 만료 등). docs/handoff.md에 목록이 있다.
// 경로 이름·단계 안내는 서버 자료(models/route_info.dart, guide_step.dart)에 두 언어로 들어 있다.
abstract class AppStrings {
  const AppStrings();

  static AppStrings of(AppLanguage language) => language == AppLanguage.ko ? const _Ko() : const _En();

  String get app;
  String get back;
  String get backRoutes;
  String get settings;

  // S01
  String get from;
  String get seoulStationEn => 'Seoul Station';
  String get seoulStationKo => '서울역';
  String get pickRoute;
  String get scopeNote;
  String get t2;
  String get soon;
  String get t2msg; // 준비 중 경로 카드 설명·누르면 띄우는 안내(시안 T2 문구)
  String get steps;
  String get resume;
  String get restart;
  String restartFor(String route); // 낭독 이름: 어느 경로를 처음부터 하는지
  String stepsCount(int n); // 낭독 이름: 시작 전 카드의 단계 수
  String get airportRailroadKo => '공항철도';
  String get airportRailroadEn => 'AREX';
  String get loading;
  String get offline;
  String get offlineSub;
  String get loadError; // [추가] 원인을 모르는 읽기 실패
  String get empty;
  String get emptySub;
  String get retry;

  // S02
  String get loadingSteps; // [추가] 단계 목록 불러오는 중
  String stepOf(int a, int n);
  String get allSteps;
  String get hideSteps;
  String get prev;
  String get next;
  String get arrived;
  String get roleHere;
  String get roleFind;
  String get elevator;
  String elevatorAt(String where); // [추가] 서버가 엘리베이터 위치를 줄 때
  String get noPhoto;
  String get noPhotoSub;
  String get doneTitle;
  String get doneSub;
  String reviewLast(int n); // 시안의 '5' 고정 대신 단계 수를 받는다(4차 DEC-09)
  String get toList;
  String get doneLabel;
  String get tipsTitle;
  String get addTip;
  String get addTipNeedsLogin;
  String checked(String date);
  String outdated(String date);
  String get example;
  String get byYou;
  String get byTraveler;
  String get bySample;
  String get markOld;
  String get markOk;
  String get saving;
  String showOld(int n);
  String get hideOld;
  String get tipsLoading;
  String get tipsEmpty;
  String get tipsError;
  String get toggleError;
  String get forbidden; // 4차 DEC-10 문구
  String get loginAgain; // [추가] 4차 DEC-10의 다음 행동 버튼

  // S03
  String get addTipTitle;
  String get stepLabel;
  String get tTitle;
  String get tLoc;
  String get tMemo;
  String get titlePh;
  String get locPh;
  String get memoPh;
  String get submit;
  String get cancel;
  String get posting;
  String get posted;
  String get postError; // [추가] 올리기 실패(값 유지)
  String get postErrorClosed; // [추가] 화면을 떠난 뒤 올리기 실패(값 없음)
  String get sessionEnded; // [추가] 로그인이 끝나 올리지 못함(값 유지)
  String get errRequired;
  String get errLong80;
  String get errLong150;
  String get cfTitle;
  String get cfBody;
  String get cfKeep;
  String get cfDiscard;

  // S04
  String get loginTitle;
  String get loginLead;
  String get loginLeadGeneral; // [추가] 설정·내 팁에서 들어온 로그인(4차 REG-08)
  String get user;
  String get pass;
  String get login;
  String get loginFail;
  String get loginError; // [추가] 아이디·비밀번호가 아닌 이유로 실패
  String get errUser;
  String get errPass;
  String get showPw;

  // S05
  String get setAppearance;
  String get thSystem;
  String get thLight;
  String get thDark;
  String get setLanguage;
  String get setAccount;
  String loggedInAs(String user);
  String get notLoggedIn;
  String get logout;
  String get loggedOut;
  String get setCredits;
  String get creditArrivals; // 4차 DEC-08: 출처 문장을 번역 키로
  String get creditWiki;
  String get creditLicenseLink;
  String get creditOriginals;
  String get setAbout;
  String get version;

  // 하단 메뉴·S06
  String get tabRoutes;
  String get tabMyTips;
  String get tabSettings;
  String get myTipsTitle;
  String get myTipsLoggedOut;
  String get myTipsEmpty;
  String get openStep;
  String whereStep(String route, int a, int n);
}

class _En extends AppStrings {
  const _En();

  @override
  String get app => 'ICN Subway Steps';
  @override
  String get back => 'Back';
  @override
  String get backRoutes => 'Back to routes';
  @override
  String get settings => 'Settings';

  @override
  String get from => 'From T1 arrivals hall';
  @override
  String get pickRoute => 'Choose a train to Seoul Station.';
  @override
  String get scopeNote => 'We guide you from the arrivals hall until you board.';
  @override
  String get t2 => 'From T2 arrivals';
  @override
  String get soon => 'Coming soon';

  @override
  String get t2msg => 'T2 directions are coming soon.';
  @override
  String get steps => 'steps';
  @override
  String get resume => 'continue';
  @override
  String get restart => 'Start over';
  @override
  String restartFor(String route) => 'Start over: $route';
  @override
  String stepsCount(int n) => '$n steps';
  @override
  String get loading => 'Loading routes…';
  @override
  String get offline => "You're offline";
  @override
  String get offlineSub => "This guide needs the internet. Connect to the airport's free Wi-Fi, then try again.";
  @override
  String get loadError => "Couldn't load this. Try again.";
  @override
  String get empty => 'No routes yet';
  @override
  String get emptySub => "Routes will show up here once they're added.";
  @override
  String get retry => 'Try again';

  @override
  String get loadingSteps => 'Loading steps…';
  @override
  String stepOf(int a, int n) => 'Step $a of $n';
  @override
  String get allSteps => 'All steps';
  @override
  String get hideSteps => 'Hide steps';
  @override
  String get prev => 'Previous';
  @override
  String get next => 'Next';
  @override
  String get arrived => "I'm on the platform";
  @override
  String get roleHere => 'You are here';
  @override
  String get roleFind => 'Look for this sign';
  @override
  String get elevator => 'Elevator: being checked on site';

  @override
  String elevatorAt(String where) => 'Elevator: $where';
  @override
  String get noPhoto => 'Photo coming soon';
  @override
  String get noPhotoSub => 'Use the sign and steps below.';
  @override
  String get doneTitle => "You're at the platform";
  @override
  String get doneSub => 'Keep your ticket or card until you exit at Seoul Station.';
  @override
  String reviewLast(int n) => 'Step $n again';
  @override
  String get toList => 'Back to routes';
  @override
  String get doneLabel => 'done';
  @override
  String get tipsTitle => 'Tips for this step';
  @override
  String get addTip => '+ Add a tip';
  @override
  String get addTipNeedsLogin => '+ Add a tip (log in)';
  @override
  String checked(String date) => 'Checked by author · $date';
  @override
  String outdated(String date) => 'Marked out of date by author · $date';
  @override
  String get example => 'Example';
  @override
  String get byYou => 'by you';
  @override
  String get byTraveler => 'by a traveler';
  @override
  String get bySample => 'Sample';
  @override
  String get markOld => 'Mark as out of date';
  @override
  String get markOk => 'Mark as checked';
  @override
  String get saving => 'Saving…';
  @override
  String showOld(int n) => 'Show $n older tip${n > 1 ? 's' : ''}';
  @override
  String get hideOld => 'Hide older tips';
  @override
  String get tipsLoading => 'Loading tips…';
  @override
  String get tipsEmpty => 'No tips for this step yet.';
  @override
  String get tipsError => "Couldn't load tips. The steps above still work.";
  @override
  String get toggleError => "Couldn't change the status. Try again.";
  @override
  String get forbidden => "You can't change this tip right now. Log in again, then try.";
  @override
  String get loginAgain => 'Log in again';

  @override
  String get addTipTitle => 'Add a tip';
  @override
  String get stepLabel => 'Step';
  @override
  String get tTitle => 'Tip title';
  @override
  String get tLoc => 'Where exactly';
  @override
  String get tMemo => 'Details (optional)';
  @override
  String get titlePh => 'e.g. Elevator is left of the gates';
  @override
  String get locPh => 'e.g. B1, next to ticket machines';
  @override
  String get memoPh => 'Anything that would have helped you';
  @override
  String get submit => 'Post tip';
  @override
  String get cancel => 'Cancel';
  @override
  String get posting => 'Posting…';
  @override
  String get posted => 'Tip posted';
  @override
  String get postError => "Couldn't post your tip. What you typed is kept. Try again.";
  @override
  String get postErrorClosed => "Your tip couldn't be posted. Please add it again.";
  @override
  String get sessionEnded => 'Your login has ended. Log in again. What you typed is kept.';
  @override
  String get errRequired => 'Enter 1–80 characters.';
  @override
  String get errLong80 => 'Use 80 characters or fewer.';
  @override
  String get errLong150 => 'Use 150 characters or fewer.';
  @override
  String get cfTitle => 'Discard this tip?';
  @override
  String get cfBody => 'What you typed will be lost.';
  @override
  String get cfKeep => 'Keep writing';
  @override
  String get cfDiscard => 'Discard';

  @override
  String get loginTitle => 'Log in to add a tip';
  @override
  String get loginLead =>
      "You'll come straight back to the step you were on. You don't need an account to follow the steps.";
  @override
  String get loginLeadGeneral => "You don't need an account to follow the steps.";
  @override
  String get user => 'Username';
  @override
  String get pass => 'Password';
  @override
  String get login => 'Log in';
  @override
  String get loginFail => "Username or password doesn't match.";
  @override
  String get loginError => "Couldn't log in. Check your connection and try again.";
  @override
  String get errUser => 'Enter your username.';
  @override
  String get errPass => 'Enter your password.';
  @override
  String get showPw => 'Show password';

  @override
  String get setAppearance => 'Appearance';
  @override
  String get thSystem => 'System';
  @override
  String get thLight => 'Light';
  @override
  String get thDark => 'Dark';
  @override
  String get setLanguage => 'Language';
  @override
  String get setAccount => 'Account';
  @override
  String loggedInAs(String user) => 'Logged in as $user';
  @override
  String get notLoggedIn => 'Not logged in. You only need an account to add tips.';
  @override
  String get logout => 'Log out';
  @override
  String get loggedOut => 'Logged out';
  @override
  String get setCredits => 'Photo credits';
  @override
  String get creditArrivals => 'Terminal 1 arrivals: {ko|인천국제공항공사}, {ko|공공데이터포털}(data.go.kr) · {ko|공공누리 제1유형}';
  @override
  String get creditWiki => 'Express/All-stop concourse, platform 1·2: MNXANL / Wikimedia Commons · CC BY-SA 4.0';
  @override
  String get creditLicenseLink => 'License';
  @override
  String get creditOriginals => 'Original photos';
  @override
  String get setAbout => 'About';
  @override
  String get version => 'Version 1.0.0 · demo data, not connected to a server yet';

  @override
  String get tabRoutes => 'Routes';
  @override
  String get tabMyTips => 'My tips';
  @override
  String get tabSettings => 'Settings';
  @override
  String get myTipsTitle => 'My tips';
  @override
  String get myTipsLoggedOut => "Log in to see the tips you've posted. You don't need an account to follow the steps.";
  @override
  String get myTipsEmpty => "You haven't posted a tip yet. Add one from the Tips section of any step.";
  @override
  String get openStep => 'Open this step';
  @override
  String whereStep(String route, int a, int n) => '$route · Step $a of $n';
}

class _Ko extends AppStrings {
  const _Ko();

  @override
  String get app => 'ICN Subway Steps';
  @override
  String get back => '뒤로';
  @override
  String get backRoutes => '경로 목록으로';
  @override
  String get settings => '설정';

  @override
  String get from => 'T1 입국장에서 출발';
  @override
  String get pickRoute => '서울역행 열차를 고르세요.';
  @override
  String get scopeNote => '입국장에서 서울역행 열차에 탈 때까지 안내합니다.';
  @override
  String get t2 => 'T2 입국장에서 출발';
  @override
  String get soon => '준비 중';

  @override
  String get t2msg => 'T2 안내는 준비 중입니다.';
  @override
  String get steps => '단계';
  @override
  String get resume => '이어 보기';
  @override
  String get restart => '처음부터';
  @override
  String restartFor(String route) => '$route 처음부터';
  @override
  String stepsCount(int n) => '$n단계';
  @override
  String get loading => '경로를 불러오는 중…';
  @override
  String get offline => '인터넷에 연결되지 않았습니다';
  @override
  String get offlineSub => '이 안내는 인터넷이 필요해요. 공항 무료 와이파이에 연결한 뒤 다시 시도하세요.';
  @override
  String get loadError => '불러오지 못했어요. 다시 시도하세요.';
  @override
  String get empty => '아직 경로가 없습니다';
  @override
  String get emptySub => '경로가 추가되면 여기에 보입니다.';
  @override
  String get retry => '다시 시도';

  @override
  String get loadingSteps => '단계를 불러오는 중…';
  @override
  String stepOf(int a, int n) => '$n단계 중 $a단계';
  @override
  String get allSteps => '전체 단계';
  @override
  String get hideSteps => '단계 접기';
  @override
  String get prev => '이전';
  @override
  String get next => '다음';
  @override
  String get arrived => '승강장에 왔어요';
  @override
  String get roleHere => '현재 위치';
  @override
  String get roleFind => '이 표지판을 찾으세요';
  @override
  String get elevator => '엘리베이터: 현장 확인 중';

  @override
  String elevatorAt(String where) => '엘리베이터: $where';
  @override
  String get noPhoto => '사진 준비 중';
  @override
  String get noPhotoSub => '아래 표지판과 안내를 따라가세요.';
  @override
  String get doneTitle => '승강장에 도착했어요';
  @override
  String get doneSub => '서울역에서 나갈 때까지 승차권·교통카드를 보관하세요.';
  @override
  String reviewLast(int n) => '$n단계 다시 보기';
  @override
  String get toList => '경로 목록으로';
  @override
  String get doneLabel => '완료';
  @override
  String get tipsTitle => '이 단계 팁';
  @override
  String get addTip => '+ 팁 등록';
  @override
  String get addTipNeedsLogin => '+ 팁 등록 (로그인)';
  @override
  String checked(String date) => '작성자 확인 · $date';
  @override
  String outdated(String date) => '작성자가 오래됨 표시 · $date';
  @override
  String get example => '예시';
  @override
  String get byYou => '내가 올림';
  @override
  String get byTraveler => '여행객';
  @override
  String get bySample => '샘플';
  @override
  String get markOld => '정보 오래됨으로 바꾸기';
  @override
  String get markOk => '확인함으로 바꾸기';
  @override
  String get saving => '저장 중…';
  @override
  String showOld(int n) => '지난 팁 $n개 보기';
  @override
  String get hideOld => '지난 팁 접기';
  @override
  String get tipsLoading => '팁을 불러오는 중…';
  @override
  String get tipsEmpty => '이 단계에는 아직 팁이 없어요.';
  @override
  String get tipsError => '팁을 불러오지 못했어요. 위 안내는 그대로 볼 수 있어요.';
  @override
  String get toggleError => '상태를 바꾸지 못했어요. 다시 시도하세요.';
  @override
  String get forbidden => '지금은 이 팁을 바꿀 수 없어요. 다시 로그인한 뒤 시도하세요.';
  @override
  String get loginAgain => '다시 로그인';

  @override
  String get addTipTitle => '팁 등록';
  @override
  String get stepLabel => '단계';
  @override
  String get tTitle => '팁 제목';
  @override
  String get tLoc => '정확한 위치';
  @override
  String get tMemo => '메모 (선택)';
  @override
  String get titlePh => '예) 개찰구 왼쪽에 엘리베이터';
  @override
  String get locPh => '예) B1, 발매기 옆';
  @override
  String get memoPh => '처음 왔을 때 도움이 됐을 내용';
  @override
  String get submit => '팁 올리기';
  @override
  String get cancel => '취소';
  @override
  String get posting => '올리는 중…';
  @override
  String get posted => '팁을 올렸습니다';
  @override
  String get postError => '팁을 올리지 못했어요. 입력한 내용은 그대로 있어요. 다시 시도하세요.';
  @override
  String get postErrorClosed => '팁을 올리지 못했어요. 다시 등록해 주세요.';
  @override
  String get sessionEnded => '로그인이 끝났어요. 다시 로그인하세요. 입력한 내용은 그대로 있어요.';
  @override
  String get errRequired => '1~80자로 입력하세요.';
  @override
  String get errLong80 => '80자 이하로 입력하세요.';
  @override
  String get errLong150 => '150자 이하로 입력하세요.';
  @override
  String get cfTitle => '작성 중인 팁을 버릴까요?';
  @override
  String get cfBody => '입력한 내용이 사라집니다.';
  @override
  String get cfKeep => '계속 쓰기';
  @override
  String get cfDiscard => '버리기';

  @override
  String get loginTitle => '팁을 올리려면 로그인하세요';
  @override
  String get loginLead => '로그인하면 보던 단계로 바로 돌아옵니다. 길 안내는 계정 없이도 볼 수 있어요.';
  @override
  String get loginLeadGeneral => '길 안내는 계정 없이도 볼 수 있어요.';
  @override
  String get user => '아이디';
  @override
  String get pass => '비밀번호';
  @override
  String get login => '로그인';
  @override
  String get loginFail => '아이디 또는 비밀번호가 맞지 않아요.';
  @override
  String get loginError => '로그인하지 못했어요. 연결을 확인하고 다시 시도하세요.';
  @override
  String get errUser => '아이디를 입력하세요.';
  @override
  String get errPass => '비밀번호를 입력하세요.';
  @override
  String get showPw => '비밀번호 보기';

  @override
  String get setAppearance => '화면 테마';
  @override
  String get thSystem => '시스템';
  @override
  String get thLight => '밝게';
  @override
  String get thDark => '어둡게';
  @override
  String get setLanguage => '언어';
  @override
  String get setAccount => '계정';
  @override
  String loggedInAs(String user) => '$user(으)로 로그인됨';
  @override
  String get notLoggedIn => '로그인하지 않았어요. 팁을 올릴 때만 계정이 필요해요.';
  @override
  String get logout => '로그아웃';
  @override
  String get loggedOut => '로그아웃했습니다';
  @override
  String get setCredits => '사진 출처';
  @override
  String get creditArrivals => '1터미널 입국장: 인천국제공항공사, 공공데이터포털(data.go.kr) · 공공누리 제1유형';
  @override
  String get creditWiki => '직통·일반열차 대합실, 1·2번 승강장: {en|MNXANL / Wikimedia Commons} · CC BY-SA 4.0';
  @override
  String get creditLicenseLink => '라이선스';
  @override
  String get creditOriginals => '원본 사진';
  @override
  String get setAbout => '정보';
  @override
  String get version => '버전 1.0.0 · 시연용 데이터(아직 서버에 연결하지 않음)';

  @override
  String get tabRoutes => '경로';
  @override
  String get tabMyTips => '내 팁';
  @override
  String get tabSettings => '설정';
  @override
  String get myTipsTitle => '내 팁';
  @override
  String get myTipsLoggedOut => '로그인하면 내가 올린 팁을 볼 수 있어요. 길 안내는 계정 없이도 볼 수 있어요.';
  @override
  String get myTipsEmpty => '아직 올린 팁이 없어요. 각 단계의 팁 영역에서 올릴 수 있어요.';
  @override
  String get openStep => '이 단계 보기';
  @override
  String whereStep(String route, int a, int n) => '$route · $n단계 중 $a단계';
}
