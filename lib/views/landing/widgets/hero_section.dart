import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/court_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/court_image.dart';
import 'section_container.dart';

/// Hero section — judul besar, deskripsi, CTA ganda, dan kartu foto lapangan.
class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.onBooking,
    required this.onSchedule,
  });

  final VoidCallback onBooking;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final textColumn = _HeroText(
            onBooking: onBooking,
            onSchedule: onSchedule,
            compact: !isWide,
          );
          final imageCard = const _HeroImageCard();

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                textColumn,
                const SizedBox(height: 32),
                imageCard,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 11, child: textColumn),
              const SizedBox(width: 48),
              Expanded(flex: 10, child: imageCard),
            ],
          );
        },
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({
    required this.onBooking,
    required this.onSchedule,
    required this.compact,
  });

  final VoidCallback onBooking;
  final VoidCallback onSchedule;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge kecil
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: PadelGoColors.primarySoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: PadelGoColors.primary.withValues(alpha: 0.25)),
          ),
          child: const Text(
            'PREMIUM COURTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: PadelGoColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Judul besar — "Lebih Seru" berwarna pink
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: compact ? 34 : 52,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: -1.2,
              color: PadelGoColors.textPrimary,
            ),
            children: const [
              TextSpan(text: 'Main Padel\n'),
              TextSpan(
                text: 'Lebih Seru',
                style: TextStyle(color: PadelGoColors.primary),
              ),
              TextSpan(text: ' di\nPadelGo.'),
            ],
          ),
        ),
        const SizedBox(height: 18),

        const Text(
          'PadelGo adalah lapangan padel premium dengan fasilitas modern, '
          'suasana komunitas yang hangat, dan booking online semudah 1 menit.',
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: PadelGoColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),

        // Tombol aksi
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: onBooking,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 52),
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text('Booking Sekarang'),
            ),
            OutlinedButton(
              onPressed: onSchedule,
              style: OutlinedButton.styleFrom(
                foregroundColor: PadelGoColors.textPrimary,
                side: const BorderSide(color: PadelGoColors.divider, width: 1.5),
                minimumSize: const Size(0, 52),
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text('Lihat Jadwal'),
            ),
          ],
        ),
        const SizedBox(height: 26),

        // Avatar + rating
        Row(
          children: [
            SizedBox(
              width: 88,
              height: 32,
              child: Stack(
                children: [
                  for (var i = 0; i < 3; i++)
                    Positioned(
                      left: i * 24.0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: [
                            PadelGoColors.primarySoft,
                            const Color(0xFFFFF3D6),
                            const Color(0xFFE3F2FD),
                          ][i],
                          child: Icon(Icons.person,
                              size: 16,
                              color: [
                                PadelGoColors.primary,
                                const Color(0xFFF59E0B),
                                const Color(0xFF1E88E5),
                              ][i]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: PadelGoColors.star, size: 17),
                    SizedBox(width: 3),
                    Text(
                      '4.9/5.0',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: PadelGoColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '200+ pemain aktif tiap minggu',
                  style: TextStyle(
                    fontSize: 12,
                    color: PadelGoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroImageCard extends StatelessWidget {
  const _HeroImageCard();

  @override
  Widget build(BuildContext context) {
    final court = context.watch<CourtProvider>().primaryCourt;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: PadelGoColors.primary.withValues(alpha: 0.14),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            CourtImage(
              colors: court?.galleryColors.first ??
                  AppConstants.defaultGalleryColors.first,
              asset: court?.assetImages.firstOrNull,
              height: 340,
              width: double.infinity,
            ),
            // Gradient gelap di bawah untuk keterbacaan badge
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 110,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: PadelGoColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Court A • Premium Indoor',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
