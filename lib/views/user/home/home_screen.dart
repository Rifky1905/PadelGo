import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/court_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../widgets/court_card.dart';
import '../../../widgets/section_title.dart';
import '../detail/court_detail_screen.dart';

/// Halaman beranda — sapaan, promo, kategori, pencarian, daftar lapangan.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController(viewportFraction: 0.88);
  int _promoIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showNotifications(BuildContext context) {
    const notifications = [
      (
        Icons.local_offer_outlined,
        'Diskon 30% Jam Pagi!',
        'Berlaku sampai akhir bulan di semua slot sebelum 10:00.',
      ),
      (
        Icons.event_available_outlined,
        'Slot Akhir Pekan Dibuka',
        'Jadwal Sabtu & Minggu untuk 2 pekan ke depan sudah tersedia.',
      ),
      (
        Icons.emoji_events_outlined,
        'PadelGo Weekend Cup',
        'Turnamen komunitas 25-26 Okt. Daftarkan tim kamu sekarang!',
      ),
    ];
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: PadelGoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              for (final n in notifications)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: PadelGoColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(n.$1,
                            color: PadelGoColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.$2,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: PadelGoColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              n.$3,
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: PadelGoColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final courtProvider = context.watch<CourtProvider>();
    final courts = courtProvider.courts;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header: sapaan + avatar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Halo, selamat datang 👋',
                            style: TextStyle(
                              fontSize: 13,
                              color: PadelGoColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.name ?? 'Pemain Padel',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: PadelGoColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tombol notifikasi
                    Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: PadelGoColors.divider),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            size: 21, color: PadelGoColors.textPrimary),
                        onPressed: () => _showNotifications(context),
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: PadelGoColors.primarySoft,
                      backgroundImage: user?.avatarUrl != null
                          ? NetworkImage(user!.avatarUrl!)
                          : null,
                      child: user?.avatarUrl == null
                          ? Text(
                              user?.initials ?? 'P',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: PadelGoColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            // Search bar + tombol filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) =>
                            context.read<CourtProvider>().setSearchQuery(v),
                        decoration: const InputDecoration(
                          hintText: 'Cari lapangan padel...',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Banner promo gradasi pink
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 130,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: AppConstants.promos.length,
                      onPageChanged: (i) => setState(() => _promoIndex = i),
                      itemBuilder: (context, i) {
                        final promo = AppConstants.promos[i];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: promo.colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      promo.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      promo.subtitle,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.35,
                                        color: Colors.white
                                            .withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.sports_tennis,
                                size: 52,
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      AppConstants.promos.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _promoIndex == i ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _promoIndex == i
                              ? PadelGoColors.primary
                              : PadelGoColors.divider,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Daftar lapangan
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: const SectionTitle(title: 'Lapangan'),
              ),
            ),
            if (courts.isEmpty && courtProvider.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (courts.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'Tidak ada lapangan yang cocok.\nCoba kata kunci lain.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: PadelGoColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: courts.length,
                itemBuilder: (context, i) {
                  final court = courts[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CourtCard(
                      court: court,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CourtDetailScreen(court: court),
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}
