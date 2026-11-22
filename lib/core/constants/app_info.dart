/// ============================================================
/// APP INFO — the product name lives here and only here
/// ============================================================
library;

abstract final class AppInfo {
  static const name = 'Homiopedia';
  static const nameBn = 'হোমিওপিডিয়া';
  static const tagline = 'The homeopathic medicine archive';
  static const version = '1.0.0';
  static const applicationId = 'com.iqballabs.homiopedia';

  static String localizedName(bool bangla) => bangla ? nameBn : name;
}
