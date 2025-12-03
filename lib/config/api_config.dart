// lib/config/api_config.dart

/// API 서버 관련 공통 설정
class ApiConfig {
  /// 운영 기준 Intersection 백엔드 URL
  /// 필요하면 --dart-define=API_BASE_URL 로 주입해서 덮어쓸 수 있게 함.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://intersection-api-balbudoong-dvaefbfhbychg9dc.canadacentral-01.azurewebsites.net',
  );

  /// 연결 타임아웃
  static const Duration connectTimeout = Duration(seconds: 10);

  /// 응답 타임아웃
  static const Duration receiveTimeout = Duration(seconds: 20);
}
