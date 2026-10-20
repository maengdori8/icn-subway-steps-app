// 팁 상태: 작성자 확인(VERIFIED) / 정보 오래됨(OUTDATED). 올린 사람만 바꾼다.
enum TipStatus {
  verified('VERIFIED'),
  outdated('OUTDATED');

  const TipStatus(this.json);
  final String json;

  TipStatus get toggled => this == verified ? outdated : verified;

  static TipStatus fromJson(String value) => TipStatus.values.firstWhere((s) => s.json == value);
}

// 단계에 붙은 팁 한 건. 필드 이름은 docs/ui-handoff.md '화면 항목과 데이터 이름' 후보를 따른다.
class Tip {
  const Tip({
    required this.id,
    required this.route,
    required this.stepNo,
    required this.title,
    required this.location,
    this.note,
    required this.status,
    required this.ownerId,
    required this.verifiedAt,
    this.isExample = false,
  });

  final int id; // 서버가 정한다
  final String route; // EXPRESS / LOCAL
  final int stepNo; // 1부터
  final String title; // 앞뒤 공백 제거 후 1~80자
  final String location; // 앞뒤 공백 제거 후 1~80자
  final String? note; // 선택, 최대 150자, 빈 값은 null
  final TipStatus status;
  final int ownerId; // 올린 사람. 화면에서 입력받지 않는다
  final String verifiedAt; // YYYY-MM-DD. 작성자가 상태를 마지막으로 정한 날(배지 '작성자 확인 · 날짜')
  final bool isExample; // 시연용 예시 팁('예시' 배지, 작성자 '샘플')

  Tip copyWith({TipStatus? status, String? verifiedAt}) => Tip(
    id: id,
    route: route,
    stepNo: stepNo,
    title: title,
    location: location,
    note: note,
    status: status ?? this.status,
    ownerId: ownerId,
    verifiedAt: verifiedAt ?? this.verifiedAt,
    isExample: isExample,
  );

  factory Tip.fromJson(Map<String, dynamic> json) => Tip(
    id: json['id'] as int,
    route: json['route'] as String,
    stepNo: json['step_no'] as int,
    title: json['title'] as String,
    location: json['location'] as String,
    note: json['note'] as String?,
    status: TipStatus.fromJson(json['status'] as String),
    ownerId: json['owner_id'] as int,
    verifiedAt: json['verified_at'] as String,
    isExample: json['is_example'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'route': route,
    'step_no': stepNo,
    'title': title,
    'location': location,
    'note': note,
    'status': status.json,
    'owner_id': ownerId,
    'verified_at': verifiedAt,
    'is_example': isExample,
  };
}

// S03이 저장소에 넘기는 입력. 번호·상태·올린 사람·날짜는 저장소(10장에서는 서버)가 정한다.
class TipDraft {
  const TipDraft({required this.route, required this.stepNo, required this.title, required this.location, this.note});

  final String route;
  final int stepNo;
  final String title;
  final String location;
  final String? note;

  Map<String, dynamic> toJson() => {
    'route': route,
    'step_no': stepNo,
    'title': title,
    'location': location,
    'note': note,
  };
}
