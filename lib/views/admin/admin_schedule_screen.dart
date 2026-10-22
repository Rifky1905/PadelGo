import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/court_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

/// Manajemen jadwal — lihat siapa yang booking tiap jam dan
/// tutup/buka slot operasional secara manual.
class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  late DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  List<DateTime> get _dates => List.generate(
        14,
        (i) => DateUtils.dateOnly(DateTime.now()).add(Duration(days: i)),
      );

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final court = context.watch<CourtProvider>().primaryCourt;
    final bookedBy = admin.bookedByFor(_selectedDate);
    final closed = admin.closedSlotsFor(_selectedDate);

    if (court == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Manajemen Jadwal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: PadelGoColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          court.name,
          style: const TextStyle(
            fontSize: 13.5,
            color: PadelGoColors.textSecondary,
          ),
        ),
        const SizedBox(height: 18),

        // Pemilih tanggal
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final date = _dates[i];
              final selected = DateUtils.isSameDay(date, _selectedDate);
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 56,
                  decoration: BoxDecoration(
                    color: selected ? PadelGoColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? PadelGoColors.primary
                          : PadelGoColors.divider,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Formatters.hariPendek(date),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : PadelGoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: selected
                              ? Colors.white
                              : PadelGoColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // Legenda
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _legend(PadelGoColors.availableBg, PadelGoColors.available,
                'Tersedia'),
            _legend(PadelGoColors.primarySoft, PadelGoColors.primary,
                'Dibooking'),
            _legend(const Color(0xFFFEE2E2), const Color(0xFFDC2626),
                'Ditutup'),
          ],
        ),
        const SizedBox(height: 14),

        // Grid slot
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.4,
          ),
          itemCount: AppConstants.closeHour - AppConstants.openHour,
          itemBuilder: (context, i) {
            final hour = AppConstants.openHour + i;
            final booker = bookedBy[hour];
            final isClosed = closed.contains(hour);
            final isBooked = booker != null;

            return _SlotRow(
              hour: hour,
              bookerName: booker,
              isClosed: isClosed,
              isBooked: isBooked,
              onToggleClosed: isBooked
                  ? null
                  : () => admin.toggleSlotClosed(_selectedDate, hour),
            );
          },
        ),
      ],
    );
  }

  Widget _legend(Color bg, Color fg, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: fg.withValues(alpha: 0.55)),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: PadelGoColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.hour,
    required this.bookerName,
    required this.isClosed,
    required this.isBooked,
    required this.onToggleClosed,
  });

  final int hour;
  final String? bookerName;
  final bool isClosed;
  final bool isBooked;
  final VoidCallback? onToggleClosed;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch ((isClosed, isBooked)) {
      (true, _) => (
          const Color(0xFFFEE2E2),
          const Color(0xFFDC2626),
          'Ditutup admin',
        ),
      (_, true) when bookerName != null => (
          PadelGoColors.primarySoft,
          PadelGoColors.primary,
          bookerName!,
        ),
      (_, true) => (
          PadelGoColors.bookedBg,
          PadelGoColors.booked,
          'Terisi',
        ),
      _ => (
          PadelGoColors.availableBg,
          PadelGoColors.available,
          'Tersedia',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Text(
            Formatters.jam(hour),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
          if (onToggleClosed != null)
            GestureDetector(
              onTap: onToggleClosed,
              child: Icon(
                isClosed ? Icons.lock_open_outlined : Icons.block_outlined,
                size: 17,
                color: fg,
              ),
            ),
        ],
      ),
    );
  }
}
