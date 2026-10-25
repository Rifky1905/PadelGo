import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/formatters.dart';

enum SlotState { available, booked, selected, past }

/// Satu tile slot waktu per jam pada grid pemilihan jadwal.
/// - Tersedia: putih bersih + border tipis
/// - Terisi: abu-abu redup (disabled)
/// - Dipilih: pink PadelGo + teks putih
class TimeSlotTile extends StatelessWidget {
  const TimeSlotTile({
    super.key,
    required this.hour,
    required this.state,
    this.onTap,
  });

  final int hour;
  final SlotState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (state) {
      SlotState.selected => (
          PadelGoColors.primary,
          Colors.white,
          PadelGoColors.primary,
        ),
      SlotState.booked => (
          PadelGoColors.bookedBg,
          PadelGoColors.booked,
          PadelGoColors.divider,
        ),
      // Jam yang sudah lewat — redup, tidak bisa diklik.
      SlotState.past => (
          PadelGoColors.bookedBg,
          PadelGoColors.textHint,
          PadelGoColors.divider,
        ),
      SlotState.available => (
          Colors.white,
          PadelGoColors.textPrimary,
          PadelGoColors.divider,
        ),
    };

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: state == SlotState.booked || state == SlotState.past
            ? null
            : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
            boxShadow: state == SlotState.selected
                ? [
                    BoxShadow(
                      color: PadelGoColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${Formatters.jam(hour)} - ${Formatters.jam(hour + 1)}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                  decoration: state == SlotState.booked
                      ? TextDecoration.lineThrough
                      : state == SlotState.past
                          ? TextDecoration.lineThrough
                          : null,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                switch (state) {
                  SlotState.available => 'Tersedia',
                  SlotState.booked => 'Terisi',
                  SlotState.selected => 'Dipilih',
                  SlotState.past => 'Lewat',
                },
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: state == SlotState.selected
                      ? Colors.white.withValues(alpha: 0.85)
                      : fg.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
