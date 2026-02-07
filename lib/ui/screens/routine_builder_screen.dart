import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/app_theme.dart';
import '../../models/exercise.dart';
import '../widgets/exercise_image.dart';

class RoutineBuilderScreen extends StatefulWidget {
  const RoutineBuilderScreen({super.key});

  @override
  State<RoutineBuilderScreen> createState() => _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends State<RoutineBuilderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _selectedExerciseIds = [];
  final List<int> _scheduledDays = []; // 1=Mon, 7=Sun

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

  void _toggleDay(int day) {
    setState(() {
      if (_scheduledDays.contains(day)) {
        _scheduledDays.remove(day);
      } else {
        _scheduledDays.add(day);
      }
      HapticFeedback.lightImpact();
    });
  }

  Future<void> _saveRoutine() async {
    if (_nameController.text.isEmpty) {
      final isAr = context.read<SettingsProvider>().isArabic;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAr ? 'يرجى إدخال اسم التدريب' : 'Please enter a routine name')),
      );
      return;
    }
    if (_selectedExerciseIds.isEmpty) {
      final isAr = context.read<SettingsProvider>().isArabic;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAr ? 'يرجى اختيار تمرين واحد على الأقل' : 'Please select at least one exercise')),
      );
      return;
    }

    await context.read<WorkoutProvider>().createRoutine(
          _nameController.text,
          _selectedExerciseIds,
          scheduledDays: _scheduledDays,
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
        title: Consumer<SettingsProvider>(
          builder: (context, settings, child) => Text(settings.isArabic ? 'إنشاء تدريب' : 'CREATE ROUTINE'),
        ),
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
            child: Consumer<SettingsProvider>(
              builder: (context, settings, child) => TextField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: settings.isArabic ? 'اسم التدريب (مثال: يوم الصدر)' : 'Routine Name (e.g. Push Day)',
                  hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.surface)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<SettingsProvider>(
              builder: (context, settings, child) => Text(
                settings.isArabic ? 'الجدولة (اختياري)' : 'SCHEDULE (OPTIONAL)',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _buildDaySelector(),
          if (_selectedExerciseIds.isNotEmpty)
            _buildSelectedTray(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Consumer<SettingsProvider>(
              builder: (context, settings, child) => Row(
                children: [
                  const Icon(Icons.add_circle_outline, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    settings.isArabic ? 'اختر التمارين' : 'SELECT EXERCISES',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ],
              ),
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
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 45,
                            height: 45,
                            color: AppTheme.black,
                            child: ExerciseImage(
                              gifPath: exercise.gifPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(exercise.localizedName.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildDaySelector() {
    final isAr = context.read<SettingsProvider>().isArabic;
    final days = isAr 
        ? ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'] 
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final dayNum = i + 1;
          final isSelected = _scheduledDays.contains(dayNum);
          return GestureDetector(
            onTap: () => _toggleDay(dayNum),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.2),
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
                    : [],
              ),
              child: Center(
                child: Text(
                  days[i],
                  style: TextStyle(
                    color: isSelected ? AppTheme.black : AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSelectedTray() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Consumer<ExerciseProvider>(
        builder: (context, library, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _selectedExerciseIds.length,
            itemBuilder: (context, index) {
              final id = _selectedExerciseIds[index];
              final exercise = library.getExerciseById(id);
              if (exercise == null) return const SizedBox();
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ExerciseImage(
                        gifPath: exercise.gifPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: GestureDetector(
                        onTap: () => _toggleExercise(id),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
