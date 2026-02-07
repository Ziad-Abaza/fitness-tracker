import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/workout_provider.dart';
import '../../core/app_theme.dart';
import '../widgets/workout_card.dart';
import 'session_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGBOOK'),
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          final groupedSessions = provider.sessionsByMonth;

          if (groupedSessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, size: 80, color: AppTheme.surface),
                    const SizedBox(height: 24),
                    Text(
                      "The best time to start was yesterday. \nThe second best time is today.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedSessions.length,
            itemBuilder: (context, index) {
              final month = groupedSessions.keys.elementAt(index);
              final sessions = groupedSessions[month]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                    child: Text(
                      month.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ...sessions.map((session) => WorkoutCard(
                    session: session,
                    onLongPress: () async {
                      HapticFeedback.mediumImpact();
                      final delete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.surface,
                          title: const Text('DELETE SESSION?'),
                          content: const Text('This will permanently remove this workout from your logbook.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (delete == true && context.mounted) {
                        await provider.deleteSession(session.id!);
                        HapticFeedback.heavyImpact();
                      }
                    },
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionDetailScreen(session: session),
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
