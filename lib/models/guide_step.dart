import 'localized_text.dart';

// 표지판 칩 위 역할 라벨: 지금 서 있는 곳(HERE)인지, 찾아야 할 표지판(FIND)인지.
enum SignRole {
  here('HERE'),
  find('FIND');

  const SignRole(this.json);
  final String json;

  static SignRole fromJson(String value) => SignRole.values.firstWhere((r) => r.json == value);
}

// 표지판 칩의 픽토그램 종류. 그림은 화면(widgets/sign_chip.dart)이 고른다.
enum StepIcon {
  plane('PLANE'),
  escalator('ESCALATOR'),
  train('TRAIN');

  const StepIcon(this.json);
  final String json;

  static StepIcon fromJson(String value) =>
      StepIcon.values.firstWhere((i) => i.json == value, orElse: () => StepIcon.train);
}

// S02 단계 한 장. 서버 후보: GET /api/routes/{code}/steps.
// 문구 안의 {ko|...}·{en|...}는 다른 언어로 읽어야 하는 구절 표시다(widgets/mixed_text.dart).
class GuideStep {
  const GuideStep({
    required this.stepNo,
    required this.role,
    required this.icon,
    required this.signKo,
    required this.signEn,
    required this.title,
    required this.actions,
    this.photoUrl,
    this.photoCredit,
    this.elevatorStatus = 'CHECKING',
  });

  final int stepNo; // 1부터. 목록 순서(index)와 구분한다.
  final SignRole role;
  final StepIcon icon;
  final String signKo; // 실제 표지판 글자. 현장 확인 전 초안이다.
  final String signEn;
  final LocalizedText title;
  final LocalizedLines actions;
  final String? photoUrl; // null이면 '사진 준비 중'. 지금은 앱 안 사진 경로(assets/...)
  final String? photoCredit; // 사진 아래 출처 한 줄
  final String elevatorStatus; // CHECKING: '엘리베이터: 현장 확인 중'

  factory GuideStep.fromJson(Map<String, dynamic> json) => GuideStep(
    stepNo: json['step_no'] as int,
    role: SignRole.fromJson(json['role'] as String),
    icon: StepIcon.fromJson(json['icon'] as String),
    signKo: json['sign_ko'] as String,
    signEn: json['sign_en'] as String,
    title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
    actions: LocalizedLines.fromJson(json['actions'] as Map<String, dynamic>),
    photoUrl: json['photo_url'] as String?,
    photoCredit: json['photo_credit'] as String?,
    elevatorStatus: json['elevator_status'] as String? ?? 'CHECKING',
  );

  Map<String, dynamic> toJson() => {
    'step_no': stepNo,
    'role': role.json,
    'icon': icon.json,
    'sign_ko': signKo,
    'sign_en': signEn,
    'title': title.toJson(),
    'actions': actions.toJson(),
    'photo_url': photoUrl,
    'photo_credit': photoCredit,
    'elevator_status': elevatorStatus,
  };
}
