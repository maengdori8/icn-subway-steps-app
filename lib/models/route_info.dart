import 'localized_text.dart';

// S01 경로 카드 한 장. 서버 GET /api/routes → {"routes": [Route…]} (camelCase, 서버 docs/api-spec.yaml).
class RouteInfo {
  const RouteInfo({
    required this.code,
    required this.name,
    required this.summary,
    required this.stepCount,
    required this.available,
  });

  final String code; // EXPRESS / LOCAL / T2(준비 중). 팁의 route 값과 같다.
  final LocalizedText name; // 직통열차 / Express Train
  final LocalizedText summary; // 카드 한 줄 설명
  final int stepCount;
  final bool available; // false면 '준비 중' 배지, 누르면 안내만 띄운다

  // 출발 터미널(S01에서 묶는 기준). 서버가 주지 않아 경로 코드로 정한다.
  String get origin => code.startsWith('T2') ? 'T2' : 'T1';

  factory RouteInfo.fromJson(Map<String, dynamic> json) => RouteInfo(
    code: json['code'] as String,
    name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
    summary: LocalizedText.fromJson(json['summary'] as Map<String, dynamic>),
    stepCount: json['stepCount'] as int,
    available: json['available'] as bool,
  );

  // 응답 봉투 {"routes": [...]}를 읽는다.
  static List<RouteInfo> listFromJson(Map<String, dynamic> json) => [
    for (final r in json['routes'] as List) RouteInfo.fromJson(r as Map<String, dynamic>),
  ];

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name.toJson(),
    'summary': summary.toJson(),
    'available': available,
    'stepCount': stepCount,
  };
}
