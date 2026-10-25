import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

/// Halaman set password baru — tampil saat user membuka link reset
/// password dari email (event `passwordRecovery` Supabase Auth).
/// Setelah password tersimpan, sesi recovery di-logout dan user
/// diminta login ulang dengan password baru.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.onDone});

  /// Dipanggil setelah proses selesai (sukses maupun dibatalkan).
  final VoidCallback onDone;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  String? _localError;

  @override
  void dispose() {
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pass = _passController.text;
    setState(() => _localError = null);
    if (pass.length < 6) {
      setState(() => _localError = 'Password minimal 6 karakter.');
      return;
    }
    if (pass != _confirmController.text) {
      setState(() => _localError = 'Konfirmasi password tidak sama.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.updatePassword(pass);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Password berhasil diperbarui! Silakan login kembali.'),
        ),
      );
      auth.logout();
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final error = _localError ?? auth.error;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF5C8A), Color(0xFFE91E63), Color(0xFFC2185B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_reset,
                        color: Colors.white, size: 56),
                    const SizedBox(height: 16),
                    const Text(
                      'Buat Password Baru',
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
                      'Masukkan password baru untuk akun PadelGo kamu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 32,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Label('Password Baru'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passController,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              hintText: 'Minimal 6 karakter',
                              prefixIcon: const Icon(Icons.lock_outline),
                              fillColor: PadelGoColors.background,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _Label('Konfirmasi Password'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _confirmController,
                            obscureText: _obscure,
                            decoration: const InputDecoration(
                              hintText: 'Ulangi password baru',
                              prefixIcon: Icon(Icons.lock_outline),
                              fillColor: PadelGoColors.background,
                            ),
                          ),
                          if (error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: PadelGoColors.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: PadelGoColors.primary,
                                      size: 17),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: PadelGoColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: auth.isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Simpan Password Baru'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              context.read<AuthProvider>().logout();
                              widget.onDone();
                            },
                            child: const Text('Batal, kembali ke halaman utama'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
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
