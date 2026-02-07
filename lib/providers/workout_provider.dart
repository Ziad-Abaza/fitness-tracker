import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import '../models/routine.dart';
import '../models/workout_session.dart';
import '../models/set_log.dart';
import '../services/database_helper.dart';

class WorkoutProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Routine> _routines = [];
  List<WorkoutSession> _sessions = [];
  WorkoutSession? _activeSession;
  
  List<Routine> get routines => _routines;
  List<WorkoutSession> get sessions => _sessions;
  WorkoutSession? get activeSession => _activeSession;

  Map<String, List<WorkoutSession>> get sessionsByMonth {
    final Map<String, List<WorkoutSession>> groups = {};
    for (var session in _sessions) {
      final month = DateFormat('MMMM yyyy').format(session.startTime);
      groups.putIfAbsent(month, () => []).add(session);
    }
    return groups;
  }

  Future<void> init() async {
    await fetchRoutines();
    await fetchSessions();
  }

  Routine? get scheduledRoutineForToday {
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun
    try {
      return _routines.firstWhere((r) => r.scheduledDays.contains(today));
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchRoutines() async {
    _routines = await _db.getAllRoutines();
    notifyListeners();
  }

  Future<void> fetchSessions() async {
    _sessions = await _db.getAllSessions();
    notifyListeners();
  }

  Future<void> startWorkout({Routine? routine}) async {
    final sessionId = await _db.startSession(
      routineId: routine?.id,
      routineName: routine?.name ?? 'Quick Start',
    );
    
    _activeSession = WorkoutSession(
      id: sessionId,
      routineId: routine?.id,
      routineName: routine?.name ?? 'Quick Start',
      startTime: DateTime.now(),
      sets: [],
    );
    notifyListeners();
  }

  void addExerciseToActiveSession(String exerciseId) {
    if (_activeSession == null) return;
    // Note: Since WorkoutSession doesn't have an exercise list (it derives it from sets logged),
    // we just need to ensure the UI knows which exercises are "on deck".
    // For now, let's assume the UI manages the "on deck" list if it's not from a routine.
    notifyListeners();
  }

  Future<void> logSet(SetLog setLog) async {
    if (_activeSession == null) return;
    
    final id = await _db.insertSet(setLog);
    final newSet = SetLog(
      id: id,
      sessionId: setLog.sessionId,
      exerciseId: setLog.exerciseId,
      weight: setLog.weight,
      reps: setLog.reps,
      timestamp: setLog.timestamp,
      isCompleted: setLog.isCompleted,
    );
    
    _activeSession!.sets.add(newSet);
    notifyListeners();
  }

  Future<WorkoutSession?> finishWorkout() async {
    if (_activeSession == null) return null;
    
    final completedSession = _activeSession!;
    await _db.endSession(completedSession.id!);
    _activeSession = null;
    await fetchSessions();
    notifyListeners();
    return completedSession;
  }

  Future<void> deleteSession(int sessionId) async {
    await _db.deleteSession(sessionId);
    await fetchSessions();
  }

  Future<void> clearAllData() async {
    await _db.clearAllData();
    await fetchRoutines();
    await fetchSessions();
    notifyListeners();
  }

  Future<String> exportToCSV() async {
    List<List<dynamic>> rows = [];
    rows.add(['Date', 'Routine', 'Exercise', 'Weight', 'Reps', 'Volume']);

    for (var session in _sessions) {
      final date = DateFormat('yyyy-MM-dd HH:mm').format(session.startTime);
      final routine = session.routineName ?? 'Quick Start';
      for (var set in session.sets) {
        final exercise = set.exerciseId; // Ideally we map this to name
        rows.add([date, routine, exercise, set.weight, set.reps, set.volume]);
      }
    }
    return const ListToCsvConverter().convert(rows);
  }

  Future<SetLog?> getLastPerformance(String exerciseId) async {
    return await _db.getLastPerformance(exerciseId);
  }

  Future<double> getMaxWeight(String exerciseId) async {
    return await _db.getMaxWeightForExercise(exerciseId);
  }

  Future<List<Map<String, dynamic>>> getExerciseProgressData(String exerciseId) async {
    final history = await _db.getWeightHistory(exerciseId);
    return history.map((h) {
      final weight = h['weight'] as double;
      final reps = h['reps'] as int;
      return {
        'weight': weight,
        'reps': reps,
        'estimated1RM': weight * (1 + (reps / 30)),
        'timestamp': h['timestamp'],
      };
    }).toList();
  }

  // Analytics Getters
  double get totalVolumeAllTime => _sessions.fold(0.0, (sum, s) => sum + s.totalVolume);
  
  double get best1RMAllTime {
    if (_sessions.isEmpty) return 0.0;
    double max1RM = 0.0;
    for (var session in _sessions) {
      for (var set in session.sets) {
        if (set.estimated1RM > max1RM) max1RM = set.estimated1RM;
      }
    }
    return max1RM;
  }

  int get workoutCount => _sessions.length;

  List<double> get lastSevenSessionsVolume {
    return _sessions.reversed.take(7).map((s) => s.totalVolume).toList().reversed.toList();
  }

  List<Map<String, dynamic>> getVolumeProgressData() {
    // For last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentSessions = _sessions.where((s) => s.startTime.isAfter(thirtyDaysAgo)).toList().reversed.toList();
    
    return recentSessions.map((s) => {
      'date': s.startTime,
      'volume': s.totalVolume,
    }).toList();
  }

  Future<void> createRoutine(String name, List<String> exerciseIds, {List<int> scheduledDays = const []}) async {
    final routine = Routine(
      name: name,
      exerciseIds: exerciseIds,
      scheduledDays: scheduledDays,
      createdAt: DateTime.now(),
    );
    await _db.insertRoutine(routine);
    await fetchRoutines();
  }
}
