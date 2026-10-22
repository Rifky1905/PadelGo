import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';

/// Navigation bar landing page — responsif: menu tengah di desktop,
/// hamburger drawer di mobile.
class LandingNavbar extends StatelessWidget {
  const LandingNavbar({
    super.key,
    required this.onNavTap,
    required this.onBooking,
    required this.onMenuPressed,
    this.isCompact = false,
  });

  /// Dipanggil dengan index menu: 0 Home, 1 Booking, 2 Contact, 3 Profile.
  final void Function(int index) onNavTap;
  final VoidCallback onBooking;
  final VoidCallback onMenuPressed;
  final bool isCompact;

  static const _menus = ['Home', 'Booking', 'Contact', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: PadelGoColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Row(
            children: [
              // Logo + nama brand
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: PadelGoColors.pinkGradient,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.sports_tennis,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: PadelGoColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              // Menu tengah (desktop)
              if (!isCompact) ...[
                const Spacer(),
                for (var i = 0; i < _menus.length; i++)
                  _NavItem(label: _menus[i], onTap: () => onNavTap(i)),
                const Spacer(),
              ] else
                const Spacer(),

              // Tombol aksi pink
              if (!isCompact)
                _BookingPill(onPressed: onBooking)
              else
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: PadelGoColors.textPrimary,
                  onPressed: onMenuPressed,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Drawer menu untuk tampilan mobile.
class LandingDrawer extends StatelessWidget {
  const LandingDrawer({
    super.key,
    required this.onNavTap,
    required this.onBooking,
  });

  final void Function(int index) onNavTap;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: PadelGoColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            for (var i = 0; i < LandingNavbar._menus.length; i++)
              ListTile(
                title: Text(
                  LandingNavbar._menus[i],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onNavTap(i);
                },
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _BookingPill(onPressed: () {
                Navigator.of(context).pop();
                onBooking();
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: PadelGoColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingPill extends StatelessWidget {
  const _BookingPill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
      ),
      child: const Text('Booking Sekarang'),
    );
  }
}
