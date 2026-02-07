import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/exercise_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/measurement_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/routines_screen.dart';
import 'ui/screens/library_screen.dart';
import 'ui/screens/history_screen.dart';
import 'ui/screens/progress_screen.dart';
import 'ui/screens/body_metrics_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  
  final exerciseProvider = ExerciseProvider();
  final workoutProvider = WorkoutProvider();
  final measurementProvider = MeasurementProvider();
  final settingsProvider = SettingsProvider();
  
  await settingsProvider.init();
  await exerciseProvider.init();
  await workoutProvider.init();
  await measurementProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: exerciseProvider),
        ChangeNotifierProvider.value(value: workoutProvider),
        ChangeNotifierProvider.value(value: measurementProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: const FitnessTrackerApp(),
    ),
  );
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Fitness Tracker',
          theme: AppTheme.darkTheme,
          locale: Locale(settings.currentLocale),
          builder: (context, child) {
            return Directionality(
              textDirection: settings.isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
          home: const MainNavigation(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const RoutinesScreen(),
    const LibraryScreen(),
    const HistoryScreen(),
    const ProgressScreen(),
  ];

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          final isAr = settings.isArabic;
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: isAr ? 'الرئيسية' : 'Home',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.fitness_center_outlined),
                activeIcon: const Icon(Icons.fitness_center),
                label: isAr ? 'تماريني' : 'Workouts',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.library_books_outlined),
                activeIcon: const Icon(Icons.library_books),
                label: isAr ? 'المكتبة' : 'Library',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_outlined),
                activeIcon: const Icon(Icons.history),
                label: isAr ? 'السجل' : 'Logbook',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_outlined),
                activeIcon: const Icon(Icons.bar_chart),
                label: isAr ? 'التقدم' : 'Progress',
              ),
            ],
          );
        },
      ),
    );
  }
}
