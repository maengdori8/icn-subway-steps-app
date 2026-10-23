import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/models/guide_step.dart';
import 'package:icn_subway_app/models/route_info.dart';
import 'package:icn_subway_app/models/tip.dart';
import 'package:icn_subway_app/models/user_session.dart';
import 'package:icn_subway_app/repositories/http_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';

// 10장 P02: 내 서버에서 받은 응답 표본(docs/samples, 2026-10-21 실행 서버 127.0.0.1:8097의 실제 응답)을 기준으로 모델을 본다.
// express-steps.json은 2026-10-22 빈 사진을 채우며 photoKey만 고쳤다(2단계 transportCenter, 4·5단계 expressGate·expressPlatform).
// 고친 뒤 서버 생성기 예시 route-steps.json 본문과 같은지 비교했다.
// 정상 값 · 명세가 허용한 null · 필수 항목 누락 · 잘못된 타입 · 명세 밖 enum 값.
// 누락·타입 오류는 그럴듯한 기본값으로 채우지 않고 원인 모를 실패(server)여야 한다(화면은 '불러오지 못했어요'와 다시 시도).

Map<String, dynamic> sample(String name) =>
    jsonDecode(File('docs/samples/$name').readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> copyOf(Map<String, dynamic> json) => jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

class _FixedTransport implements ApiTransport {
  _FixedTransport(this.body);

  final Object body;

  @override
  Future<ApiResponse> send(Uri uri, ApiRequest request) async => ApiResponse(200, utf8.encode(jsonEncode(body)));
}

Future<RepositoryErrorCode?> failureOf(Object body, Future<Object?> Function(HttpSubwayRepository repo) call) async {
  try {
    await call(HttpSubwayRepository(transport: _FixedTransport(body)));
    return null;
  } on RepositoryException catch (e) {
    return e.code;
  }
}

void main() {
  group('정상 값과 명세가 허용한 null', () {
    test('GET /api/routes 표본: 경로 3개, T2는 준비 중(단계 0)', () {
      final routes = RouteInfo.listFromJson(sample('routes-list.json'));
      expect(routes.map((r) => r.code), ['EXPRESS', 'LOCAL', 'T2']);
      expect(routes.first.name.ko, '직통열차');
      expect(routes.first.stepCount, 5);
      expect(routes.last.available, isFalse);
      expect(routes.last.stepCount, 0);
    });

    test('GET /api/routes/EXPRESS/steps 표본: 1~5단계 사진 키, elevator는 null 허용(키는 있음)', () {
      final steps = GuideStep.listFromJson(sample('express-steps.json'));
      expect(steps.map((s) => s.stepNo), [1, 2, 3, 4, 5]);
      expect(steps.map((s) => s.photoKey), ['arrivals', 'transportCenter', 'expressConcourse', 'expressGate', 'expressPlatform']);
      expect(steps.every((s) => s.elevator == null), isTrue);
      expect(steps.first.signKo, '제1여객터미널 입국장');
      expect(steps.first.icon, StepIcon.plane);
    });

    test('GET /api/tips 표본: 메모 null은 허용(예시 팁 7), 메모 있는 팁 8은 OUTDATED', () {
      final seven = Tip.listFromJson(sample('tips-express-3.json')).single;
      expect(seven.id, 7);
      expect(seven.note, isNull);
      expect(seven.example, isTrue);
      expect(seven.mine, isFalse, reason: '토큰 없이 받은 표본');
      expect(seven.ownerId, 102);
      expect(seven.verifiedAt, DateTime.utc(2026, 10, 12, 3));
      final eight = Tip.listFromJson(sample('tips-local-4.json')).single;
      expect(eight.note, 'The wide gate next to it fits two suitcases.');
      expect(eight.status, TipStatus.outdated);
      expect(eight.ownerId, 101);
    });

    test('POST /api/auth/login 표본(토큰은 숨김으로 바꿔 저장): 사용자 101 student01', () {
      final json = sample('login-response.json');
      expect(json['accessToken'], '(숨김)', reason: '표본 파일에 토큰 원문이 없어야 한다');
      expect(json['tokenType'], 'Bearer');
      expect(json['expiresIn'], 1800);
      final s = UserSession.fromLoginJson(json);
      expect(s.userId, 101);
      expect(s.username, 'student01');
    });
  });

  group('필수 항목 누락·잘못된 타입·명세 밖 값은 server 실패(기본값으로 채우지 않음)', () {
    final tips = sample('tips-local-4.json');
    Map<String, dynamic> tipsWith(void Function(Map<String, dynamic> tip) change) {
      final copy = copyOf(tips);
      change((copy['tips'] as List).first as Map<String, dynamic>);
      return copy;
    }

    Future<RepositoryErrorCode?> readTips(Map<String, dynamic> body) => failureOf(body, (r) => r.fetchTips('LOCAL', 4));

    test('title 누락', () async {
      expect(await readTips(tipsWith((t) => t.remove('title'))), RepositoryErrorCode.server);
    });

    test('note 키 누락(값이 null인 것과 다름)', () async {
      expect(await readTips(tipsWith((t) => t.remove('note'))), RepositoryErrorCode.server);
    });

    test('mine·example 누락(false로 채우지 않음)', () async {
      expect(await readTips(tipsWith((t) => t.remove('mine'))), RepositoryErrorCode.server);
      expect(await readTips(tipsWith((t) => t.remove('example'))), RepositoryErrorCode.server);
    });

    test('id가 문자열 "8", stepNo가 문자열', () async {
      expect(await readTips(tipsWith((t) => t['id'] = '8')), RepositoryErrorCode.server);
      expect(await readTips(tipsWith((t) => t['stepNo'] = '4')), RepositoryErrorCode.server);
    });

    test('status가 명세 밖 값(DELETED), 날짜가 시각 형식이 아님', () async {
      expect(await readTips(tipsWith((t) => t['status'] = 'DELETED')), RepositoryErrorCode.server);
      expect(await readTips(tipsWith((t) => t['verifiedAt'] = 'yesterday')), RepositoryErrorCode.server);
    });

    test('목록 봉투가 아님(최상위 배열·tips 없음)', () async {
      expect(await failureOf([tips['tips']], (r) => r.fetchTips('LOCAL', 4)), RepositoryErrorCode.server);
      expect(await readTips({'items': tips['tips']}), RepositoryErrorCode.server);
    });

    test('단계: photoKey 키 누락, icon이 명세 밖 값', () async {
      Map<String, dynamic> stepsWith(void Function(Map<String, dynamic> step) change) {
        final copy = copyOf(sample('express-steps.json'));
        change((copy['steps'] as List).first as Map<String, dynamic>);
        return copy;
      }

      Future<RepositoryErrorCode?> readSteps(Map<String, dynamic> body) => failureOf(body, (r) => r.fetchSteps('EXPRESS'));
      expect(await readSteps(stepsWith((s) => s.remove('photoKey'))), RepositoryErrorCode.server);
      expect(await readSteps(stepsWith((s) => s.remove('elevator'))), RepositoryErrorCode.server);
      expect(await readSteps(stepsWith((s) => s['icon'] = 'BUS')), RepositoryErrorCode.server);
    });
  });
}
