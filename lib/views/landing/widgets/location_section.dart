import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/court_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/links.dart';
import '../../../widgets/court_map.dart';
import 'section_container.dart';

/// Section "Lokasi Kami" — info alamat & kontak di kiri,
/// peta interaktif OpenStreetMap di kanan.
class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final court = context.watch<CourtProvider>().primaryCourt;
    return SectionContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;
          final info = _LocationInfo(
            address: (court?.address.isNotEmpty ?? false)
                ? court!.address
                : AppConstants.courtAddress,
          );
          const map = CourtMap(height: 320);
          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [info, const SizedBox(height: 24), map],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: info),
              const SizedBox(width: 40),
              const Expanded(flex: 6, child: map),
            ],
          );
        },
      ),
    );
  }
}

class _LocationInfo extends StatelessWidget {
  const _LocationInfo({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi Kami',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: PadelGoColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kunjungi lapangan kami — mudah dijangkau dari pusat kota.',
          style: TextStyle(fontSize: 14, color: PadelGoColors.textSecondary),
        ),
        const SizedBox(height: 22),
        _contactTile(
          Icons.location_on_outlined,
          'PadelGo Court A',
          address,
          onTap: () => openLink(AppConstants.mapsUrl),
        ),
        const SizedBox(height: 14),
        _contactTile(
          Icons.chat_outlined,
          'Hubungi Kami (WhatsApp)',
          '${AppConstants.adminPhoneDisplay} • ${AppConstants.adminEmail}',
          onTap: () =>
              openLink(AppConstants.waMeUrl(message: AppConstants.waTemplate)),
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: () => openLink(AppConstants.mapsUrl),
          icon: const Icon(Icons.directions_outlined, size: 19),
          label: const Text('Petunjuk Arah (Google Maps)'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _contactTile(IconData icon, String title, String subtitle,
      {required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PadelGoColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: PadelGoColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: PadelGoColors.primary, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: PadelGoColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: PadelGoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new,
                  size: 15, color: PadelGoColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
