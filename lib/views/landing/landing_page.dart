import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/court_provider.dart';
import '../auth/login_screen.dart';
import '../user/booking/booking_screen.dart';
import 'widgets/cta_banner.dart';
import 'widgets/facility_section.dart';
import 'widgets/footer_section.dart';
import 'widgets/gallery_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/info_bar.dart';
import 'widgets/landing_navbar.dart';
import 'widgets/location_section.dart';

/// Landing page PadelGo — responsif untuk Web & Mobile.
/// Index nav: 0 Home, 1 Booking, 2 Contact, 3 Profile.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scrollController = ScrollController();
  final _homeKey = GlobalKey();
  final _contactKey = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToBooking() {
    final loggedIn = context.read<AuthProvider>().isLoggedIn;
    if (!loggedIn) {
      // Booking butuh akun — arahkan ke login dulu.
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const LoginScreen(fromBooking: true)),
      );
      return;
    }
    final court = context.read<CourtProvider>().primaryCourt;
    if (court == null) {
      // Data lapangan belum termuat — muat ulang lalu minta coba lagi.
      context.read<CourtProvider>().loadCourts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Memuat data lapangan, coba sebentar lagi...')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookingScreen(court: court)),
    );
  }

  void _goToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        _scrollTo(_homeKey);
      case 1:
        _goToBooking();
      case 2:
        _scrollTo(_contactKey);
      case 3:
        _goToLogin();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 900;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: isCompact
          ? LandingDrawer(onNavTap: _onNavTap, onBooking: _goToBooking)
          : null,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: LandingNavbar(
              isCompact: isCompact,
              onNavTap: _onNavTap,
              onBooking: _goToBooking,
              onMenuPressed: () =>
                  _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KeyedSubtree(key: _homeKey, child: HeroSection(
                    onBooking: _goToBooking,
                    onSchedule: _goToBooking,
                  )),
                  const InfoBar(),
                  const FacilitySection(),
                  const GallerySection(),
                  KeyedSubtree(key: _contactKey, child: const LocationSection()),
                  CtaBanner(onBooking: _goToBooking),
                  FooterSection(onNavTap: _onNavTap),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
