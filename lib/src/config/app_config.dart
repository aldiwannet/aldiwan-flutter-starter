class AppConfig {
  const AppConfig._();
  static const apiBaseUrl = String.fromEnvironment(
    'ALDIWAN_API_BASE_URL',
    defaultValue: 'https://api.aldiwan.net/v1',
  );
  static const apiKey = String.fromEnvironment('ALDIWAN_API_KEY');
  static const demoMode = bool.fromEnvironment(
    'ALDIWAN_DEMO_MODE',
    defaultValue: false,
  );
  // Keep secrets on a trusted backend. Mobile/web binaries cannot protect embedded API keys.
}
