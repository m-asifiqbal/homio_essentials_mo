/// The app is called Homiopedia everywhere a person can see it, and its application id is com.iqballabs.homiopedia.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:homio_essentials/core/constants/app_info.dart';

void main() {
  const name = 'Homiopedia';
  const nameBn = 'হোমিওপিডিয়া';

  test('app info', () {
    expect(AppInfo.name, name);
    expect(AppInfo.nameBn, nameBn);
    expect(AppInfo.localizedName(false), name);
    expect(AppInfo.localizedName(true), nameBn);
  });

  test('the strings file says Homiopedia in both languages', () {
    final en = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map;
    final bn = jsonDecode(File('lib/l10n/app_bn.arb').readAsStringSync()) as Map;
    expect(en['appName'], name);
    expect(bn['appName'], nameBn);
    expect(en['needsInternet'], startsWith(name));
    expect(bn['needsInternet'], startsWith(nameBn));
  });

  test('the Android launcher label, iOS names and the web manifest say Homiopedia', () {
    expect(File('android/app/src/main/AndroidManifest.xml').readAsStringSync(), contains('android:label="$name"'));
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(RegExp(r'<key>CFBundleDisplayName</key>\s*<string>' + name + r'</string>').hasMatch(plist), isTrue);
    expect(RegExp(r'<key>CFBundleName</key>\s*<string>' + name + r'</string>').hasMatch(plist), isTrue);
    final manifest = jsonDecode(File('web/manifest.json').readAsStringSync()) as Map;
    expect(manifest['name'], name);
    expect(manifest['short_name'], name);
    expect(File('web/index.html').readAsStringSync(), contains('<title>$name</title>'));
  });

  test('no visible trace of the old name is left in the app', () {
    const old = ['Homio Essentials', 'হোমিও এসেনশিয়ালস'];
    final roots = ['lib', 'web', 'android/app/src', 'ios/Runner'];
    final hits = <String>[];
    for (final r in roots) {
      for (final f in Directory(r).listSync(recursive: true).whereType<File>()) {
        final p = f.path.replaceAll(r'\', '/');
        if (p.contains('/l10n/app_localizations') || RegExp(r'\.(png|jpg|ttf|otf|ico|webp|jar|class|so)$').hasMatch(p)) continue;
        final text = f.readAsStringSync(encoding: const Utf8Codec(allowMalformed: true));
        if (old.any(text.contains)) hits.add(p);
      }
    }
    expect(hits, isEmpty, reason: 'still says the old name: $hits');
  });

  test('the application id is com.iqballabs.homiopedia on Android and iOS, with no trace of the old id', () {
    const id = 'com.iqballabs.homiopedia';
    expect(AppInfo.applicationId, id);
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, contains('namespace = "$id"'));
    expect(gradle, contains('applicationId = "$id"'));
    // MainActivity lives in the matching folder and declares the matching package.
    final activity = File('android/app/src/main/kotlin/com/iqballabs/homiopedia/MainActivity.kt');
    expect(activity.existsSync(), isTrue);
    expect(activity.readAsStringSync(), contains('package $id'));
    expect(Directory('android/app/src/main/kotlin/com/homio').existsSync(), isFalse, reason: 'the old package folder is gone');
    // iOS: the app and its test target.
    final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    expect(RegExp('PRODUCT_BUNDLE_IDENTIFIER = $id;').allMatches(pbx), hasLength(3));
    expect(RegExp('PRODUCT_BUNDLE_IDENTIFIER = $id.RunnerTests;').allMatches(pbx), hasLength(3));
    // Nothing in the platform folders or the app code still mentions the old id.
    final stale = <String>[];
    for (final root in ['android/app/src', 'android/app/build.gradle.kts', 'ios/Runner', 'ios/Runner.xcodeproj', 'lib']) {
      final files = FileSystemEntity.isDirectorySync(root) ? Directory(root).listSync(recursive: true).whereType<File>() : [File(root)];
      for (final f in files) {
        if (RegExp(r'\.(png|jpg|ttf|otf|ico|webp|jar|class|so)$').hasMatch(f.path)) continue;
        if (f.readAsStringSync(encoding: const Utf8Codec(allowMalformed: true)).contains('com.homio')) stale.add(f.path.replaceAll(r'\', '/'));
      }
    }
    expect(stale, isEmpty, reason: 'old application id still in: $stale');
  });
}
