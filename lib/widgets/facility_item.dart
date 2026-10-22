import 'package:flutter/material.dart';

import '../models/facility.dart';
import '../utils/app_theme.dart';

/// Ikon + label fasilitas di halaman detail lapangan.
class FacilityItem extends StatelessWidget {
  const FacilityItem({super.key, required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: PadelGoColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(facility.icon, color: PadelGoColors.primary, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          facility.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: PadelGoColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
