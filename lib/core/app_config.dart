class AppConfig {
  // インスタンス化を防ぐ
  AppConfig._();

  // 基本URL
  static const String yahooSearchBaseUrl = "https://search.yahoo.co.jp/image/search";

  // ヘッダー情報
  static const String userAgent = "your_email@example.com";

  // バリデーション設定
  static const int minSearchWordLength = 3;

  // デザイン設定
  static const double defaultPadding = 16.0;
  static const int gridCrossAxisCount = 3;
}