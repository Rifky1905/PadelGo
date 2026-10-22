import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../providers/court_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/links.dart';
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
          const map = _MapPreview();
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

/// Peta interaktif OpenStreetMap dengan pin PadelGo.
/// Geser untuk menjelajah, ketuk untuk buka Google Maps.
class _MapPreview extends StatelessWidget {
  const _MapPreview();

  static final _center =
      LatLng(AppConstants.courtLat, AppConstants.courtLng);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PadelGoColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 16,
              // Ketuk peta (bukan geser) → buka Google Maps.
              onTap: (_, _) => openLink(AppConstants.mapsUrl),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'id.padelgo.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _center,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_on,
                      size: 44,
                      color: PadelGoColors.primary,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Label lokasi di atas peta
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_tennis,
                      size: 15, color: PadelGoColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'PadelGo • Depok',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: PadelGoColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tombol buka Google Maps
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              elevation: 3,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => openLink(AppConstants.mapsUrl),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new,
                          size: 13, color: PadelGoColors.primary),
                      SizedBox(width: 5),
                      Text(
                        'Buka Google Maps',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: PadelGoColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Atribusi OpenStreetMap (wajib lisensi tile)
          const Positioned(
            right: 4,
            bottom: 2,
            child: Text(
              '© OpenStreetMap contributors',
              style: TextStyle(
                fontSize: 8.5,
                color: Color(0xAA555555),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
