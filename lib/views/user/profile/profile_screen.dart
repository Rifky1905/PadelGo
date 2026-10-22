import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../utils/app_theme.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';
import 'help_center_screen.dart';

/// Halaman profil — ringkasan akun, member, pengaturan, logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Kartu identitas
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PadelGoColors.divider),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: PadelGoColors.primarySoft,
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
                      ? Text(
                          user?.initials ?? 'P',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: PadelGoColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '-',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: PadelGoColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user?.email ?? '-',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: PadelGoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.phone ?? '-',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: PadelGoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Kartu member & poin
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: PadelGoColors.pinkGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: PadelGoColors.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_outlined,
                    color: Colors.white, size: 34),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.memberTier ?? 'Member',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kumpulkan poin dari tiap booking untuk naik tier.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${user?.points ?? 0}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'POIN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu pengaturan
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PadelGoColors.divider),
            ),
            child: Column(
              children: [
                _menuItem(
                  Icons.manage_accounts_outlined,
                  'Pengaturan Akun',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  ),
                ),
                const Divider(indent: 56),
                _menuItem(
                  Icons.help_outline,
                  'Pusat Bantuan & FAQ',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const HelpCenterScreen()),
                  ),
                ),
                const Divider(indent: 56),
                _menuItem(
                  Icons.info_outline,
                  'Tentang PadelGo',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
                const Divider(indent: 56),
                _menuItem(
                  Icons.logout_rounded,
                  'Keluar',
                  color: PadelGoColors.primary,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog konfirmasi sebelum logout.
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari PadelGo?'),
        content: const Text(
          'Sesi kamu akan diakhiri. Kamu bisa masuk kembali kapan saja.',
          style: TextStyle(
            fontSize: 13.5,
            color: PadelGoColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 42),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label,
      {Color? color, String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? PadelGoColors.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: color ?? PadelGoColors.textPrimary,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                color: PadelGoColors.textHint,
              ),
            ),
      trailing: const Icon(Icons.chevron_right,
          color: PadelGoColors.textHint, size: 20),
      onTap: onTap ?? () {},
    );
  }
}
