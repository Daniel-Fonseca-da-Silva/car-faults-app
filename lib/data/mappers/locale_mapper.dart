import '../../domain/models/app_locale.dart';

/// Maps [AppLocale] to the `language`/`locale` query value `car-faults-api`
/// expects (BCP 47 tags, per `common/enums/lookup-locale.enum.ts`).
String apiLanguageFor(AppLocale locale) {
  switch (locale) {
    case AppLocale.pt:
      return 'pt-PT';
    case AppLocale.en:
      return 'en-GB';
    case AppLocale.es:
      return 'es-ES';
  }
}
