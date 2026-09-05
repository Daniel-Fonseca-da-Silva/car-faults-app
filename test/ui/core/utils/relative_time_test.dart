import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/l10n/app_localizations_pt.dart';
import 'package:car_faults_app/ui/core/utils/relative_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final AppLocalizations l10n = AppLocalizationsPt();

  test('less than a minute ago is "agora mesmo"', () {
    final submittedAt = DateTime.now().subtract(const Duration(seconds: 30));

    expect(relativeTimeLabel(submittedAt, l10n), 'agora mesmo');
  });

  test('less than an hour ago is in minutes', () {
    final submittedAt = DateTime.now().subtract(const Duration(minutes: 25));

    expect(relativeTimeLabel(submittedAt, l10n), 'há 25 min');
  });

  test('less than a day ago is in hours', () {
    final submittedAt = DateTime.now().subtract(const Duration(hours: 6));

    expect(relativeTimeLabel(submittedAt, l10n), 'há 6 h');
  });

  test('a day or more ago is in days', () {
    final submittedAt = DateTime.now().subtract(const Duration(days: 2));

    expect(relativeTimeLabel(submittedAt, l10n), 'há 2 d');
  });

  test('a future timestamp (clock skew) is treated as "agora mesmo"', () {
    final submittedAt = DateTime.now().add(const Duration(minutes: 5));

    expect(relativeTimeLabel(submittedAt, l10n), 'agora mesmo');
  });
}
