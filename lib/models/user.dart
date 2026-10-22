/// Role pengguna aplikasi PadelGo.
enum AppRole {
  /// Pemain / pembooking lapangan.
  user('User'),

  /// Pengelola lapangan.
  admin('Admin');

  const AppRole(this.label);
  final String label;
}

/// Data model untuk pengguna aplikasi PadelGo.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.points = 1250,
  });

  final String id;
  final String name;
  final String email;
  final AppRole role;
  final String? phone;

  /// URL foto profil di Supabase Storage (bucket 'avatars').
  final String? avatarUrl;

  /// Poin loyalitas member.
  final int points;

  /// Status member berdasar poin.
  String get memberTier =>
      points >= 1000 ? 'Gold Member' : 'Silver Member';

  /// Inisial untuk avatar, misal "Rifky Arya" -> "RA".
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    AppRole? role,
  }) =>
      User(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        points: points,
      );
}
