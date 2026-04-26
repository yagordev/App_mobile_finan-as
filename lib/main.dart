import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_colors.dart';
import 'login_page.dart';
import 'providers/finance_provider.dart';

void main() {
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.light,
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryGreen,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.darkerGrotesqueTextTheme(
        ThemeData.light().textTheme,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: base.textTheme.copyWith(
          headlineLarge: GoogleFonts.darkerGrotesque(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: AppColors.textDark,
          ),
          titleLarge: GoogleFonts.darkerGrotesque(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
          bodyLarge: GoogleFonts.darkerGrotesque(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: AppColors.textDark,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
