import 'localized_text.dart';

// 표지판 칩 위 역할 라벨: 지금 서 있는 곳(HERE)인지, 찾아야 할 표지판(FIND)인지.
enum SignRole {
  here('HERE'),
  find('FIND');

  const SignRole(this.json);
  final String json;

  static SignRole fromJson(String value) => SignRole.values.firstWhere((r) => r.json == value);
}

// 표지판 칩의 픽토그램 종류. 그림은 화면(widgets/step_widgets.dart)이 고른다.
enum StepIcon {
  plane('PLANE'),
  escalator('ESCALATOR'),
  train('TRAIN');

  const StepIcon(this.json);
  final String json;

  static StepIcon fromJson(String value) =>
      StepIcon.values.firstWhere((i) => i.json == value, orElse: () => StepIcon.train);
}

// S02 단계 한 장. 서버 GET /api/routes/{route}/steps → {"route": "EXPRESS", "steps": [Step…]}.
// 안내 줄의 {ko|...}·{en|...}는 다른 언어로 읽어야 하는 구절 표시다(widgets/mixed_text.dart).
class GuideStep {
  const GuideStep({
    required this.stepNo,
    required this.role,
    required this.icon,
    required this.signKo,
    required this.signEn,
    required this.title,
    required this.instructions,
    this.photoKey,
    this.elevator,
  });

  final int stepNo; // 1부터. 목록 순서(index)와 구분한다.
  final SignRole role;
  final StepIcon icon;
  final String signKo; // 실제 표지판 글자(서버 sign.ko·sign.en). 현장 확인 전 초안이다.
  final String signEn;
  final LocalizedText title;
  final LocalizedLines instructions;
  final String? photoKey; // 앱에 들어 있는 사진 키(models/step_photos.dart). null이면 '사진 준비 중'
  final LocalizedText? elevator; // 엘리베이터 위치. null이면 '엘리베이터: 현장 확인 중'

  factory GuideStep.fromJson(Map<String, dynamic> json) {
    final sign = json['sign'] as Map<String, dynamic>;
    final elevator = json['elevator'] as Map<String, dynamic>?;
    return GuideStep(
      stepNo: json['stepNo'] as int,
      role: SignRole.fromJson(json['role'] as String),
      icon: StepIcon.fromJson(json['icon'] as String),
      signKo: sign['ko'] as String,
      signEn: sign['en'] as String,
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      instructions: LocalizedLines.fromJson(json['instructions'] as Map<String, dynamic>),
      photoKey: json['photoKey'] as String?,
      elevator: elevator == null ? null : LocalizedText.fromJson(elevator),
    );
  }

  // 응답 봉투 {"route": ..., "steps": [...]}를 읽는다.
  static List<GuideStep> listFromJson(Map<String, dynamic> json) => [
    for (final s in json['steps'] as List) GuideStep.fromJson(s as Map<String, dynamic>),
  ];

  Map<String, dynamic> toJson() => {
    'stepNo': stepNo,
    'role': role.json,
    'icon': icon.json,
    'photoKey': photoKey,
    'sign': {'ko': signKo, 'en': signEn},
    'title': title.toJson(),
    'instructions': instructions.toJson(),
    'elevator': elevator?.toJson(),
  };
}
