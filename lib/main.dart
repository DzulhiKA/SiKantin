import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';
import 'pages/admin_home_page.dart';
import 'pages/customer_home_page.dart';
import 'pages/performance_test_page.dart';

const supabaseUrl = 'https://vwddfjdusxzbzvnejzen.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3ZGRmamR1c3h6Ynp2bmVqemVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzNzE4NjMsImV4cCI6MjA3NTk0Nzg2M30.yk0rZvobghlpyrAzJwsf1xzW0A7Henj1eocfTUJE6uc';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const SiKantinApp());
}

class SiKantinApp extends StatelessWidget {
  const SiKantinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiKantin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      routes: {
        '/': (_) => const AuthStateHandler(),
        '/login': (_) => const LoginPage(),
        '/admin-home': (_) => const AdminHomePage(),
        '/customer-home': (_) => const CustomerHomePage(),
        '/test-api': (_) => const PerformanceTestPage(),
      },
      initialRoute: '/',
    );
  }
}

class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({super.key});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  late final SupabaseClient _supabase;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;

    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (!mounted) return;

      if (session == null) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      } else {
        final userId = session.user.id;
        final userData = await _supabase
            .from('users')
            .select('role')
            .eq('id', userId)
            .maybeSingle();

        final role = userData?['role'] ?? 'customer';

        if (role == 'admin') {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/admin-home', (r) => false);
        } else {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/customer-home', (r) => false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = _supabase.auth.currentSession;
    return session == null
        ? const LoginPage()
        : const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
  }
}
