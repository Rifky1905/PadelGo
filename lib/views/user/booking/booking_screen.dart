import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/court.dart';
import '../../../providers/court_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/time_slot_tile.dart';
import 'payment_screen.dart';

/// Halaman pemilihan tanggal & slot waktu per jam.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.court});

  final Court court;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  final Set<int> _selectedHours = {};

  Court get court => widget.court;

  List<DateTime> get _dates => List.generate(
        14,
        (i) => DateUtils.dateOnly(DateTime.now()).add(Duration(days: i)),
      );

  @override
  void initState() {
    super.initState();
    // Mode DB: muat slot terisi dari Supabase untuk tanggal awal.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourtProvider>().loadOccupied(court.id, _selectedDate);
    });
  }

  /// Slot terisi — dari Supabase (bookings aktif + slot ditutup admin).
  Set<int> _occupiedFor(BuildContext context) =>
      context.watch<CourtProvider>().occupiedFor(court.id, _selectedDate);

  /// true jika waktu mulai slot sudah lewat — booking bersifat
  /// real-time: jam yang sudah berlalu tidak bisa dipilih.
  bool _isPastHour(int hour) {
    final now = DateTime.now();
    if (!DateUtils.isSameDay(_selectedDate, now)) return false;
    final slotStart = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, hour);
    return !slotStart.isAfter(now);
  }

  void _toggleSlot(int hour) {
    if (_isPastHour(hour)) return;
    setState(() {
      if (!_selectedHours.remove(hour)) _selectedHours.add(hour);
    });
  }

  void _proceed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          court: court,
          date: _selectedDate,
          slotHours: _selectedHours.toList()..sort(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final occupied = _occupiedFor(context);
    final total = court.pricePerHour * _selectedHours.length;

    return Scaffold(
      appBar: AppBar(title: Text(court.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pemilihan tanggal interaktif — 14 hari ke depan
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Text(
              'Pilih Tanggal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: PadelGoColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _dates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final date = _dates[i];
                final selected = DateUtils.isSameDay(date, _selectedDate);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                      _selectedHours.clear();
                    });
                    context
                        .read<CourtProvider>()
                        .loadOccupied(court.id, date);
                  },
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
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: PadelGoColors.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Formatters.hariPendek(date),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : PadelGoColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? Colors.white
                                : PadelGoColors.textPrimary,
                          ),
                        ),
                        Text(
                          Formatters.tanggalPendek(date).split(' ')[1],
                          style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? Colors.white.withValues(alpha: 0.85)
                                : PadelGoColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Legenda status slot
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pilih Jam',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PadelGoColors.textPrimary,
                    ),
                  ),
                ),
                _legend(Colors.white, PadelGoColors.divider, 'Tersedia'),
                const SizedBox(width: 10),
                _legend(PadelGoColors.bookedBg, PadelGoColors.booked, 'Terisi'),
                const SizedBox(width: 10),
                _legend(PadelGoColors.primary, PadelGoColors.primary, 'Dipilih'),
                const SizedBox(width: 10),
                _legend(PadelGoColors.bookedBg, PadelGoColors.textHint, 'Lewat'),
              ],
            ),
          ),

          // Grid slot waktu — compact
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemCount: AppConstants.closeHour - AppConstants.openHour,
              itemBuilder: (context, i) {
                final hour = AppConstants.openHour + i;
                final state = _isPastHour(hour)
                    ? SlotState.past
                    : occupied.contains(hour)
                        ? SlotState.booked
                        : _selectedHours.contains(hour)
                            ? SlotState.selected
                            : SlotState.available;
                return TimeSlotTile(
                  hour: hour,
                  state: state,
                  onTap: () => _toggleSlot(hour),
                );
              },
            ),
          ),
        ],
      ),

      // Bottom bar ringkasan + lanjut
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedHours.isEmpty
                          ? 'Belum ada slot dipilih'
                          : '${_selectedHours.length} jam • ${Formatters.tanggalPendek(_selectedDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: PadelGoColors.textSecondary,
                      ),
                    ),
                    Text(
                      Formatters.rupiah(total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: PadelGoColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedHours.isEmpty ? null : _proceed,
                  child: const Text('Lanjutkan Pembayaran'),
                ),
              ),
            ],
          ),
        ),
      ),
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
            border: Border.all(color: fg),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: PadelGoColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
