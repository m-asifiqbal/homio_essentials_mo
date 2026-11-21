/// ============================================================
/// RENDER APP ICON — exports the launcher / splash PNGs from HomioMarkPainter
/// ============================================================
///
///   flutter test tool/icon/render_icon_test.dart
///   dart run flutter_launcher_icons && dart run flutter_native_splash:create
///
/// Writes assets/icon/:
///   app_icon.png             1024² full icon (iOS, web, legacy Android)
///   app_icon_foreground.png  1024² transparent, mark in the 66 % safe zone (adaptive)
///   splash_logo.png          1152² transparent, mark inside Android 12's 768 circle
/// ============================================================
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homio_essentials/core/widgets/hm_logo.dart';

Future<void> _render(String path, double size, HomioMarkPainter painter) async {
  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), Size.square(size));
  final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render icons', (tester) async {
    await tester.runAsync(() async {
      await _render('assets/icon/app_icon.png', 1024, const HomioMarkPainter(rounded: false, markScale: .9));
      await _render('assets/icon/app_icon_foreground.png', 1024, const HomioMarkPainter(background: false, markScale: .62));
      await _render('assets/icon/splash_logo.png', 1152, const HomioMarkPainter(background: false, markScale: .58));
    });
    expect(File('assets/icon/app_icon.png').existsSync(), isTrue);
  });
}
