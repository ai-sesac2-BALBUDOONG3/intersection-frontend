class ApiConfig {
  /// 기본 백엔드 베이스 URL (Azure App Service)
  /// 뒤에 슬래시(/)는 붙이지 않는다.
  static const String _defaultBaseUrl =
      'https://intersection-api-balbudoong-dvaefbfhbychg9dc.canadacentral-01.azurewebsites.net';

  /// 빌드 시 --dart-define=API_BASE_URL=... 으로 재정의 가능
  ///
  /// 예)
  ///   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl);
}
