import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/links.dart';
import 'legal_screen.dart';

/// Tentang PadelGo — info aplikasi, versi, dan legal.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang PadelGo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: PadelGoColors.pinkGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: PadelGoColors.primary.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.sports_tennis,
                  color: Colors.white, size: 38),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'PadelGo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: PadelGoColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Versi 1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: PadelGoColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PadelGoColors.divider),
            ),
            child: const Text(
              'PadelGo adalah platform booking lapangan padel premium di '
              'Depok. Kami menyediakan lapangan standar WPT dengan '
              'fasilitas lengkap — shower room, parkir luas, pro shop, dan '
              'cafeteria — agar pengalaman main padel kamu makin seru.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.6,
                color: PadelGoColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PadelGoColors.divider),
            ),
            child: Column(
              children: [
                _infoRow(Icons.location_on_outlined, 'Alamat',
                    AppConstants.courtAddress),
                const Divider(indent: 56),
                _infoRow(Icons.schedule_outlined, 'Jam Operasional',
                    'Setiap hari • 06:00 - 22:00'),
                const Divider(indent: 56),
                _infoRow(Icons.email_outlined, 'Email',
                    AppConstants.adminEmail),
                const Divider(indent: 56),
                _infoRow(Icons.chat_outlined, 'WhatsApp Admin',
                    AppConstants.adminPhoneDisplay,
                    onTap: () => openLink(
                        AppConstants.waMeUrl(
                            message: AppConstants.waTemplate))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PadelGoColors.divider),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined,
                      color: PadelGoColors.textSecondary),
                  title: const Text(
                    'Syarat & Ketentuan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PadelGoColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: PadelGoColors.textHint, size: 20),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LegalScreen.terms()),
                  ),
                ),
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: PadelGoColors.textSecondary),
                  title: const Text(
                    'Kebijakan Privasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PadelGoColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: PadelGoColors.textHint, size: 20),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LegalScreen.privacy()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '© 2026 PadelGo. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              color: PadelGoColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: PadelGoColors.primary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: PadelGoColors.textSecondary,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: PadelGoColors.textPrimary,
        ),
      ),
      trailing: onTap == null
          ? null
          : const Icon(Icons.open_in_new,
              size: 16, color: PadelGoColors.textHint),
      onTap: onTap,
    );
  }
}
