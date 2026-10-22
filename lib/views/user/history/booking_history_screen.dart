import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/booking.dart';
import '../../../providers/booking_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/booking_card.dart';
import '../booking/ticket_screen.dart';

/// Halaman riwayat pesanan — tab "Mendatang" dan "Selesai".
class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Pesanan'),
          bottom: TabBar(
            labelColor: PadelGoColors.primary,
            unselectedLabelColor: PadelGoColors.textSecondary,
            indicatorColor: PadelGoColors.primary,
            indicatorWeight: 3,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            tabs: const [
              Tab(text: 'Mendatang'),
              Tab(text: 'Selesai / Batal'),
            ],
          ),
        ),
        body: Consumer<BookingProvider>(
          builder: (context, provider, _) => TabBarView(
            children: [
              _BookingList(
                bookings: provider.upcoming,
                emptyMessage: 'Belum ada pesanan aktif.\nYuk booking lapangan!',
              ),
              _BookingList(
                bookings: provider.completed,
                emptyMessage: 'Belum ada pesanan yang selesai.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
  });

  final List<Booking> bookings;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: PadelGoColors.textHint.withValues(alpha: 0.5)),
            const SizedBox(height: 14),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: PadelGoColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, i) {
        final booking = bookings[i];
        return BookingCard(
          booking: booking,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TicketScreen(booking: booking)),
          ),
        );
      },
    );
  }
}
