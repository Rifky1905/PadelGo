import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/court_provider.dart';
import 'booking/booking_screen.dart';
import 'history/booking_history_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';

/// Host navigasi bawah user: Beranda, Booking, Riwayat, Profil.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.initialIndex = 0});

  final int initialIndex;

  /// Pindah ke tab Riwayat dari mana saja (setelah booking sukses).
  static void goToHistory(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainNavigation(initialIndex: 2),
      ),
      (route) => false,
    );
  }

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _index = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    // Mode DB: sinkronkan riwayat booking user dari Supabase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<BookingProvider>()
          .loadBookings(context.read<AuthProvider>().user?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final court = context.watch<CourtProvider>().primaryCourt;
    final pages = [
      const HomeScreen(),
      // Tab Booking langsung menampilkan jadwal lapangan utama.
      court == null
          ? const Center(child: CircularProgressIndicator())
          : BookingScreen(court: court),
      const BookingHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
