import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../core/app_theme.dart';
import 'routine_builder_screen.dart';
import 'active_workout_screen.dart';
import '../widgets/workout_card.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY ROUTINES'),
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
                  const Text('No routines created yet.', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoutineBuilderScreen()),
                    ),
                    child: const Text('CREATE YOUR FIRST ROUTINE'),
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
                  subtitle: Text('${routine.exerciseIds.length} Exercises', style: const TextStyle(color: AppTheme.primary)),
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
