// lib/config/api_config.dart

/// API 엔드포인트 설정
///
/// - 로컬 개발용: http://127.0.0.1:8000
/// - 프로덕션(Azure App Service):
///   https://intersection-api-balbudoong-dvaefbfhbychg9dc.canadacentral-01.azurewebsites.net
///
/// 지금은 Azure 백엔드에 붙어서 테스트하므로 PROD_URL 을 사용한다.
class ApiConfig {
  // Azure App Service (intersection-api-balbudoong)
  static const String baseUrl =
      "https://intersection-api-balbudoong-dvaefbfhbychg9dc.canadacentral-01.azurewebsites.net";

  // 필요하면 나중에 스위치해서 쓸 수 있게 로컬 URL도 참고용으로 남겨둠
  static const String localUrl = "http://127.0.0.1:8000";
}
