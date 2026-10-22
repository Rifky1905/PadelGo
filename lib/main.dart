import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/court_provider.dart';
import 'services/supabase_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'views/admin/admin_navigation.dart';
import 'views/landing/landing_page.dart';
import 'views/user/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Supabase — app berjalan 100% live backend.
  await SupabaseService.init();
  runApp(const PadelGoApp());
}

class PadelGoApp extends StatelessWidget {
  const PadelGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider()..tryRestoreSession()),
        ChangeNotifierProvider(create: (_) => CourtProvider()..loadCourts()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

/// Menentukan halaman awal berdasar state auth & role:
/// - belum login  -> LandingPage
/// - role admin   -> AdminNavigation
/// - role user    -> MainNavigation
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    // Sedang memulihkan sesi Supabase — tampilkan loading sebentar.
    if (auth.restoring) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!auth.isLoggedIn) return const LandingPage();
    return auth.user!.role == AppRole.admin
        ? const AdminNavigation()
        : const MainNavigation();
  }
}
