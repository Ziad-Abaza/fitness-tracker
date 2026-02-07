import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../core/app_theme.dart';
import 'routine_builder_screen.dart';
import 'active_workout_screen.dart';
import '../../providers/settings_provider.dart';
import '../widgets/workout_card.dart';
import '../widgets/exercise_image.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settings, child) => Text(settings.isArabic ? 'تدريباتي' : 'MY ROUTINES'),
        ),
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          if (provider.routines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center, size: 64, color: AppTheme.surface),
                  const SizedBox(height: 16),
                  Consumer<SettingsProvider>(
                    builder: (context, settings, child) => Text(
                      settings.isArabic ? 'لا توجد تدريبات بعد.' : 'No routines created yet.',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoutineBuilderScreen()),
                    ),
                    child: Consumer<SettingsProvider>(
                      builder: (context, settings, child) => Text(settings.isArabic ? 'إنشاء أول تدريب لك' : 'CREATE YOUR FIRST ROUTINE'),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.routines.length,
            itemBuilder: (context, index) {
              final routine = provider.routines[index];
              return Card(
                color: AppTheme.surface,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(routine.name.toUpperCase(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<SettingsProvider>(
                        builder: (context, settings, child) => Text(
                          settings.isArabic ? '${routine.exerciseIds.length} تمارين' : '${routine.exerciseIds.length} Exercises',
                          style: const TextStyle(color: AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 35,
                        child: Consumer<ExerciseProvider>(
                          builder: (context, exProvider, child) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: routine.exerciseIds.length,
                              itemBuilder: (context, i) {
                                final ex = exProvider.getExerciseById(routine.exerciseIds[i]);
                                if (ex == null) return const SizedBox();
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: AppTheme.black,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: ExerciseImage(
                                      gifPath: ex.gifPath,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.play_arrow, color: AppTheme.primary),
                  onTap: () async {
                    await provider.startWorkout(routine: routine);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ActiveWorkoutScreen()),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RoutineBuilderScreen()),
        ),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: AppTheme.black),
      ),
    );
  }
}
