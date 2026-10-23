import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/l10n/app_language.dart';
import 'package:icn_subway_app/l10n/app_strings.dart';
import 'package:icn_subway_app/models/guide_step.dart';
import 'package:icn_subway_app/models/step_photos.dart';
import 'package:icn_subway_app/theme/app_theme.dart';
import 'package:icn_subway_app/widgets/step_widgets.dart';

// 사진 키 → 앱 사진 연결(lib/models/step_photos.dart). pubspec.yaml에 빠진 사진은 화면에서 깨지므로 묶음에 실제로 있는지 본다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('사진 키마다 앱 묶음에 든 사진 파일과 출처 한 줄이 있다', () async {
    for (final MapEntry(:key, :value) in stepPhotos.entries) {
      final data = await rootBundle.load(value.asset);
      expect(data.lengthInBytes, greaterThan(10000), reason: key);
      expect(value.credit, startsWith('Photo'), reason: key);
    }
  });

  test('2026-10-22에 채운 네 곳: 교통센터·일반열차 개찰구·직통열차 개찰구·직통열차 승강장', () {
    expect(stepPhotoFor('transportCenter')!.asset, 'assets/photos/transport_center.jpg');
    expect(stepPhotoFor('transportCenter')!.credit, 'Photo: Minseong Kim / Wikimedia Commons · CC BY-SA 4.0');
    expect(stepPhotoFor('localGate')!.asset, 'assets/photos/local_gate.jpg');
    expect(stepPhotoFor('localGate')!.credit, 'Photo (2007): Kanchi1979 / Wikimedia Commons · CC BY 2.5');
    expect(stepPhotoFor('expressGate')!.asset, 'assets/photos/express_gate.jpg');
    expect(stepPhotoFor('expressGate')!.credit, 'Photo (2015, cropped): Asacyan / Wikimedia Commons · CC BY-SA 4.0');
    expect(stepPhotoFor('expressPlatform')!.asset, 'assets/photos/express_platform.jpg');
    expect(stepPhotoFor('expressPlatform')!.credit, 'Photo (2015): Wei-Te Wong / Wikimedia Commons · CC BY-SA 2.0');
    expect(stepPhotoFor(null), isNull);
    expect(stepPhotoFor('notInApp'), isNull, reason: '앱에 없는 키는 사진 준비 중');
  });

  // 이제 모든 시드 단계에 사진이 있어 여정 검사로는 자리표시를 보지 않는다. 서버가 null이나 모르는 키를 주는 경우를 따로 본다.
  testWidgets('photoKey가 null이거나 앱이 모르는 키면 사진 대신 사진 준비 중 칸', (tester) async {
    for (final key in [null, 'notInApp']) {
      final step = GuideStep.fromJson({
        'stepNo': 4,
        'role': 'FIND',
        'icon': 'TRAIN',
        'photoKey': key,
        'sign': {'ko': '직통열차 승차구', 'en': 'Express Gate'},
        'title': {'en': 'Pass the Express Train gate', 'ko': '직통열차 개찰구 통과'},
        'instructions': {'en': ['Use the Express Train gate.'], 'ko': ['직통열차 개찰구로 갑니다.']},
        'elevator': null,
      });
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
          body: StepPhoto(step: step, language: AppLanguage.en, strings: AppStrings.of(AppLanguage.en)),
        ),
      ));
      expect(find.text('Photo coming soon'), findsOneWidget, reason: '$key');
      expect(find.byType(Image), findsNothing, reason: '$key');
    }
  });
}
