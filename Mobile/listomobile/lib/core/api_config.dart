class ApiConfig {
  /// No emulador Android, o IP 10.0.2.2 aponta para o localhost do seu PC.
  ///
  /// Para rodar no navegador, use:
  /// flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
  ///
  /// Para rodar em celular físico, use o IP do seu computador:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
}
