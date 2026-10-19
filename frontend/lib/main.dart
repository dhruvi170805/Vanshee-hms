import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/hms_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/widgets/app_layout.dart';
import 'features/auth/presentation/login_screen.dart';

void main() {
  runApp(const HmsApp());
}

class HmsApp extends StatelessWidget {
  const HmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HmsProvider()..refreshAll()),
      ],
      child: MaterialApp(
        title: 'Hospital Management System (HMS)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.surface,
          ),
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) {
              return const AppLayout();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
