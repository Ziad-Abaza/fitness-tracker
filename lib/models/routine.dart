class Routine {
  final int? id;
  final String name;
  final List<String> exerciseIds;
  final List<int> scheduledDays; // 1=Mon, 7=Sun
  final DateTime createdAt;

  Routine({
    this.id,
    required this.name,
    required this.exerciseIds,
    this.scheduledDays = const [],
    required this.createdAt,
  });

  factory Routine.fromMap(Map<String, dynamic> map, List<String> exerciseIds) {
    return Routine(
      id: map['id'],
      name: map['name'],
      exerciseIds: exerciseIds,
      scheduledDays: (map['scheduledDays'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .map(int.parse)
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scheduledDays': scheduledDays.join(','),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
