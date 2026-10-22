import 'package:flutter/material.dart';

import '../models/court.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'court_image.dart';

/// Kartu daftar lapangan di beranda — foto, nama, harga, rating, jarak.
class CourtCard extends StatelessWidget {
  const CourtCard({super.key, required this.court, this.onTap});

  final Court court;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: PadelGoColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CourtImage(
                  colors: court.galleryColors.first,
                  asset:
                      court.assetImages.isNotEmpty ? court.assetImages.first : null,
                  height: 150,
                  width: double.infinity,
                  borderRadius: 16,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
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
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          court.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: PadelGoColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.star_rounded,
                          color: PadelGoColors.star, size: 18),
                      const SizedBox(width: 2),
                      Text(
                        court.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: PadelGoColors.textPrimary,
                        ),
                      ),
                      Text(
                        ' (${court.reviewCount})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: PadelGoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: PadelGoColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          court.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: PadelGoColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        Formatters.rupiah(court.pricePerHour),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PadelGoColors.primary,
                        ),
                      ),
                      const Text(
                        ' /jam',
                        style: TextStyle(
                          fontSize: 12,
                          color: PadelGoColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.directions_run,
                          size: 14, color: PadelGoColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${court.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: PadelGoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
