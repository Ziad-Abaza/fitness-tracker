import 'set_log.dart';

class WorkoutSession {
  final int? id;
  final int? routineId;
  final String? routineName;
  final DateTime startTime;
  final DateTime? endTime;
  final List<SetLog> sets;

  WorkoutSession({
    this.id,
    this.routineId,
    this.routineName,
    required this.startTime,
    this.endTime,
    this.sets = const [],
  });

  factory WorkoutSession.fromMap(Map<String, dynamic> map, {List<SetLog> sets = const []}) {
    return WorkoutSession(
      id: map['id'],
      routineId: map['routineId'],
      routineName: map['routineName'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      sets: sets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routineId': routineId,
      'routineName': routineName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  double get totalVolume => sets.fold(0, (sum, set) => sum + set.volume);
}
