import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/court_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

/// Pengaturan harga — atur tarif per jam lapangan.
class AdminPricingScreen extends StatefulWidget {
  const AdminPricingScreen({super.key});

  @override
  State<AdminPricingScreen> createState() => _AdminPricingScreenState();
}

class _AdminPricingScreenState extends State<AdminPricingScreen> {
  late final TextEditingController _controller;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context
          .read<AdminProvider>()
          .pricePerHour
          .round()
          .toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _adjust(int delta) {
    final current = int.tryParse(_controller.text) ?? 0;
    final next = (current + delta).clamp(0, 10000000);
    _controller.text = next.toString();
    setState(() => _saved = false);
  }

  void _save() {
    final value = double.tryParse(_controller.text);
    if (value == null || value <= 0) return;
    context.read<AdminProvider>().setPricePerHour(value);
    // Sinkronkan harga di kartu lapangan sisi user.
    context.read<CourtProvider>().updateLocalPrice(value);
    setState(() => _saved = true);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final court = context.watch<CourtProvider>().primaryCourt;

    if (court == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Pengaturan Harga',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: PadelGoColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Atur tarif sewa lapangan per jam.',
          style: TextStyle(
            fontSize: 13.5,
            color: PadelGoColors.textSecondary,
          ),
        ),
        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PadelGoColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                court.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: PadelGoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tarif saat ini: ${Formatters.rupiah(admin.pricePerHour)}/jam',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: PadelGoColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Harga per jam (Rp)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: PadelGoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _adjustButton(Icons.remove, () => _adjust(-10000)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: PadelGoColors.textPrimary,
                      ),
                      onChanged: (_) => setState(() => _saved = false),
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _adjustButton(Icons.add, () => _adjust(10000)),
                ],
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  '± Rp 10.000 per klik',
                  style: TextStyle(
                    fontSize: 11,
                    color: PadelGoColors.textHint,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(
                  _saved ? Icons.check_circle : Icons.save_outlined,
                  size: 19,
                ),
                label: Text(_saved ? 'Tersimpan' : 'Simpan Tarif'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Info
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PadelGoColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: PadelGoColors.primary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Perubahan tarif berlaku untuk booking baru. Pesanan yang '
                  'sudah dibayar tidak terpengaruh.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: PadelGoColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _adjustButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: PadelGoColors.primarySoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 46,
          height: 50,
          child: Icon(icon, color: PadelGoColors.primary),
        ),
      ),
    );
  }
}
