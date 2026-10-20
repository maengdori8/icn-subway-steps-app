// 가짜 저장소의 처음 자료. 시안 docs/screens/ICN-subway-steps-v03.src.html의 ROUTES·tips를 서버 JSON 모양으로 옮겼다.
// 표지판 글자·안내 문구는 현장 확인 전 초안이다. 층수·승강장 위치·요금·시간을 새로 만들어 넣지 않는다.
// 예시 팁 두 건은 시연용 가상 데이터다(1번은 '예시' 배지, 2번은 student01이 올린 팁).

const _arrivalsCredit = 'Photo: {ko|인천국제공항공사} · data.go.kr · {ko|공공누리 1유형}';
const _wikiCredit = 'Photo: MNXANL / Wikimedia Commons · CC BY-SA 4.0';

const List<Map<String, dynamic>> fakeRoutesJson = [
  {
    'code': 'EXPRESS',
    'origin': 'T1',
    'name': {'en': 'Express Train', 'ko': '직통열차'},
    'summary': {'en': 'Non-stop to Seoul Station · ticket needed', 'ko': '서울역까지 무정차 · 승차권 필요'},
    'sign_ko': '직통열차',
    'sign_en': 'Express Train',
    'step_count': 5,
    'available': true,
  },
  {
    'code': 'LOCAL',
    'origin': 'T1',
    'name': {'en': 'All-stop Train', 'ko': '일반열차'},
    'summary': {'en': 'Stops at every station · T-money card', 'ko': '모든 역 정차 · 교통카드(T-money)'},
    'sign_ko': '일반열차',
    'sign_en': 'All-stop Train',
    'step_count': 5,
    'available': true,
  },
  {
    'code': 'T2',
    'origin': 'T2',
    'name': {'en': 'T2 → Seoul Station', 'ko': 'T2 → 서울역'},
    'summary': {'en': 'T2 directions are coming soon.', 'ko': 'T2 안내는 준비 중입니다.'},
    'sign_ko': null,
    'sign_en': null,
    'step_count': 0,
    'available': false,
  },
];

// 1·2단계는 두 경로가 같다.
const Map<String, dynamic> _step1 = {
  'step_no': 1,
  'role': 'HERE',
  'icon': 'PLANE',
  'sign_ko': '제1여객터미널 입국장',
  'sign_en': 'Terminal 1 Arrivals',
  'title': {'en': 'Walk out of the arrivals hall', 'ko': '입국장 밖으로 나오기'},
  'actions': {
    'en': [
      'Exit through the arrival doors with your bags.',
      'Look up for signs that say Airport Railroad ({ko|공항철도}).',
    ],
    'ko': ['짐을 찾고 도착 출구로 나옵니다.', "천장에서 '공항철도 {en|Airport Railroad}' 표지판을 찾습니다."],
  },
  'photo_url': 'assets/photos/arrivals_t1.jpg',
  'photo_credit': _arrivalsCredit,
  'elevator_status': 'CHECKING',
};

const Map<String, dynamic> _step2 = {
  'step_no': 2,
  'role': 'FIND',
  'icon': 'ESCALATOR',
  'sign_ko': '교통센터 · 공항철도',
  'sign_en': 'Transportation Center · Airport Railroad',
  'title': {'en': 'Go down to the Transportation Center', 'ko': '교통센터로 내려가기'},
  'actions': {
    'en': [
      'Follow the Airport Railroad signs to the Transportation Center.',
      'Take the escalator or elevator down one floor.',
    ],
    'ko': ['공항철도 표지판을 따라 교통센터로 갑니다.', '에스컬레이터나 엘리베이터로 한 층 내려갑니다.'],
  },
  'photo_url': null,
  'photo_credit': null,
  'elevator_status': 'CHECKING',
};

const Map<String, List<Map<String, dynamic>>> fakeStepsJson = {
  'EXPRESS': [
    _step1,
    _step2,
    {
      'step_no': 3,
      'role': 'FIND',
      'icon': 'TRAIN',
      'sign_ko': '직통열차',
      'sign_en': 'Express Train',
      'title': {'en': 'Buy an Express Train ticket', 'ko': '직통열차 승차권 사기'},
      'actions': {
        'en': ['Find the Express Train sign.', 'Use a ticket machine or the counter next to it.'],
        'ko': ["'직통열차' 표지판을 찾습니다.", '옆의 발매기나 안내센터에서 승차권을 삽니다.'],
      },
      'photo_url': 'assets/photos/express_concourse.jpg',
      'photo_credit': _wikiCredit,
      'elevator_status': 'CHECKING',
    },
    {
      'step_no': 4,
      'role': 'FIND',
      'icon': 'TRAIN',
      'sign_ko': '직통열차 승차구',
      'sign_en': 'Express Gate',
      'title': {'en': 'Pass the Express Train gate', 'ko': '직통열차 개찰구 통과'},
      'actions': {
        'en': ['Use the gate marked Express Train, not All-stop.', 'Keep your ticket until you leave Seoul Station.'],
        'ko': ["'일반열차'가 아닌 '직통열차' 개찰구로 갑니다.", '승차권은 서울역에서 나갈 때까지 보관합니다.'],
      },
      'photo_url': null,
      'photo_credit': null,
      'elevator_status': 'CHECKING',
    },
    {
      'step_no': 5,
      'role': 'FIND',
      'icon': 'TRAIN',
      'sign_ko': '직통열차 승강장 · 서울역 방면',
      'sign_en': 'Express Platform · To Seoul Station',
      'title': {'en': 'Board at the Express platform', 'ko': '직통열차 승강장에서 탑승'},
      'actions': {
        'en': ['Check the screen says Seoul Station.', 'Board the train and find your seat.'],
        'ko': ["전광판에 '서울역'이 보이는지 확인합니다.", '열차에 타고 자리를 찾습니다.'],
      },
      'photo_url': null,
      'photo_credit': null,
      'elevator_status': 'CHECKING',
    },
  ],
  'LOCAL': [
    _step1,
    _step2,
    {
      'step_no': 3,
      'role': 'FIND',
      'icon': 'TRAIN',
      'sign_ko': '일반열차',
      'sign_en': 'All-stop Train',
      'title': {'en': 'Get a T-money card', 'ko': '교통카드 준비하기'},
      'actions': {
        'en': ['Go to the All-stop Train side.', 'Buy or top up a T-money card at the machines.'],
        'ko': ["'일반열차' 쪽으로 갑니다.", '기계에서 교통카드(T-money)를 사거나 충전합니다.'],
      },
      'photo_url': 'assets/photos/local_concourse.jpg',
      'photo_credit': _wikiCredit,
      'elevator_status': 'CHECKING',
    },
    {
      'step_no': 4,
      'role': 'FIND',
      'icon': 'TRAIN',
      'sign_ko': '일반열차 승차구',
      'sign_en': 'All-stop Gate',
      'title': {'en': 'Tap your card at the gate', 'ko': '개찰구에 카드 찍기'},
      'actions': {
        'en': ['Tap the T-money card on the reader.', 'Tap it again when you leave Seoul Station.'],
        'ko': ['단말기에 교통카드를 댑니다.', '서울역에서 나갈 때 한 번 더 찍습니다.'],
      },
      'photo_url': null,
      'photo_credit': null,
      'elevator_status': 'CHECKING',
    },
    {
      'step_no': 5,
      'role': 'FIND',
      'icon': 'TRAIN',
      'sign_ko': '1·2 승강장 · 서울역 방면',
      'sign_en': 'Platform 1·2 · To Seoul Station',
      'title': {'en': 'Board at platform 1 or 2', 'ko': '1·2번 승강장에서 탑승'},
      'actions': {
        'en': ['Check the screen says Seoul Station.', 'Board the train heading to Seoul Station.'],
        'ko': ["전광판에 '서울역'이 보이는지 확인합니다.", '서울역 방면 열차에 탑니다.'],
      },
      'photo_url': 'assets/photos/local_platform.jpg',
      'photo_credit': _wikiCredit,
      'elevator_status': 'CHECKING',
    },
  ],
};

// 시연용 사용자 번호. 가짜 저장소는 아이디 student01을 101번으로 정한다.
const int fakeDemoUserId = 101;
const String fakeDemoUsername = 'student01';
const int fakeSampleOwnerId = 900; // 예시 팁의 '샘플' 작성자

// 팁 내용은 쓴 사람의 언어 하나로 둔다(사용자 글은 번역하지 않음).
const List<Map<String, dynamic>> fakeTipsJson = [
  {
    'id': 1,
    'route': 'EXPRESS',
    'step_no': 3,
    'title': 'Ask at the info center if your card fails',
    'location': 'B1, right of the ticket machines',
    'note': null,
    'status': 'VERIFIED',
    'owner_id': fakeSampleOwnerId,
    'verified_at': '2026-10-12',
    'is_example': true,
  },
  {
    'id': 2,
    'route': 'LOCAL',
    'step_no': 4,
    'title': 'Elevator for big suitcases',
    'location': 'Left end of the gates',
    'note': 'The wide gate next to it fits two suitcases.',
    'status': 'OUTDATED',
    'owner_id': fakeDemoUserId,
    'verified_at': '2026-09-30',
    'is_example': false,
  },
];
