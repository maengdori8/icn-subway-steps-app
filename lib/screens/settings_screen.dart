import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/mixed_text.dart';
import 'login_screen.dart';

const _dataGoUrl = 'https://www.data.go.kr/data/15130703/fileData.do';
const _ccBySaUrl = 'https://creativecommons.org/licenses/by-sa/4.0/';
const _ccByUrl = 'https://creativecommons.org/licenses/by/2.5/';
const _ccBySa2Url = 'https://creativecommons.org/licenses/by-sa/2.0/';
const _commonsUrls = [
  'https://commons.wikimedia.org/wiki/File:202403_AREX_Express_Train_Concourse_at_Incheon_International_Airport_Terminal_1_Station.jpg',
  'https://commons.wikimedia.org/wiki/File:202403_AREX_Local_Train_Concourse_at_Incheon_International_Airport_Terminal_1_Station.jpg',
  'https://commons.wikimedia.org/wiki/File:202403_AREX_Local_Platform_1,2_of_Incheon_International_Airport_Terminal_1_Station.jpg',
  'https://commons.wikimedia.org/wiki/File:Incheon_Airport_Transportation_Center_Main_Hall.jpg',
  'https://commons.wikimedia.org/wiki/File:AREX-Incheon-International-Airport-Station-Gates.JPG',
  'https://commons.wikimedia.org/wiki/File:Korail_ar_incheon_int%27l_airport_sta_02.jpg',
  'https://commons.wikimedia.org/wiki/File:Wongwt_首爾機場快鐵_(16921458087).jpg',
];

// S05 설정: 화면 테마(시스템/밝게/어둡게), 언어(English/한국어), 계정·로그아웃, 사진 출처, 정보.
// 언어·테마는 여기서만 바꾼다. 둘 다 기기에 기억한다.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = app.strings;
    final c = AppColors.of(context);
    final small = TextStyle(fontSize: 12, height: 1.5, color: c.textSecondary);
    final session = app.session;

    return ScrollColumn(
      children: [
        _Group(
          title: s.setAppearance,
          // 시안의 3칸 선택(.seg). 선택 표시는 언어 목록과 같이 primary 테두리 + 체크(4차 VIS-09).
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: c.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                for (final (mode, label) in [
                  (ThemeMode.system, s.thSystem),
                  (ThemeMode.light, s.thLight),
                  (ThemeMode.dark, s.thDark),
                ])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _ThemeOption(
                        label: label,
                        selected: app.themeMode == mode,
                        onTap: () => app.setThemeMode(mode),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        _Group(
          title: s.setLanguage,
          child: Column(
            children: [
              for (final language in AppLanguage.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LanguageOption(
                    language: language,
                    selected: app.language == language,
                    onTap: () => app.setLanguage(language),
                  ),
                ),
            ],
          ),
        ),
        _Group(
          title: s.setAccount,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            decoration: BoxDecoration(color: c.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: [
                Text(
                  session != null ? s.loggedInAs(session.username) : s.notLoggedIn,
                  style: TextStyle(fontSize: 14, color: session != null ? c.textPrimary : c.textSecondary),
                ),
                if (session != null)
                  TextButton(
                    onPressed: () {
                      app.signOut();
                      app.showMessage((s) => s.loggedOut);
                    },
                    child: Text(s.logout),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute<bool>(builder: (_) => const LoginScreen(purpose: LoginPurpose.general))),
                    child: Text(s.login),
                  ),
              ],
            ),
          ),
        ),
        // 사진 출처: licenses.txt의 표시 문구와 라이선스·원본 주소(4차 REG-07). 주소는 길게 눌러 복사할 수 있다.
        _Group(
          title: s.setCredits,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MixedText(s.creditArrivals, language: app.language, style: small),
              SelectableText(_dataGoUrl, style: small),
              const SizedBox(height: 8),
              MixedText(s.creditWiki, language: app.language, style: small),
              MixedText(s.creditTransport, language: app.language, style: small),
              MixedText(s.creditExpressGate, language: app.language, style: small),
              Text('${s.creditLicenseLink}:', style: small),
              SelectableText(_ccBySaUrl, style: small),
              const SizedBox(height: 8),
              MixedText(s.creditGate, language: app.language, style: small),
              Text('${s.creditLicenseLink}:', style: small),
              SelectableText(_ccByUrl, style: small),
              const SizedBox(height: 8),
              MixedText(s.creditExpressPlatform, language: app.language, style: small),
              Text('${s.creditLicenseLink}:', style: small),
              SelectableText(_ccBySa2Url, style: small),
              const SizedBox(height: 8),
              Text('${s.creditOriginals}:', style: small),
              for (final url in _commonsUrls) SelectableText(url, style: small),
            ],
          ),
        ),
        _Group(
          title: s.setAbout,
          child: Text(s.version(demoData: app.demoData), style: small),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [Eyebrow(title, header: true), const SizedBox(height: 8), child],
    ),
  );
}

// 테마 한 칸. 셋 중 하나만 고르는 라디오로 읽힌다.
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MergeSemantics(
      child: Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: true,
        child: Material(
          color: selected ? c.surface : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: selected ? BorderSide(color: c.primary, width: 2) : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSizes.minimumTap),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected) ...[
                      ExcludeSemantics(child: Icon(Icons.check, size: 16, color: c.primary)),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 언어 한 줄: 그 언어로 쓴 이름(국기 없음), 현재 언어는 primary 테두리와 체크.
class _LanguageOption extends StatelessWidget {
  const _LanguageOption({required this.language, required this.selected, required this.onTap});

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: Material(
          color: c.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: selected ? BorderSide(color: c.primary, width: 2) : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          locale: language.locale,
                          children: [
                            TextSpan(
                              text: language.nativeName,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                color: c.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: '  ${language.shortCode}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (selected) ExcludeSemantics(child: Icon(Icons.check, color: c.primary)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
