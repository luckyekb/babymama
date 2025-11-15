import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/pregnancy_provider.dart';
import 'providers/doctor_diary_provider.dart';
import 'providers/wellness_provider.dart';
import 'providers/checklist_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const BabyMamaApp());
}

class BabyMamaApp extends StatelessWidget {
  const BabyMamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PregnancyProvider()),
        ChangeNotifierProvider(create: (_) => DoctorDiaryProvider()),
        ChangeNotifierProvider(create: (_) => WellnessProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
      ],
      child: MaterialApp(
        title: 'BabyMama',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFC4D6), // Нежный розовый
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.nunitoTextTheme(),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        home: const AppEntry(),
      ),
    );
  }
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PregnancyProvider>(
      builder: (context, provider, _) {
        if (!provider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return provider.hasPregnancyDate
            ? const MainNavigation()
            : const OnboardingScreen();
      },
    );
  }
}
