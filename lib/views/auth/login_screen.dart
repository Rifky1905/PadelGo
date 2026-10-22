import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'register_screen.dart';

/// Halaman login PadelGo — gaya Stellar: background gradasi pink,
/// branding di atas, dan kartu form putih dengan pemilih role inline.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.initialRole = AppRole.user,
    this.fromBooking = false,
  });

  final AppRole initialRole;

  /// True jika user diarahkan ke sini karena ingin booking.
  final bool fromBooking;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _remember = false;
  late AppRole _role = widget.initialRole;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
      role: _role,
    );
    // Jika halaman ini dipush (dari landing), tutup agar kembali
    // ke navigasi yang sudah dirender oleh AuthGate.
    if (success && mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canPop = Navigator.canPop(context);

    return Scaffold(
      body: Container(
        // Background gradasi pink penuh
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF5C8A), Color(0xFFE91E63), Color(0xFFC2185B)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Lingkaran dekoratif
              Positioned(
                top: -70,
                right: -60,
                child: _DecorCircle(size: 220, opacity: 0.14),
              ),
              Positioned(
                bottom: -50,
                left: -40,
                child: _DecorCircle(size: 170, opacity: 0.10),
              ),

              // Konten terpusat
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Link kembali
                        if (canPop)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.arrow_back,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Kembali ke Halaman Utama',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white
                                          .withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 26),

                        // Logo putih + nama brand
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.sports_tennis,
                                    color: PadelGoColors.primary,
                                    size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'PadelGo',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: PadelGoColors.textPrimary,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Badge kecil
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Text(
                              'BOOKING LAPANGAN PADEL ONLINE',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Judul + subjudul
                        const Text(
                          'Masuk ke Akun PadelGo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Silakan pilih peran dan masukkan kredensial\nuntuk membuka sesi pemain atau pengelola.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Kartu form putih
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.18),
                                blurRadius: 32,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              // Info: booking butuh akun
                              if (widget.fromBooking) ...[
                                Container(
                                  padding: const EdgeInsets.all(11),
                                  margin:
                                      const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: PadelGoColors.primarySoft,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: PadelGoColors.primary,
                                          size: 17),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Masuk dulu untuk melanjutkan booking lapangan.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                PadelGoColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Dua kartu role berdampingan
                              Row(
                                children: [
                                  Expanded(
                                    child: _RolePickerCard(
                                      icon: Icons.sports_tennis,
                                      title: 'User / Pemain',
                                      subtitle: 'Booking & Riwayat',
                                      selected: _role == AppRole.user,
                                      onTap: () => setState(
                                          () => _role = AppRole.user),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _RolePickerCard(
                                      icon: Icons
                                          .admin_panel_settings_outlined,
                                      title: 'Admin Lapangan',
                                      subtitle: 'Kelola & Laporan',
                                      selected: _role == AppRole.admin,
                                      onTap: () => setState(
                                          () => _role = AppRole.admin),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Field email
                              const _FieldLabel('Nama Pengguna / Email'),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _emailController,
                                keyboardType:
                                    TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'contoh: kamu@padelgo.id',
                                  prefixIcon:
                                      Icon(Icons.person_outline),
                                  fillColor: PadelGoColors.background,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Field password
                              const _FieldLabel('Kata Sandi'),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan kata sandi',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline),
                                  fillColor: PadelGoColors.background,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscure = !_obscure),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Ingat sesi + lupa sandi
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: _remember,
                                      onChanged: (v) => setState(
                                          () => _remember = v ?? false),
                                      activeColor:
                                          PadelGoColors.primary,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize
                                              .shrinkWrap,
                                      side: const BorderSide(
                                          color:
                                              PadelGoColors.textHint),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Ingat Sesi Perangkat ini',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          PadelGoColors.textSecondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Text(
                                      'Lupa Kata Sandi?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: PadelGoColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (auth.error != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(11),
                                  decoration: BoxDecoration(
                                    color: PadelGoColors.primarySoft,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: PadelGoColors.primary,
                                          size: 17),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          auth.error!,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: PadelGoColors
                                                .primaryDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),

                              // Tombol masuk besar pink
                              ElevatedButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () => _login(),
                                style: ElevatedButton.styleFrom(
                                  minimumSize:
                                      const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('Masuk ke PadelGo'),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward,
                                              size: 18),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 16),

                              // Daftar akun (hanya role user)
                              if (_role == AppRole.user)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Belum punya akun PadelGo? ',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color:
                                            PadelGoColors.textSecondary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context
                                            .read<AuthProvider>()
                                            .clearError();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Daftar Akun Baru Sekarang',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: PadelGoColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label kecil tebal di atas field, seperti referensi.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: PadelGoColors.textPrimary,
      ),
    );
  }
}

/// Kartu pemilih role di dalam form (berdampingan, seperti referensi).
class _RolePickerCard extends StatelessWidget {
  const _RolePickerCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PadelGoColors.primarySoft : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? PadelGoColors.primary
                  : PadelGoColors.divider,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: selected
                    ? PadelGoColors.primary
                    : PadelGoColors.textHint,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? PadelGoColors.primaryDark
                      : PadelGoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: PadelGoColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lingkaran dekoratif semi-transparan untuk background.
class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
