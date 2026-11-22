/// ============================================================
/// APP ROUTES — every path in one place
/// ============================================================
library;

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  // tabs
  static const home = '/home';
  static const explore = '/explore';
  static const saved = '/saved';
  static const settings = '/settings';
  // drill-ins
  static const search = '/search';
  static const remedyPattern = '/remedy/:slug';
  static const conditionPattern = '/condition/:slug';
  static const request = '/request';
  static const myRequests = '/my-requests';
  static const data = '/data';
  static const disclaimer = '/disclaimer';
  static const sources = '/sources';
  static const guide = '/guide';

  static String remedy(String slug, {String? tab}) => '/remedy/$slug${tab == null ? '' : '?tab=$tab'}';
  static String condition(String slug) => '/condition/$slug';
  static String searchFor({String? q, bool voice = false}) =>
      Uri(path: search, queryParameters: {if (q != null && q.isNotEmpty) 'q': q, if (voice) 'voice': '1'}).toString();
  static String exploreTab(String tab) => '$explore?tab=$tab';
  static String requestFor({String? name, String? kind}) =>
      Uri(path: request, queryParameters: {'name': ?name, 'kind': ?kind}).toString();
}
