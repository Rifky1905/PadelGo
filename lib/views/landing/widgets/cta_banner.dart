import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import 'section_container.dart';

/// Banner CTA gelap glossy dengan aksen gradasi pink — "Siap Bermain?".
class CtaBanner extends StatelessWidget {
  const CtaBanner({super.key, required this.onBooking, this.onWhatsApp});

  final VoidCallback onBooking;
  final VoidCallback? onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111827), Color(0xFF1F2937)],
          ),
          boxShadow: [
            BoxShadow(
              color: PadelGoColors.primary.withValues(alpha: 0.18),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glow pink dekoratif
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PadelGoColors.primary.withValues(alpha: 0.4),
                      PadelGoColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C3AED).withValues(alpha: 0.3),
                      const Color(0xFF7C3AED).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            // Konten
            Column(
              children: [
                const Text(
                  'Siap Bermain?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Amankan slot favoritmu hari ini. Booking lapangan\nPadelGo cuma butuh 1 menit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
                const SizedBox(height: 26),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: onBooking,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text('Booking Lapangan'),
                    ),
                    ElevatedButton.icon(
                      onPressed: onWhatsApp ?? () {},
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('WhatsApp Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF374151)),
                        minimumSize: const Size(0, 50),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
