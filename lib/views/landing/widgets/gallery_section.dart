import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../widgets/court_image.dart';
import 'section_container.dart';

/// Section "Suasana di PadelGo" — galeri: 1 foto besar kiri,
/// 2 foto tumpuk kecil kanan.
class GallerySection extends StatelessWidget {
  const GallerySection({super.key});

  // Foto suasana padel (placeholder Unsplash, fallback gradasi jika offline).
  static const _photoAction =
      'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=900&q=80';
  static const _photoRacket =
      'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=600&q=80';

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'Suasana di PadelGo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: PadelGoColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lihat langsung keseruan bermain di lapangan kami.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: PadelGoColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              const big = _GalleryPhoto.network(
                url: _photoAction,
                height: 360,
                label: 'Aksi pemain di Court A',
              );
              final smallTop = const _GalleryPhoto.network(
                url: _photoRacket,
                height: 172,
                label: 'Raket & bola padel',
              );
              final smallBottom = const _GalleryPhoto.asset(
                path: AppConstants.courtImageAsset,
                height: 172,
                label: 'Tampilan lapangan',
              );

              if (!isWide) {
                return Column(
                  children: [
                    const _GalleryPhoto.network(
                      url: _photoAction,
                      height: 230,
                      label: 'Aksi pemain di Court A',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: smallTop),
                        const SizedBox(width: 14),
                        Expanded(child: smallBottom),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: big),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        smallTop,
                        const SizedBox(height: 16),
                        smallBottom,
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Foto galeri dengan label overlay — dukung network & asset,
/// fallback ke gradasi PadelGo jika gambar gagal dimuat.
class _GalleryPhoto extends StatelessWidget {
  const _GalleryPhoto.network({
    required String url,
    required this.height,
    required this.label,
  })  : asset = null,
        networkUrl = url;

  const _GalleryPhoto.asset({
    required String path,
    required this.height,
    required this.label,
  })  : asset = path,
        networkUrl = null;

  final String? networkUrl;
  final String? asset;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (asset != null)
              CourtImage(
                colors: const [Color(0xFFE91E63), Color(0xFF880E4F)],
                asset: asset,
              )
            else
              Image.network(
                networkUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _fallback(),
                errorBuilder: (_, _, _) => _fallback(),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 10,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => const CourtImage(
        colors: [Color(0xFFAD1457), Color(0xFF6A1B4D)],
      );
}
