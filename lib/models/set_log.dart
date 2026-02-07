class SetLog {
  final int? id;
  final int sessionId;
  final String exerciseId;
  final double weight;
  final int reps;
  final DateTime timestamp;
  final bool isCompleted;

  SetLog({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    required this.timestamp,
    this.isCompleted = false,
  });

  double get volume => weight * reps;
  
  double get estimated1RM => weight * (1 + (reps / 30));

  factory SetLog.fromMap(Map<String, dynamic> map) {
    return SetLog(
      id: map['id'],
      sessionId: map['sessionId'],
      exerciseId: map['exerciseId'],
      weight: map['weight'],
      reps: map['reps'],
      timestamp: DateTime.parse(map['timestamp']),
      isCompleted: map['isCompleted'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'weight': weight,
      'reps': reps,
      'timestamp': timestamp.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
