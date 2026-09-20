/// Compile-time configuration for the Adzuna REST API.
///
/// Credentials are injected at build/run time so that no key is committed:
///
/// ```sh
/// flutter run --dart-define=ADZUNA_APP_ID=xxx --dart-define=ADZUNA_APP_KEY=yyy
/// ```
class AppConfig {
  const AppConfig._();

  static const String adzunaAppId = String.fromEnvironment('ADZUNA_APP_ID');
  static const String adzunaAppKey = String.fromEnvironment('ADZUNA_APP_KEY');

  /// Adzuna country code (gb, us, in, au, ...).
  static const String country = String.fromEnvironment(
    'ADZUNA_COUNTRY',
    defaultValue: 'in',
  );

  static const String baseUrl = 'https://api.adzuna.com/v1/api/jobs';

  static const int resultsPerPage = 20;

  /// Postings older than this are treated as closed and hidden.
  static const int maxDaysOld = 30;

  static bool get hasCredentials =>
      adzunaAppId.isNotEmpty && adzunaAppKey.isNotEmpty;
}
