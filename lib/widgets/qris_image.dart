import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../utils/app_theme.dart';

/// Gambar QRIS pembayaran terbaru yang diatur admin.
///
/// Berlangganan `app_settings` via Supabase Realtime, jadi gambar
/// langsung berganti saat admin mengunggah QRIS baru.
class QrisImage extends StatefulWidget {
  const QrisImage({super.key, this.size = 220});

  final double size;

  @override
  State<QrisImage> createState() => _QrisImageState();
}

class _QrisImageState extends State<QrisImage> {
  late final Stream<String?> _stream = SupabaseService.qrisUrlStream();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return _frame(const CircularProgressIndicator(strokeWidth: 2.4));
        }
        final url = snap.data;
        if (snap.hasError || url == null || url.isEmpty) {
          return _frame(
            _placeholder(
              snap.hasError
                  ? 'Gagal memuat QRIS'
                  : 'QRIS belum diatur pengelola',
            ),
          );
        }
        return _frame(
          Image.network(
            url,
            key: ValueKey(url),
            fit: BoxFit.contain,
            loadingBuilder: (c, child, p) => p == null
                ? child
                : const CircularProgressIndicator(strokeWidth: 2.4),
            errorBuilder: (c, e, s) => _placeholder('Gagal memuat QRIS'),
          ),
        );
      },
    );
  }

  Widget _frame(Widget child) => Container(
    width: widget.size,
    height: widget.size,
    padding: const EdgeInsets.all(10),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: PadelGoColors.divider),
    ),
    child: child,
  );

  Widget _placeholder(String text) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(
        Icons.qr_code_2_rounded,
        size: 56,
        color: PadelGoColors.textHint,
      ),
      const SizedBox(height: 8),
      Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12.5,
          color: PadelGoColors.textSecondary,
        ),
      ),
    ],
  );
}
