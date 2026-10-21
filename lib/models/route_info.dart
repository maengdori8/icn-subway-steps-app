import 'localized_text.dart';

// 서버가 주지 않는 경로별 표시 정보. 앱 안에 경로 code별 상수로 둔다(fromJson에서 읽지 않음).
class RouteDisplay {
  const RouteDisplay({this.origin = 'T1', this.signKo, this.signEn});

  final String origin; // 출발 터미널: S01에서 묶는 기준
  final String? signKo; // 표지판 글자(언어와 관계없이 두 언어 병기, 시안 .signline)
  final String? signEn;
}

const Map<String, RouteDisplay> routeDisplays = {
  'EXPRESS': RouteDisplay(signKo: '직통열차', signEn: 'Express Train'),
  'LOCAL': RouteDisplay(signKo: '일반열차', signEn: 'All-stop Train'),
  'T2': RouteDisplay(origin: 'T2'),
};

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

  RouteDisplay get _display => routeDisplays[code] ?? const RouteDisplay();
  String get origin => _display.origin;
  String? get signKo => _display.signKo;
  String? get signEn => _display.signEn;

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
