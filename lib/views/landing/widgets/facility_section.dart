import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import 'section_container.dart';

/// Section "Fasilitas Lengkap" — grid 4 kartu fasilitas.
class FacilitySection extends StatelessWidget {
  const FacilitySection({super.key});

  static const _facilities = [
    _FacilityItem(
      Icons.shower_outlined,
      'Shower Room',
      'Ruang bilas bersih dengan air hangat & amenities.',
    ),
    _FacilityItem(
      Icons.local_parking,
      'Parkir Luas',
      'Area parkir aman untuk mobil & motor.',
    ),
    _FacilityItem(
      Icons.storefront_outlined,
      'Pro Shop',
      'Sewa & beli raket, bola, dan aksesori padel.',
    ),
    _FacilityItem(
      Icons.local_cafe_outlined,
      'Cafeteria',
      'Kopi, snack, dan minuman segar pasca-main.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fasilitas Lengkap',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: PadelGoColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Semua yang kamu butuhkan untuk pengalaman main terbaik.',
                      style: TextStyle(
                        fontSize: 14,
                        color: PadelGoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Lihat Semua →',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: PadelGoColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: cols == 1 ? 3.4 : 1.35,
                ),
                itemCount: _facilities.length,
                itemBuilder: (_, i) =>
                    _FacilityCard(item: _facilities[i]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FacilityItem {
  const _FacilityItem(this.icon, this.title, this.desc);
  final IconData icon;
  final String title;
  final String desc;
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({required this.item});

  final _FacilityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PadelGoColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PadelGoColors.primarySoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(item.icon, color: PadelGoColors.primary, size: 23),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: PadelGoColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: PadelGoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
