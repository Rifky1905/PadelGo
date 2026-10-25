import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/links.dart';

/// Peta interaktif OpenStreetMap dengan pin PadelGo.
/// Geser untuk menjelajah, ketuk untuk buka Google Maps.
/// Dipakai di landing page dan halaman detail lapangan.
class CourtMap extends StatelessWidget {
  const CourtMap({super.key, this.height = 320});

  final double height;

  static final _center =
      LatLng(AppConstants.courtLat, AppConstants.courtLng);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
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
