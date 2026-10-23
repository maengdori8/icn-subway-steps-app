// 가짜 저장소의 처음 자료. 서버 응답과 같은 모양(봉투·camelCase, 서버 docs/api-spec.yaml)으로 두어
// 모델의 fromJson이 실제 서버 응답을 읽는 것과 같은 길을 지나게 한다.
// 내용은 시안 v03의 ROUTES·예시 팁(서버 SeedData와 같은 번호 7·8). 표지판 글자·안내 문구는 현장 확인 전 초안이다.
// 층수·승강장 위치·요금·시간을 새로 만들어 넣지 않는다.

const Map<String, dynamic> fakeRoutesResponse = {
  'routes': [
    {
      'code': 'EXPRESS',
      'name': {'en': 'Express Train', 'ko': '직통열차'},
      'summary': {'en': 'Non-stop to Seoul Station · ticket needed', 'ko': '서울역까지 무정차 · 승차권 필요'},
      'available': true,
      'stepCount': 5,
    },
    {
      'code': 'LOCAL',
      'name': {'en': 'All-stop Train', 'ko': '일반열차'},
      'summary': {'en': 'Stops at every station · T-money card', 'ko': '모든 역 정차 · 교통카드(T-money)'},
      'available': true,
      'stepCount': 5,
    },
    {
      'code': 'T2',
      'name': {'en': 'T2 → Seoul Station', 'ko': 'T2 → 서울역'},
      'summary': {'en': 'From T2 arrivals', 'ko': 'T2 입국장에서 출발'},
      'available': false,
      'stepCount': 0,
    },
  ],
};

// 1·2단계는 두 경로가 같다. elevator가 null이면 앱은 '엘리베이터: 현장 확인 중'.
const Map<String, dynamic> _step1 = {
  'stepNo': 1,
  'role': 'HERE',
  'icon': 'PLANE',
  'photoKey': 'arrivals',
  'sign': {'ko': '제1여객터미널 입국장', 'en': 'Terminal 1 Arrivals'},
  'title': {'en': 'Walk out of the arrivals hall', 'ko': '입국장 밖으로 나오기'},
  'instructions': {
    'en': [
      'Exit through the arrival doors with your bags.',
      'Look up for signs that say Airport Railroad ({ko|공항철도}).',
    ],
    'ko': ['짐을 찾고 도착 출구로 나옵니다.', "천장에서 '공항철도 {en|Airport Railroad}' 표지판을 찾습니다."],
  },
  'elevator': null,
};

const Map<String, dynamic> _step2 = {
  'stepNo': 2,
  'role': 'FIND',
  'icon': 'ESCALATOR',
  'photoKey': 'transportCenter',
  'sign': {'ko': '교통센터 · 공항철도', 'en': 'Transportation Center · Airport Railroad'},
  'title': {'en': 'Go down to the Transportation Center', 'ko': '교통센터로 내려가기'},
  'instructions': {
    'en': [
      'Follow the Airport Railroad signs to the Transportation Center.',
      'Take the escalator or elevator down one floor.',
    ],
    'ko': ['공항철도 표지판을 따라 교통센터로 갑니다.', '에스컬레이터나 엘리베이터로 한 층 내려갑니다.'],
  },
  'elevator': null,
};

const Map<String, Map<String, dynamic>> fakeStepsResponses = {
  'EXPRESS': {
    'route': 'EXPRESS',
    'steps': [
      _step1,
      _step2,
      {
        'stepNo': 3,
        'role': 'FIND',
        'icon': 'TRAIN',
        'photoKey': 'expressConcourse',
        'sign': {'ko': '직통열차', 'en': 'Express Train'},
        'title': {'en': 'Buy an Express Train ticket', 'ko': '직통열차 승차권 사기'},
        'instructions': {
          'en': ['Find the Express Train sign.', 'Use a ticket machine or the counter next to it.'],
          'ko': ["'직통열차' 표지판을 찾습니다.", '옆의 발매기나 안내센터에서 승차권을 삽니다.'],
        },
        'elevator': null,
      },
      {
        'stepNo': 4,
        'role': 'FIND',
        'icon': 'TRAIN',
        'photoKey': 'expressGate',
        'sign': {'ko': '직통열차 승차구', 'en': 'Express Gate'},
        'title': {'en': 'Pass the Express Train gate', 'ko': '직통열차 개찰구 통과'},
        'instructions': {
          'en': ['Use the gate marked Express Train, not All-stop.', 'Keep your ticket until you leave Seoul Station.'],
          'ko': ["'일반열차'가 아닌 '직통열차' 개찰구로 갑니다.", '승차권은 서울역에서 나갈 때까지 보관합니다.'],
        },
        'elevator': null,
      },
      {
        'stepNo': 5,
        'role': 'FIND',
        'icon': 'TRAIN',
        'photoKey': 'expressPlatform',
        'sign': {'ko': '직통열차 승강장 · 서울역 방면', 'en': 'Express Platform · To Seoul Station'},
        'title': {'en': 'Board at the Express platform', 'ko': '직통열차 승강장에서 탑승'},
        'instructions': {
          'en': ['Check the screen says Seoul Station.', 'Board the train and find your seat.'],
          'ko': ["전광판에 '서울역'이 보이는지 확인합니다.", '열차에 타고 자리를 찾습니다.'],
        },
        'elevator': null,
      },
    ],
  },
  'LOCAL': {
    'route': 'LOCAL',
    'steps': [
      _step1,
      _step2,
      {
        'stepNo': 3,
        'role': 'FIND',
        'icon': 'TRAIN',
        'photoKey': 'localConcourse',
        'sign': {'ko': '일반열차', 'en': 'All-stop Train'},
        'title': {'en': 'Get a T-money card', 'ko': '교통카드 준비하기'},
        'instructions': {
          'en': ['Go to the All-stop Train side.', 'Buy or top up a T-money card at the machines.'],
          'ko': ["'일반열차' 쪽으로 갑니다.", '기계에서 교통카드(T-money)를 사거나 충전합니다.'],
        },
        'elevator': null,
      },
      {
        'stepNo': 4,
        'role': 'FIND',
        'icon': 'TRAIN',
        'photoKey': 'localGate',
        'sign': {'ko': '일반열차 승차구', 'en': 'All-stop Gate'},
        'title': {'en': 'Tap your card at the gate', 'ko': '개찰구에 카드 찍기'},
        'instructions': {
          'en': ['Tap the T-money card on the reader.', 'Tap it again when you leave Seoul Station.'],
          'ko': ['단말기에 교통카드를 댑니다.', '서울역에서 나갈 때 한 번 더 찍습니다.'],
        },
        'elevator': null,
      },
      {
        'stepNo': 5,
        'role': 'FIND',
        'icon': 'TRAIN',
        'photoKey': 'localPlatform',
        'sign': {'ko': '1·2 승강장 · 서울역 방면', 'en': 'Platform 1·2 · To Seoul Station'},
        'title': {'en': 'Board at platform 1 or 2', 'ko': '1·2번 승강장에서 탑승'},
        'instructions': {
          'en': ['Check the screen says Seoul Station.', 'Board the train heading to Seoul Station.'],
          'ko': ["전광판에 '서울역'이 보이는지 확인합니다.", '서울역 방면 열차에 탑니다.'],
        },
        'elevator': null,
      },
    ],
  },
  'T2': {'route': 'T2', 'steps': <Map<String, dynamic>>[]}, // 준비 중 경로는 빈 목록(서버와 같음)
};

// 시연용 사용자. 서버 표본 계정과 번호를 맞췄다(비밀번호는 가짜 저장소에서 확인하지 않음).
const int fakeDemoUserId = 101;
const String fakeDemoUsername = 'student01';
const int fakeSampleOwnerId = 102; // student02. 예시 팁(7번)을 올린 사람

// 팁 내용은 쓴 사람의 언어 하나로 둔다(사용자 글은 번역하지 않음). 서버 SeedData의 7·8번과 같다.
const Map<String, dynamic> fakeTipsResponse = {
  'tips': [
    {
      'id': 8,
      'route': 'LOCAL',
      'stepNo': 4,
      'title': 'Elevator for big suitcases',
      'location': 'Left end of the gates',
      'note': 'The wide gate next to it fits two suitcases.',
      'status': 'OUTDATED',
      'verifiedAt': '2026-09-30T03:00:00Z',
      'createdAt': '2026-09-30T03:00:00Z',
      'ownerId': fakeDemoUserId,
      'mine': false,
      'example': false,
    },
    {
      'id': 7,
      'route': 'EXPRESS',
      'stepNo': 3,
      'title': 'Ask at the info center if your card fails',
      'location': 'B1, right of the ticket machines',
      'note': null,
      'status': 'VERIFIED',
      'verifiedAt': '2026-10-12T03:00:00Z',
      'createdAt': '2026-10-12T03:00:00Z',
      'ownerId': fakeSampleOwnerId,
      'mine': false,
      'example': true,
    },
  ],
};
