import 'package:flutter/material.dart';

/// Fasilitas yang tersedia di sebuah lapangan padel.
enum Facility {
  locker('Loker', Icons.lock_outline),
  ac('AC', Icons.ac_unit),
  parking('Parkir', Icons.local_parking),
  racketRental('Sewa Raket', Icons.sports_tennis),
  cafe('Cafe', Icons.local_cafe_outlined),
  shower('Shower', Icons.shower_outlined),
  wifi('WiFi', Icons.wifi),
  mushola('Mushola', Icons.mosque_outlined);

  const Facility(this.label, this.icon);
  final String label;
  final IconData icon;
}
