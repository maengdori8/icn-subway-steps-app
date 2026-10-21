// 팁 상태: 작성자 확인(VERIFIED) / 정보 오래됨(OUTDATED). 올린 사람만 바꾼다.
enum TipStatus {
  verified('VERIFIED'),
  outdated('OUTDATED');

  const TipStatus(this.json);
  final String json;

  TipStatus get toggled => this == verified ? outdated : verified;

  static TipStatus fromJson(String value) => TipStatus.values.firstWhere((s) => s.json == value);
}

// 단계에 붙은 팁 한 건. 서버 Tip 스키마(camelCase, docs/api-spec.yaml)와 같은 이름.
class Tip {
  const Tip({
    required this.id,
    required this.route,
    required this.stepNo,
    required this.title,
    required this.location,
    this.note,
    required this.status,
    required this.verifiedAt,
    required this.createdAt,
    required this.ownerId,
    this.mine = false,
    this.example = false,
  });

  final int id; // 서버가 정한다
  final String route; // EXPRESS / LOCAL
  final int stepNo; // 1부터
  final String title; // 앞뒤 공백 제거 후 1~80자
  final String location; // 앞뒤 공백 제거 후 1~80자
  final String? note; // 선택, 최대 150자, 빈 값은 null
  final TipStatus status;
  final DateTime verifiedAt; // UTC. 작성자가 마지막으로 상태를 정한 시각(배지에는 서울 날짜만)
  final DateTime createdAt; // UTC
  final int ownerId; // 올린 사람. 화면에서 입력받지 않는다
  // 서버가 요청 토큰으로 계산한 값. 화면은 로그인 상태가 바뀐 직후에도 맞도록 ownerId와 로그인 user.id를 비교한다.
  final bool mine;
  final bool example; // 시드 예시 팁('예시' 배지, 작성자 '샘플', 상태 바꾸기 버튼 없음)

  Tip copyWith({TipStatus? status, DateTime? verifiedAt}) => Tip(
    id: id,
    route: route,
    stepNo: stepNo,
    title: title,
    location: location,
    note: note,
    status: status ?? this.status,
    verifiedAt: verifiedAt ?? this.verifiedAt,
    createdAt: createdAt,
    ownerId: ownerId,
    mine: mine,
    example: example,
  );

  factory Tip.fromJson(Map<String, dynamic> json) => Tip(
    id: json['id'] as int,
    route: json['route'] as String,
    stepNo: json['stepNo'] as int,
    title: json['title'] as String,
    location: json['location'] as String,
    note: json['note'] as String?,
    status: TipStatus.fromJson(json['status'] as String),
    verifiedAt: DateTime.parse(json['verifiedAt'] as String).toUtc(),
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    ownerId: json['ownerId'] as int,
    mine: json['mine'] as bool? ?? false,
    example: json['example'] as bool? ?? false,
  );

  // 응답 봉투 {"tips": [...]}를 읽는다(GET /api/tips, GET /api/me/tips).
  static List<Tip> listFromJson(Map<String, dynamic> json) => [
    for (final t in json['tips'] as List) Tip.fromJson(t as Map<String, dynamic>),
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'route': route,
    'stepNo': stepNo,
    'title': title,
    'location': location,
    'note': note,
    'status': status.json,
    'verifiedAt': verifiedAt.toUtc().toIso8601String(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'ownerId': ownerId,
    'mine': mine,
    'example': example,
  };
}

// 서울(UTC+9, 일광절약시간 없음) 날짜 'YYYY-MM-DD'. 배지 '작성자 확인 · 날짜'에 쓴다.
String seoulDate(DateTime instant) {
  final d = instant.toUtc().add(const Duration(hours: 9));
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// S03이 저장소에 넘기는 입력(POST /api/tips 본문). 이 다섯 항목 외에는 보내지 않는다(서버는 400).
class TipDraft {
  const TipDraft({required this.route, required this.stepNo, required this.title, required this.location, this.note});

  final String route;
  final int stepNo;
  final String title;
  final String location;
  final String? note;

  Map<String, dynamic> toJson() => {
    'route': route,
    'stepNo': stepNo,
    'title': title,
    'location': location,
    'note': note,
  };
}
