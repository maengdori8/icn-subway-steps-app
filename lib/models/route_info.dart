import 'localized_text.dart';

// S01 경로 카드 한 장. 온라인 전용 결정에 따라 서버(GET /api/routes 후보)에서 받는다.
// JSON 이름은 docs/ui-handoff.md의 후보(route: EXPRESS/LOCAL, step_no)와 같은 snake_case로 둔다.
class RouteInfo {
  const RouteInfo({
    required this.code,
    required this.origin,
    required this.name,
    required this.summary,
    this.signKo,
    this.signEn,
    required this.stepCount,
    required this.available,
  });

  final String code; // EXPRESS / LOCAL / T2(준비 중). 팁의 route 값과 같다.
  final String origin; // 출발 터미널: T1 / T2. S01에서 묶는 기준
  final LocalizedText name; // 직통열차 / Express Train
  final LocalizedText summary; // 카드 한 줄 설명. 준비 중 경로는 안내 문구
  final String? signKo; // 표지판 글자(언어와 관계없이 두 언어 병기)
  final String? signEn;
  final int stepCount;
  final bool available; // false면 '준비 중' 배지, 누르면 안내만 띄운다

  bool get isExpress => code == 'EXPRESS';
  bool get isLocal => code == 'LOCAL';

  factory RouteInfo.fromJson(Map<String, dynamic> json) => RouteInfo(
    code: json['code'] as String,
    origin: json['origin'] as String,
    name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
    summary: LocalizedText.fromJson(json['summary'] as Map<String, dynamic>),
    signKo: json['sign_ko'] as String?,
    signEn: json['sign_en'] as String?,
    stepCount: json['step_count'] as int,
    available: json['available'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'origin': origin,
    'name': name.toJson(),
    'summary': summary.toJson(),
    'sign_ko': signKo,
    'sign_en': signEn,
    'step_count': stepCount,
    'available': available,
  };
}
