import 'package:flutter/material.dart';
import '../../models/workout_session.dart';
import '../../core/app_theme.dart';
import 'package:intl/intl.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const WorkoutCard({
    super.key,
    required this.session,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        onLongPress: onLongPress,
        title: Text(
          session.routineName ?? 'Quick Start',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('EEE, MMM d • HH:mm').format(session.startTime),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.fitness_center, size: 14, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(
                  '${session.sets.length} Sets • ${session.totalVolume.toStringAsFixed(1)} kg Volume',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }
}
