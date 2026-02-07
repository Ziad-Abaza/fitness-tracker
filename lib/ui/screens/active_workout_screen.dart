import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../core/app_theme.dart';
import '../../models/exercise.dart';
import '../../models/set_log.dart';
import '../../models/workout_session.dart';
import '../widgets/rest_timer_overlay.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _timeString = '00:00:00';
  
  final Map<String, List<SetController>> _exerciseSets = {};
  final Map<String, SetLog?> _lastPerformances = {};
  
  int _currentExerciseIndex = 0;
  List<String> _activeExerciseIds = [];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeString = _formatDuration(_stopwatch.elapsed);
        });
      }
    });

    final workoutProvider = context.read<WorkoutProvider>();
    final session = workoutProvider.activeSession;
    
    if (session?.routineId != null) {
      final routine = workoutProvider.routines.firstWhere((r) => r.id == session!.routineId);
      _activeExerciseIds = List.from(routine.exerciseIds);
    }

    _initializeSets();
  }

  Future<void> _initializeSets() async {
    final workoutProvider = context.read<WorkoutProvider>();
    for (var id in _activeExerciseIds) {
      final lastPerf = await workoutProvider.getLastPerformance(id);
      setState(() {
        _lastPerformances[id] = lastPerf;
        _exerciseSets[id] = [
          SetController(
            weight: lastPerf?.weight.toString() ?? '',
            reps: lastPerf?.reps.toString() ?? '',
          )
        ];
      });
    }
  }

  String _formatDuration(Duration duration) {
    return [
      duration.inHours,
      duration.inMinutes.remainder(60),
      duration.inSeconds.remainder(60)
    ].map((seg) => seg.toString().padLeft(2, '0')).join(':');
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var sets in _exerciseSets.values) {
      for (var ctrl in sets) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  void _addSet(String exerciseId) {
    HapticFeedback.lightImpact();
    setState(() {
      final lastSet = _exerciseSets[exerciseId]!.last;
      _exerciseSets[exerciseId]!.add(
        SetController(weight: lastSet.weightController.text, reps: lastSet.repsController.text),
      );
    });
  }

  void _completeSet(String exerciseId, int setIndex) async {
    final controller = _exerciseSets[exerciseId]![setIndex];
    if (controller.isCompleted) return;

    if (controller.weightController.text.isEmpty || controller.repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter weight and reps')),
      );
      return;
    }

    HapticFeedback.lightImpact();
    
    final workoutProvider = context.read<WorkoutProvider>();
    final session = workoutProvider.activeSession!;
    
    final setLog = SetLog(
      sessionId: session.id!,
      exerciseId: exerciseId,
      weight: double.parse(controller.weightController.text),
      reps: int.parse(controller.repsController.text),
      timestamp: DateTime.now(),
      isCompleted: true,
    );

    await workoutProvider.logSet(setLog);

    setState(() {
      controller.isCompleted = true;
    });

    // Show Rest Timer Overlay
    _showRestTimer();
  }

  void _showRestTimer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RestTimerOverlay(
        initialSeconds: 90,
        onFinished: () {
          Navigator.pop(context);
          HapticFeedback.mediumImpact();
        },
      ),
    );
  }

  Future<void> _finishWorkout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('FINISH WORKOUT?'),
        content: const Text('Are you sure you want to end this session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('FINISH')),
        ],
      ),
    );

    if (result == true) {
      final session = await context.read<WorkoutProvider>().finishWorkout();
      if (mounted && session != null) {
        _showSummary(session);
      }
    }
  }

  void _showSummary(WorkoutSession session) {
    final best1RM = session.sets.isEmpty 
        ? 0.0 
        : session.sets.map((s) => s.estimated1RM).reduce((a, b) => a > b ? a : b);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Center(child: Text('WORKOUT SUMMARY', style: Theme.of(context).textTheme.titleLarge)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: AppTheme.primary),
            const SizedBox(height: 20),
            _summaryRow('TOTAL VOLUME', '${session.totalVolume.toStringAsFixed(1)} kg'),
            _summaryRow('BEST 1RM', '${best1RM.toStringAsFixed(1)} kg'),
            _summaryRow('TOTAL SETS', '${session.sets.length}'),
            _summaryRow('DURATION', _timeString),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Exit workout screen
              },
              child: const Text('BACK TO DASHBOARD'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_activeExerciseIds.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.black,
        appBar: AppBar(title: const Text('ACTIVE SESSION')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 64, color: AppTheme.surface),
              const SizedBox(height: 24),
              const Text('NO EXERCISES ADDED', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openExercisePicker,
                icon: const Icon(Icons.add),
                label: const Text('ADD EXERCISE'),
              ),
            ],
          ),
        ),
      );
    }

    final currentExerciseId = _activeExerciseIds[_currentExerciseIndex];
    final exercise = context.watch<ExerciseProvider>().getExerciseById(currentExerciseId);

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildStickyHeader(exercise),
            Expanded(
              child: _buildSetsTable(currentExerciseId),
            ),
            _buildNavigationFooter(),
          ],
        ),
      ),
    );
  }

  void _openExercisePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('ADD EXERCISE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
            Expanded(
              child: Consumer<ExerciseProvider>(
                builder: (context, provider, child) => ListView.builder(
                  controller: scrollController,
                  itemCount: provider.exercises.length,
                  itemBuilder: (context, index) {
                    final ex = provider.exercises[index];
                    return ListTile(
                      onTap: () async {
                        final lastPerf = await context.read<WorkoutProvider>().getLastPerformance(ex.id);
                        setState(() {
                          _activeExerciseIds.add(ex.id);
                          _lastPerformances[ex.id] = lastPerf;
                          _exerciseSets[ex.id] = [
                            SetController(
                              weight: lastPerf?.weight.toString() ?? '',
                              reps: lastPerf?.reps.toString() ?? '',
                            )
                          ];
                        });
                        if (mounted) Navigator.pop(context);
                      },
                      leading: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
                      title: Text(ex.name.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: Text(ex.equipment, style: const TextStyle(fontSize: 10)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader(Exercise? exercise) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise?.name.toUpperCase() ?? 'ADD EXERCISE',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'SESSION TIME: $_timeString',
                      style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: _finishWorkout, icon: const Icon(Icons.check, color: AppTheme.primary)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          if (exercise != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 100,
                width: double.infinity,
                color: AppTheme.black,
                child: Image.asset(
                  exercise.gifPath, 
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.fitness_center, color: AppTheme.surface, size: 40),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSetsTable(String exerciseId) {
    final sets = _exerciseSets[exerciseId] ?? [];
    final lastPerf = _lastPerformances[exerciseId];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('SET', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const Text('PREVIOUS', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const Text('WEIGHT (KG)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const Text('REPS', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(width: 40),
          ],
        ),
        const Divider(color: AppTheme.surface),
        ...sets.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: controller.isCompleted ? AppTheme.primary : AppTheme.surface,
                  child: Text('${index + 1}', style: TextStyle(fontSize: 10, color: controller.isCompleted ? AppTheme.black : AppTheme.textPrimary)),
                ),
                Text(
                  lastPerf != null ? '${lastPerf.weight}/${lastPerf.reps}' : '--',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                _buildInputField(controller.weightController, '0', controller.isCompleted),
                _buildInputField(controller.repsController, '0', controller.isCompleted),
                IconButton(
                  onPressed: () => _completeSet(exerciseId, index),
                  icon: Icon(
                    controller.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                    color: controller.isCompleted ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => _addSet(exerciseId),
          icon: const Icon(Icons.add, color: AppTheme.primary),
          label: const Text('ADD SET', style: TextStyle(color: AppTheme.primary)),
        ),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, bool disabled) {
    return SizedBox(
      width: 60,
      height: 35,
      child: TextField(
        controller: controller,
        enabled: !disabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppTheme.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildNavigationFooter() {
    final isLast = _currentExerciseIndex == _activeExerciseIds.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _currentExerciseIndex > 0 ? () => setState(() => _currentExerciseIndex--) : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('PREV'),
            style: TextButton.styleFrom(
              foregroundColor: _currentExerciseIndex > 0 ? AppTheme.textPrimary : AppTheme.textSecondary.withOpacity(0.3),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _openExercisePicker,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('EXERCISE', style: TextStyle(fontSize: 10)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surface, side: const BorderSide(color: AppTheme.primary)),
          ),
          ElevatedButton(
            onPressed: isLast 
                ? _finishWorkout 
                : () => setState(() => _currentExerciseIndex++),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.black),
            child: Text(isLast ? 'FINISH' : 'NEXT'),
          ),
        ],
      ),
    );
  }
}

class SetController {
  final TextEditingController weightController;
  final TextEditingController repsController;
  bool isCompleted;

  SetController({String weight = '', String reps = '', this.isCompleted = false})
      : weightController = TextEditingController(text: weight),
        repsController = TextEditingController(text: reps);

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}
