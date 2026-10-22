/// Helper formatting untuk mata uang Rupiah dan tanggal Bahasa Indonesia.
class Formatters {
  Formatters._();

  static const List<String> _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static const List<String> _bulanPendek = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static const List<String> _hari = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  /// 250000 -> "Rp 250.000"
  static String rupiah(num value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final pos = digits.length - i;
      buffer.write(digits[i]);
      if (pos > 1 && pos % 3 == 1) buffer.write('.');
    }
    return 'Rp ${buffer.toString()}';
  }

  /// "Senin, 20 Januari 2026"
  static String tanggalPanjang(DateTime d) =>
      '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]} ${d.year}';

  /// "20 Jan 2026"
  static String tanggalPendek(DateTime d) =>
      '${d.day} ${_bulanPendek[d.month - 1]} ${d.year}';

  /// "Sen" / "Sel" ...
  static String hariPendek(DateTime d) => _hari[d.weekday - 1].substring(0, 3);

  /// "Oktober 2026"
  static String bulanTahun(DateTime d) => '${_bulan[d.month - 1]} ${d.year}';

  /// "20 Okt"
  static String tanggalSingkat(DateTime d) =>
      '${d.day} ${_bulanPendek[d.month - 1]}';

  /// 7 -> "07:00"
  static String jam(int hour) =>
      '${hour.toString().padLeft(2, '0')}:00';

  /// DateTime -> "18:05"
  static String jamMenit(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}
