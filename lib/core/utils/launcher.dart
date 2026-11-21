import 'package:url_launcher/url_launcher.dart';

/// Opens a contact or promotion target: phone, WhatsApp, email, web.
Future<bool> openTarget(String type, String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  final uri = switch (type) {
    'phone' || 'call' => Uri(scheme: 'tel', path: value.replaceAll(' ', '')),
    'whatsapp' => Uri.parse('https://wa.me/$digits'),
    'email' => Uri(scheme: 'mailto', path: value),
    'address' => Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(value)}'),
    _ => Uri.tryParse(value.startsWith('http') ? value : 'https://$value') ?? Uri.parse('https://example.com'),
  };
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
