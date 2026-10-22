import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Judul section dengan opsi tombol "Lihat Semua".
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: PadelGoColors.textPrimary,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: PadelGoColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
