import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/workout_provider.dart';
import '../../core/app_theme.dart';
import '../widgets/workout_card.dart';
import 'active_workout_screen.dart';
import 'body_metrics_screen.dart';
import 'settings_screen.dart';
import '../../providers/settings_provider.dart';
import '../../models/exercise.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settings, child) => Text(settings.isArabic ? 'لوحة التحكم' : 'DASHBOARD'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (workoutProvider.scheduledRoutineForToday != null) ...[
                  _buildTodayWorkoutCard(context, workoutProvider, workoutProvider.scheduledRoutineForToday!),
                  const SizedBox(height: 16),
                ],
                _buildQuickStartCard(context, workoutProvider),
                const SizedBox(height: 16),
                _buildMetricsShortcut(context),
                const SizedBox(height: 24),
                Consumer<SettingsProvider>(
                  builder: (context, settings, child) => Text(
                    settings.isArabic ? 'حجم التمرين الأسبوعي' : 'WEEKLY VOLUME',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
                _buildVolumeChart(context, workoutProvider),
                const SizedBox(height: 24),
                Consumer<SettingsProvider>(
                  builder: (context, settings, child) => Text(
                    settings.isArabic ? 'الجلسات الأخيرة' : 'RECENT SESSIONS',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                if (workoutProvider.sessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Consumer<SettingsProvider>(
                        builder: (context, settings, child) => Text(
                          settings.isArabic ? 'لا توجد جلسات مسجلة بعد.' : 'No sessions logged yet.',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  )
                else
                  ...workoutProvider.sessions.take(5).map((session) => WorkoutCard(session: session)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayWorkoutCard(BuildContext context, WorkoutProvider workoutProvider, dynamic routine) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary.withAlpha(200), AppTheme.primary.withAlpha(50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available, color: AppTheme.black),
              const SizedBox(width: 8),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) => Text(
                  settings.isArabic ? 'تمرين اليوم' : 'TODAY\'S WORKOUT',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            routine.name.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.black, fontSize: 24),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await workoutProvider.startWorkout(routine: routine);
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActiveWorkoutScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.black,
              foregroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Consumer<SettingsProvider>(
              builder: (context, settings, child) => Text(settings.isArabic ? 'ابدأ التمرين' : 'START SESSION'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartCard(BuildContext context, WorkoutProvider workoutProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) => Text(
              settings.isArabic ? 'مستعد للتمرين؟' : 'READY TO TRAIN?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) => Text(
              settings.isArabic ? 'ابدأ جلسة جديدة أو اختر من تدريباتك.' : 'Start a fresh session or pick from your routines.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await workoutProvider.startWorkout();
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActiveWorkoutScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Consumer<SettingsProvider>(
              builder: (context, settings, child) => Text(settings.isArabic ? 'ابدأ بسرعة' : 'QUICK START'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsShortcut(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BodyMetricsScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.analytics_outlined, color: AppTheme.primary),
            SizedBox(width: 12),
            Text('LOG BODY METRICS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Spacer(),
            Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeChart(BuildContext context, WorkoutProvider workoutProvider) {
    final data = workoutProvider.lastSevenSessionsVolume;
    final maxVolume = data.isEmpty ? 1000.0 : data.reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: data.isEmpty 
        ? const Center(child: Text('LOG WORKOUTS TO SEE PROGRESS', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)))
        : BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVolume * 1.2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'S${value.toInt() + 1}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: data.asMap().entries.map((entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: AppTheme.primary,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              )).toList(),
            ),
          ),
    );
  }
}
