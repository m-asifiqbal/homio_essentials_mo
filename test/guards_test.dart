/// Source-level guards for mistakes that already cost a release build.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Files whose CODE (comment lines ignored) contains [p].
  List<String> filesMatching(String p) => [
        for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')))
          if (f.readAsLinesSync().where((l) => !l.trimLeft().startsWith('//')).any((l) => l.contains(p))) f.path.replaceAll(r'\', '/'),
      ];

  test('no PageStorageKey: one above a SelectableText made an opened book section crash into a grey box', () {
    // PageStorage keeps ONE value per key chain. An ExpansionTile stores its open flag (bool) there and the
    // SelectableText below it stores its scroll offset (double): the first tap threw a type-cast error, which
    // a release build draws as a grey box with no height limit — the page then scrolled forever.
    // Keep UI state (like which sub-section is open) in a State object or a provider instead.
    expect(filesMatching('PageStorageKey'), isEmpty);
  });

  test('loading is always a shimmer: no CircularProgressIndicator/LinearProgressIndicator for a screen load', () {
    // Button spinners (a form that is sending) are allowed; list them here so adding another is a decision.
    const allowed = {'lib/features/requests/presentation/screens/request_screen.dart'};
    final offenders = {...filesMatching('CircularProgressIndicator'), ...filesMatching('LinearProgressIndicator')}.difference(allowed);
    expect(offenders, isEmpty, reason: 'use HmSkeleton / SkeletonList for loading: $offenders');
  });
}
