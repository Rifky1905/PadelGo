import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import 'section_container.dart';

/// Footer landing page — brand, kolom link, sosial media, copyright.
class FooterSection extends StatelessWidget {
  const FooterSection({super.key, this.onNavTap});

  /// Index menu: 0 Home, 1 Booking, 2 Contact, 3 Profile.
  final void Function(int index)? onNavTap;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              final brand = _brandBlock();
              final links = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _linkColumn('Menu', const [
                    'Home', 'Booking', 'Contact', 'Profile',
                  ], onTap: (i) => onNavTap?.call(i)),
                  const SizedBox(width: 48),
                  _linkColumn('Legal', const [
                    'Terms & Conditions',
                    'Privacy Policy',
                  ]),
                  const SizedBox(width: 48),
                  _socialColumn(),
                ],
              );

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [brand, const SizedBox(height: 28), links],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: brand),
                  Expanded(flex: 3, child: links),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            '© 2026 PadelGo. All rights reserved.',
            style: TextStyle(fontSize: 12, color: PadelGoColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _brandBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: PadelGoColors.pinkGradient,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.sports_tennis,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: PadelGoColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Lapangan padel premium di Depok.\nBooking mudah, main makin seru.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.55,
            color: PadelGoColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _linkColumn(String title, List<String> items,
      {void Function(int index)? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: PadelGoColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: onTap == null ? () {} : () => onTap(i),
              child: Text(
                items[i],
                style: const TextStyle(
                  fontSize: 12.5,
                  color: PadelGoColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _socialColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ikuti Kami',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: PadelGoColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final icon in [
              Icons.camera_alt_outlined,   // Instagram
              Icons.facebook_rounded,      // Facebook
              Icons.play_circle_outline,   // TikTok/YouTube
            ])
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: PadelGoColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: PadelGoColors.primary),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
