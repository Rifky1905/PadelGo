import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/supabase_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/qris_image.dart';

/// Pengaturan QRIS pembayaran — admin mengunggah / memperbarui gambar
/// QRIS yang langsung tampil di halaman checkout user.
class AdminQrisScreen extends StatefulWidget {
  const AdminQrisScreen({super.key});

  @override
  State<AdminQrisScreen> createState() => _AdminQrisScreenState();
}

class _AdminQrisScreenState extends State<AdminQrisScreen> {
  bool _uploading = false;

  Future<void> _upload() async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
    );
    if (picked == null || !mounted) return;
    final ext = picked.name.split('.').last.toLowerCase();
    final safeExt = {'jpg', 'jpeg', 'png', 'webp'}.contains(ext) ? ext : 'png';

    setState(() => _uploading = true);
    try {
      await SupabaseService.uploadQris(await picked.readAsBytes(), safeExt);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('QRIS berhasil diperbarui.'),
          backgroundColor: PadelGoColors.available,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah QRIS: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'QRIS Pembayaran',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: PadelGoColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Unggah kode QRIS operasional lapangan. Gambar terbaru langsung '
          'tampil di halaman pembayaran pemain.',
          style: TextStyle(fontSize: 13.5, color: PadelGoColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PadelGoColors.divider),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        color: PadelGoColors.primary,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'QRIS Aktif',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PadelGoColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const QrisImage(size: 260),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _uploading ? null : _upload,
                    icon: _uploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.upload_rounded, size: 20),
                    label: Text(
                      _uploading ? 'Mengunggah...' : 'Unggah / Perbarui QRIS',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Format JPG, PNG, atau WEBP. Pastikan kode QR terlihat jelas '
                    'dan tidak terpotong.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: PadelGoColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
