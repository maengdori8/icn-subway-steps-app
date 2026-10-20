import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_language.dart';
import 'screens/home_shell.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';

class IcnSubwayApp extends StatelessWidget {
  const IcnSubwayApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => MaterialApp(
          title: 'ICN Subway Steps',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          themeMode: controller.themeMode, // 시스템 기본, 설정(S05)에서 밝게·어둡게
          locale: controller.language.locale,
          supportedLocales: [for (final l in AppLanguage.values) l.locale],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          scaffoldMessengerKey: controller.messengerKey,
          navigatorObservers: [MessageRouteObserver(controller)],
          home: const HomeShell(),
        ),
      ),
    );
  }
}
