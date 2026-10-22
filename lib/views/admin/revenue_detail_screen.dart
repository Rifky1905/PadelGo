import 'package:flutter/material.dart';

import '../../models/admin_order.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

enum RevenuePeriod {
  day('Per Hari'),
  week('Per Minggu'),
  month('Per Bulan');

  const RevenuePeriod(this.label);
  final String label;
}

/// Rincian pendapatan — transaksi lunas/selesai dari tabel `bookings`
/// dengan filter Per Hari / Per Minggu / Per Bulan + grafik batang.
class RevenueDetailScreen extends StatefulWidget {
  const RevenueDetailScreen({super.key});

  @override
  State<RevenueDetailScreen> createState() => _RevenueDetailScreenState();
}

class _RevenueDetailScreenState extends State<RevenueDetailScreen> {
  RevenuePeriod _period = RevenuePeriod.week;
  DateTime _anchor = DateUtils.dateOnly(DateTime.now());

  List<AdminOrder> _orders = const [];
  bool _loading = true;
  String? _error;

  /// Penanda request terakhir — hasil request lama diabaikan saat
  /// filter diganti cepat berturut-turut.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime get _start => switch (_period) {
    RevenuePeriod.day => _anchor,
    RevenuePeriod.week => _anchor.subtract(Duration(days: _anchor.weekday - 1)),
    RevenuePeriod.month => DateTime(_anchor.year, _anchor.month),
  };

  DateTime get _end => switch (_period) {
    RevenuePeriod.day => DateTime(_start.year, _start.month, _start.day + 1),
    RevenuePeriod.week => DateTime(_start.year, _start.month, _start.day + 7),
    RevenuePeriod.month => DateTime(_start.year, _start.month + 1),
  };

  bool get _canGoNext => _end.isBefore(DateTime.now());

  String get _rangeLabel {
    final end = _end.subtract(const Duration(days: 1));
    return switch (_period) {
      RevenuePeriod.day => Formatters.tanggalPanjang(_start),
      RevenuePeriod.week =>
        '${Formatters.tanggalSingkat(_start)} – ${Formatters.tanggalPendek(end)}',
      RevenuePeriod.month => Formatters.bulanTahun(_start),
    };
  }

  Future<void> _load() async {
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await SupabaseService.fetchRevenueOrders(_start, _end);
      if (!mounted || id != _requestId) return;
      setState(() {
        _orders = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = 'Gagal memuat data pendapatan: $e';
        _loading = false;
      });
    }
  }

  void _setPeriod(RevenuePeriod p) {
    _period = p;
    _anchor = DateUtils.dateOnly(DateTime.now());
    _load();
  }

  void _shift(int dir) {
    _anchor = switch (_period) {
      RevenuePeriod.day => DateTime(
        _anchor.year,
        _anchor.month,
        _anchor.day + dir,
      ),
      RevenuePeriod.week => DateTime(
        _anchor.year,
        _anchor.month,
        _anchor.day + 7 * dir,
      ),
      RevenuePeriod.month => DateTime(_anchor.year, _anchor.month + dir),
    };
    _load();
  }

  /// Pendapatan per bucket: jam (Per Hari) atau tanggal (Minggu/Bulan).
  ({List<double> values, List<String> labels}) get _chart {
    final start = _start;
    final count = switch (_period) {
      RevenuePeriod.day => 24,
      RevenuePeriod.week => 7,
      RevenuePeriod.month => DateUtils.getDaysInMonth(start.year, start.month),
    };
    final values = List<double>.filled(count, 0);
    for (final o in _orders) {
      final i = _period == RevenuePeriod.day
          ? o.createdAt.hour
          : DateUtils.dateOnly(o.createdAt).difference(start).inDays;
      if (i >= 0 && i < count) values[i] += o.totalPrice;
    }
    final labels = [
      for (var i = 0; i < count; i++)
        switch (_period) {
          RevenuePeriod.day => i % 3 == 0 ? i.toString().padLeft(2, '0') : '',
          RevenuePeriod.week => Formatters.hariPendek(
            start.add(Duration(days: i)),
          ),
          RevenuePeriod.month => (i == 0 || (i + 1) % 5 == 0) ? '${i + 1}' : '',
        },
    ];
    return (values: values, labels: labels);
  }

  @override
  Widget build(BuildContext context) {
    final total = _orders.fold(0.0, (s, o) => s + o.totalPrice);
    final avg = _orders.isEmpty ? 0.0 : total / _orders.length;
    final chart = _chart;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pendapatan')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<RevenuePeriod>(
                segments: [
                  for (final p in RevenuePeriod.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {_period},
                showSelectedIcon: false,
                onSelectionChanged: (s) => _setPeriod(s.first),
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.white,
                  selectedBackgroundColor: PadelGoColors.primary,
                  selectedForegroundColor: Colors.white,
                  foregroundColor: PadelGoColors.textSecondary,
                  side: const BorderSide(color: PadelGoColors.divider),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.outlined(
                  tooltip: 'Sebelumnya',
                  onPressed: () => _shift(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    _rangeLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: PadelGoColors.textPrimary,
                    ),
                  ),
                ),
                IconButton.outlined(
                  tooltip: 'Berikutnya',
                  onPressed: _canGoNext ? () => _shift(1) : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _TotalBanner(total: total, loading: _loading),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transaksi',
                    value: '${_orders.length}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.trending_up_rounded,
                    label: 'Rata-rata',
                    value: Formatters.rupiah(avg),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _period == RevenuePeriod.day
                        ? 'Grafik Pendapatan per Jam'
                        : 'Grafik Pendapatan per Hari',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: PadelGoColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _RevenueBarChart(
                            values: chart.values,
                            labels: chart.labels,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Rincian Transaksi Masuk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PadelGoColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (_error != null)
              _Message(icon: Icons.error_outline, text: _error!)
            else if (!_loading && _orders.isEmpty)
              const _Message(
                icon: Icons.inbox_outlined,
                text: 'Belum ada transaksi lunas pada periode ini.',
              )
            else
              for (final o in _orders) _TransactionTile(order: o),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: PadelGoColors.divider),
    ),
    child: child,
  );
}

class _TotalBanner extends StatelessWidget {
  const _TotalBanner({required this.total, required this.loading});
  final double total;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: PadelGoColors.pinkGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PadelGoColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pendapatan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loading ? '...' : Formatters.rupiah(total),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.payments_rounded, color: Colors.white, size: 36),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: PadelGoColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: PadelGoColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: PadelGoColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: PadelGoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grafik batang sederhana tanpa dependency tambahan.
class _RevenueBarChart extends StatelessWidget {
  const _RevenueBarChart({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final max = values.fold(0.0, (m, v) => v > m ? v : m);
    if (max == 0) {
      return const Center(
        child: Text(
          'Tidak ada pendapatan pada periode ini.',
          style: TextStyle(fontSize: 12.5, color: PadelGoColors.textSecondary),
        ),
      );
    }
    final gap = values.length > 12 ? 2.0 : 6.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gap / 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Tooltip(
                        message: Formatters.rupiah(values[i]),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: values[i] / max),
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                          builder: (context, f, _) => FractionallySizedBox(
                            heightFactor: values[i] == 0 ? 0.015 : f,
                            child: Container(
                              decoration: BoxDecoration(
                                color: values[i] == 0
                                    ? PadelGoColors.divider
                                    : PadelGoColors.primary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 14,
                    child: Text(
                      labels[i],
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                      style: const TextStyle(
                        fontSize: 10,
                        color: PadelGoColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.order});
  final AdminOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PadelGoColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PadelGoColors.availableBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.south_west_rounded,
              color: PadelGoColors.available,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: PadelGoColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.id} • ${order.paymentMethod.label}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: PadelGoColors.textSecondary,
                  ),
                ),
                Text(
                  '${Formatters.tanggalPendek(order.createdAt)}, '
                  '${Formatters.jamMenit(order.createdAt)} • '
                  'Main ${Formatters.tanggalSingkat(order.date)} ${order.timeRange}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: PadelGoColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${Formatters.rupiah(order.totalPrice)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: PadelGoColors.available,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                order.paymentStatus.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: PadelGoColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Column(
      children: [
        Icon(icon, size: 40, color: PadelGoColors.textHint),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: PadelGoColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
