import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/workout_session.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/workout_provider.dart';
import '../../core/app_theme.dart';
import '../widgets/exercise_image.dart';

class SessionDetailScreen extends StatelessWidget {
  final WorkoutSession session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final duration = session.endTime != null 
        ? session.endTime!.difference(session.startTime)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.routineName?.toUpperCase() ?? 'WORKOUT'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, duration),
            const SizedBox(height: 24),
            Text(
              'EXERCISES',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ..._buildExerciseGroups(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Duration? duration) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _headerItem('DATE', DateFormat('MMM d, y').format(session.startTime)),
          _headerItem('VOLUME', '${session.totalVolume.toStringAsFixed(1)} kg'),
          if (duration != null) 
            _headerItem('TIME', '${duration.inMinutes}m'),
        ],
      ),
    );
  }

  Widget _headerItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  List<Widget> _buildExerciseGroups(BuildContext context) {
    final Map<String, List<dynamic>> groupedSets = {};
    for (var set in session.sets) {
      groupedSets.putIfAbsent(set.exerciseId, () => []).add(set);
    }

    return groupedSets.entries.map((entry) {
      final exercise = context.read<ExerciseProvider>().getExerciseById(entry.key);
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (exercise != null)
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ExerciseImage(
                        gifPath: exercise.gifPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    exercise?.name.toUpperCase() ?? 'UNKNOWN EXERCISE',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...entry.value.asMap().entries.map((setEntry) {
              final set = setEntry.value;
              return FutureBuilder<double>(
                future: context.read<WorkoutProvider>().getMaxWeight(set.exerciseId),
                builder: (context, snapshot) {
                  final isPR = snapshot.hasData && set.weight >= snapshot.data! && snapshot.data! > 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text('SET ${setEntry.key + 1}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        const SizedBox(width: 8),
                        if (isPR)
                          const Tooltip(
                            message: 'Personal Record!',
                            child: Icon(Icons.emoji_events, color: Colors.amber, size: 14),
                          ),
                        const Spacer(),
                        Text('${set.weight} kg x ${set.reps}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }
              );
            }).toList(),
          ],
        ),
      );
    }).toList();
  }
}
