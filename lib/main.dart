import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'repositories/fake_subway_repository.dart';
import 'repositories/http_api_transport.dart';
import 'repositories/http_subway_repository.dart';
import 'repositories/subway_repository.dart';
import 'state/app_controller.dart';

// 상태 확인용 가짜 상황. 이 값을 주면 서버 대신 9장 가짜 저장소로 실행한다. 예: flutter run --dart-define=FAKE_SCENARIO=offline
// none: 가짜 자료 그대로 / offline: 첫 경로 읽기가 연결 끊김으로 실패 / empty: 경로 0건 / tips-error: 첫 팁 읽기 실패
const String _scenario = String.fromEnvironment('FAKE_SCENARIO');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // 10장: 내 서버(icn-subway-server)에 연결한다. 주소는 --dart-define=API_BASE_URL로 받는다(기본 http://10.0.2.2:8097, ApiConfig).
  final SubwayRepository repository =
      _scenario.isEmpty ? HttpSubwayRepository(transport: HttpApiTransport()) : _fakeRepository(_scenario);

  runApp(
    IcnSubwayApp(
      controller: AppController(repository: repository, prefs: prefs),
    ),
  );
}

FakeSubwayRepository _fakeRepository(String scenario) {
  final repository = FakeSubwayRepository(emptyRoutes: scenario == 'empty');
  if (scenario == 'offline') repository.failNext(FakeOperation.routes, RepositoryErrorCode.offline);
  if (scenario == 'tips-error') repository.failNext(FakeOperation.tips, RepositoryErrorCode.server);
  return repository;
}
