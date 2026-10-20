import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'repositories/fake_subway_repository.dart';
import 'repositories/subway_repository.dart';
import 'state/app_controller.dart';

// 상태 확인용 가짜 상황. 예: flutter run --dart-define=FAKE_SCENARIO=offline
// offline: 첫 경로 읽기가 연결 끊김으로 실패 / empty: 경로 0건 / tips-error: 첫 팁 읽기 실패
const String _scenario = String.fromEnvironment('FAKE_SCENARIO');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // 9장: 메모리 가짜 저장소. 10장에서 HttpSubwayRepository(repositories/http_subway_repository.dart)로 바꾼다.
  final repository = FakeSubwayRepository(emptyRoutes: _scenario == 'empty');
  if (_scenario == 'offline') repository.failNext(FakeOperation.routes, RepositoryErrorCode.offline);
  if (_scenario == 'tips-error') repository.failNext(FakeOperation.tips, RepositoryErrorCode.server);

  runApp(
    IcnSubwayApp(
      controller: AppController(repository: repository, prefs: prefs),
    ),
  );
}
