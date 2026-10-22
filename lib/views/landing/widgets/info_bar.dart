import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import 'section_container.dart';

/// Strip 4 kartu info cepat: harga, jam operasional, lokasi, standar.
class InfoBar extends StatelessWidget {
  const InfoBar({super.key});

  static const _items = [
    _InfoItem(Icons.payments_outlined, 'Rp 150k/jam', 'Harga Mulai'),
    _InfoItem(Icons.schedule_outlined, '06:00 - 22:00', 'Jam Operasional'),
    _InfoItem(Icons.location_on_outlined, 'Depok, Jawa Barat', 'Lokasi Utama'),
    _InfoItem(Icons.verified_outlined, 'Standar WPT', 'Fasilitas'),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          if (isWide) {
            return Row(
              children: [
                for (var i = 0; i < _items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(child: _InfoCard(item: _items[i])),
                ],
              ],
            );
          }
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [for (final item in _items) _InfoCard(item: item)],
          );
        },
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.icon, this.value, this.label);
  final IconData icon;
  final String value;
  final String label;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PadelGoColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PadelGoColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: PadelGoColors.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: PadelGoColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: PadelGoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
