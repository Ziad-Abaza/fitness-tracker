import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../core/app_theme.dart';
import '../../models/exercise.dart';

class RoutineBuilderScreen extends StatefulWidget {
  const RoutineBuilderScreen({super.key});

  @override
  State<RoutineBuilderScreen> createState() => _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends State<RoutineBuilderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _selectedExerciseIds = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleExercise(String id) {
    setState(() {
      if (_selectedExerciseIds.contains(id)) {
        _selectedExerciseIds.remove(id);
        HapticFeedback.mediumImpact();
      } else {
        _selectedExerciseIds.add(id);
        HapticFeedback.lightImpact();
      }
    });
  }

  Future<void> _saveRoutine() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a routine name')),
      );
      return;
    }
    if (_selectedExerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one exercise')),
      );
      return;
    }

    await context.read<WorkoutProvider>().createRoutine(
          _nameController.text,
          _selectedExerciseIds,
        );
    
    if (mounted) {
      Navigator.pop(context);
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CREATE ROUTINE'),
        actions: [
          IconButton(
            onPressed: _saveRoutine,
            icon: const Icon(Icons.check, color: AppTheme.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Routine Name (e.g. Push Day)',
                hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.surface)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, size: 16, color: AppTheme.primary),
                SizedBox(width: 8),
                Text('SELECT EXERCISES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ExerciseProvider>(
              builder: (context, library, child) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: library.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = library.exercises[index];
                    final isSelected = _selectedExerciseIds.contains(exercise.id);
                    return Card(
                      color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primary : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => _toggleExercise(exercise.id),
                        title: Text(exercise.name.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        subtitle: Text(exercise.equipment, style: const TextStyle(fontSize: 10)),
                        trailing: Icon(
                          isSelected ? Icons.check_circle : Icons.add_circle_outline,
                          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
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
    );
  }
}
