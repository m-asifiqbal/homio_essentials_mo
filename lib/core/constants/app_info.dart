/// ============================================================
/// APP INFO — the product name lives here and only here
/// ============================================================
library;

abstract final class AppInfo {
  static const name = 'Homio Essentials';
  static const nameBn = 'হোমিও এসেনশিয়ালস';
  static const tagline = 'The homeopathic medicine archive';
  static const version = '1.0.0';
  static const applicationId = 'com.homio.essentials';

  static String localizedName(bool bangla) => bangla ? nameBn : name;
}
