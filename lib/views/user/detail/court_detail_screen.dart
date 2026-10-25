import 'package:flutter/material.dart';

import '../../../models/court.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/formatters.dart';
import '../../../utils/links.dart';
import '../../../widgets/court_image.dart';
import '../../../widgets/court_map.dart';
import '../../../widgets/facility_item.dart';
import '../../../widgets/section_title.dart';
import '../booking/booking_screen.dart';

/// Halaman detail lapangan — galeri, info, fasilitas, lokasi, CTA pesan.
class CourtDetailScreen extends StatefulWidget {
  const CourtDetailScreen({super.key, required this.court});

  final Court court;

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  final _pageController = PageController();
  int _imageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Court get court => widget.court;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image carousel
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: PadelGoColors.background,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: court.assetImages.isNotEmpty
                        ? court.assetImages.length
                        : court.galleryColors.length,
                    onPageChanged: (i) => setState(() => _imageIndex = i),
                    itemBuilder: (_, i) => CourtImage(
                      colors:
                          court.galleryColors[i % court.galleryColors.length],
                      asset: court.assetImages.isNotEmpty
                          ? court.assetImages[i % court.assetImages.length]
                          : null,
                      iconSize: 72,
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        court.assetImages.isNotEmpty
                            ? court.assetImages.length
                            : court.galleryColors.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _imageIndex == i ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _imageIndex == i
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama + kategori + rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: PadelGoColors.primarySoft,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                court.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: PadelGoColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              court.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: PadelGoColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PadelGoColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: PadelGoColors.star, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              court.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${court.reviewCount} ulasan • ${court.distanceKm.toStringAsFixed(1)} km dari lokasimu',
                    style: const TextStyle(
                      fontSize: 13,
                      color: PadelGoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Deskripsi
                  const SectionTitle(title: 'Tentang Lapangan'),
                  const SizedBox(height: 8),
                  Text(
                    court.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: PadelGoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fasilitas
                  const SectionTitle(title: 'Fasilitas'),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 18,
                    runSpacing: 16,
                    children: court.facilities
                        .map((f) => FacilityItem(facility: f))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // Lokasi — kartu alamat + peta interaktif
                  const SectionTitle(title: 'Lokasi'),
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => openLink(AppConstants.mapsUrl),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: PadelGoColors.divider),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: PadelGoColors.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.location_on,
                                  color: PadelGoColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    court.address,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: PadelGoColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Ketuk untuk buka di Google Maps',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: PadelGoColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.open_in_new,
                                size: 16, color: PadelGoColors.textHint),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const CourtMap(height: 220),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => openLink(AppConstants.mapsUrl),
                    icon: const Icon(Icons.directions_outlined, size: 19),
                    label: const Text('Petunjuk Arah (Google Maps)'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom bar: harga + tombol Pesan Lapangan
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mulai dari',
                    style: TextStyle(
                      fontSize: 11,
                      color: PadelGoColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${Formatters.rupiah(court.pricePerHour)}/jam',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: PadelGoColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(court: court),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, size: 20),
                  label: const Text('Pesan Lapangan Sekarang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
