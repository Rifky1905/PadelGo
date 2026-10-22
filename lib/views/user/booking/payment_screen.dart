import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/booking.dart';
import '../../../models/court.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/court_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/qris_image.dart';
import 'ticket_screen.dart';

/// Halaman ringkasan pesanan & pemilihan metode pembayaran.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.court,
    required this.date,
    required this.slotHours,
  });

  final Court court;
  final DateTime date;
  final List<int> slotHours;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.qris;
  bool _processing = false;

  /// Bukti pembayaran yang diupload user (wajib sebelum bayar).
  Uint8List? _proofBytes;
  String? _proofName;

  String get _proofExt {
    final ext = _proofName?.split('.').last.toLowerCase() ?? 'jpg';
    return {'jpg', 'jpeg', 'png', 'webp'}.contains(ext) ? ext : 'jpg';
  }

  double get _subtotal => widget.court.pricePerHour * widget.slotHours.length;
  double get _serviceFee => 5000;
  double get _total => _subtotal + _serviceFee;

  String get _timeRange {
    final sorted = [...widget.slotHours]..sort();
    return '${Formatters.jam(sorted.first)} - ${Formatters.jam(sorted.last + 1)}';
  }

  IconData _methodIcon(PaymentMethod m) => switch (m) {
        PaymentMethod.qris => Icons.qr_code_2_rounded,
        PaymentMethod.gopay => Icons.account_balance_wallet_outlined,
        PaymentMethod.ovo => Icons.wallet_outlined,
        PaymentMethod.bca || PaymentMethod.mandiri =>
          Icons.account_balance_outlined,
      };

  /// Pilih foto bukti pembayaran dari galeri/file picker.
  Future<void> _pickProof() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _proofBytes = bytes;
      _proofName = picked.name;
    });
  }

  Future<void> _confirm() async {
    final proof = _proofBytes;
    if (proof == null) return;
    setState(() => _processing = true);

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => _processing = false);
      return;
    }
    late final Booking booking;
    try {
      booking = await context.read<BookingProvider>().createBooking(
            court: widget.court,
            date: widget.date,
            slotHours: widget.slotHours,
            paymentMethod: _method,
            userId: user.id,
            proofBytes: proof,
            proofExt: _proofExt,
          );
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }
    if (!mounted) return;

    // Refresh cache slot — jam yang baru dibooking langsung tampil terisi.
    context
        .read<CourtProvider>()
        .invalidateOccupied(widget.court.id, widget.date);

    // Langsung arahkan ke tiket digital (gantikan halaman checkout).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TicketScreen(booking: booking)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Ringkasan pesanan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.court.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: PadelGoColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.court.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: PadelGoColors.textSecondary,
                  ),
                ),
                const Divider(height: 24),
                _summaryRow(
                  Icons.calendar_month_outlined,
                  'Tanggal',
                  Formatters.tanggalPanjang(widget.date),
                ),
                const SizedBox(height: 10),
                _summaryRow(
                  Icons.schedule_outlined,
                  'Waktu',
                  '$_timeRange (${widget.slotHours.length} jam)',
                ),
                const SizedBox(height: 10),
                _summaryRow(
                  Icons.sports_tennis,
                  'Slot',
                  widget.slotHours.map(Formatters.jam).join(', '),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Metode pembayaran
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: PadelGoColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: RadioGroup<PaymentMethod>(
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
              child: Column(
                children: [
                for (final m in PaymentMethod.values) ...[
                  RadioListTile<PaymentMethod>(
                    value: m,
                    activeColor: PadelGoColors.primary,
                    secondary: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: PadelGoColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_methodIcon(m),
                          color: PadelGoColors.primary, size: 22),
                    ),
                    title: Text(
                      m.label,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      m.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: PadelGoColors.textSecondary,
                      ),
                    ),
                  ),
                  if (m != PaymentMethod.values.last)
                    const Divider(indent: 70, endIndent: 16),
                ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // QRIS terbaru dari admin (realtime)
          if (_method == PaymentMethod.qris) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Scan QRIS untuk Membayar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: PadelGoColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bisa dibayar lewat semua e-wallet & m-banking',
                    style: TextStyle(
                      fontSize: 12,
                      color: PadelGoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const QrisImage(size: 240),
                  const SizedBox(height: 14),
                  Text(
                    'Total: ${Formatters.rupiah(_total)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: PadelGoColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Setelah membayar, upload bukti pembayaran di bawah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: PadelGoColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Rincian harga
          const Text(
            'Rincian Harga',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: PadelGoColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _priceRow(
                  '${Formatters.rupiah(widget.court.pricePerHour)} x ${widget.slotHours.length} jam',
                  _subtotal,
                ),
                const SizedBox(height: 10),
                _priceRow('Biaya layanan', _serviceFee),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      Formatters.rupiah(_total),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: PadelGoColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bukti pembayaran (wajib — diverifikasi admin)
          Row(
            children: [
              const Text(
                'Bukti Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: PadelGoColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Wajib',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _processing ? null : _pickProof,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _proofBytes == null
                      ? PadelGoColors.divider
                      : PadelGoColors.available,
                ),
              ),
              child: _proofBytes == null
                  ? const Column(
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 34, color: PadelGoColors.primary),
                        SizedBox(height: 8),
                        Text(
                          'Upload bukti transfer / screenshot pembayaran',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: PadelGoColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'JPG, PNG — pesanan diverifikasi admin lapangan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: PadelGoColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _proofBytes!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bukti terlampir',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: PadelGoColors.available,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _proofName ?? 'bukti.jpg',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: PadelGoColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Tap untuk ganti',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: PadelGoColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed:
                (_processing || _proofBytes == null) ? null : _confirm,
            icon: _processing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline, size: 20),
            label: Text(
              _processing
                  ? 'Memproses...'
                  : _proofBytes == null
                      ? 'Upload Bukti untuk Membayar'
                      : 'Bayar Sekarang',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: PadelGoColors.textHint),
        const SizedBox(width: 10),
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: PadelGoColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: PadelGoColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: PadelGoColors.textSecondary,
          ),
        ),
        Text(
          Formatters.rupiah(value),
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: PadelGoColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
