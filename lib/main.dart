import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants.dart';
import 'screens/login_screen.dart';
import 'main_layout.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Spanish locale for DateFormat
  await initializeDateFormatting('es', null);
  
  // Initialize Notifications
  await NotificationService().init();

  // Initialize Supabase
  // Note: If you haven't replaced the Anon Key in constants.dart, this might fail.
  try {
    await Supabase.initialize(
      url: Constants.supabaseUrl,
      anonKey: Constants.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }

  runApp(const UniversityApp());
}

class UniversityApp extends StatelessWidget {
  const UniversityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión Universitaria',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Supabase.instance.client.auth.currentUser == null
          ? const LoginScreen()
          : const MainLayout(),
    );
  }
}
