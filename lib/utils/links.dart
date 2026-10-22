import 'package:url_launcher/url_launcher.dart';

/// Buka URL eksternal (Google Maps, WhatsApp, email) — di web
/// terbuka sebagai tab baru.
Future<void> openLink(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
