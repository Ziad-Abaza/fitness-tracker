class Routine {
  final int? id;
  final String name;
  final List<String> exerciseIds;
  final DateTime createdAt;

  Routine({
    this.id,
    required this.name,
    required this.exerciseIds,
    required this.createdAt,
  });

  factory Routine.fromMap(Map<String, dynamic> map, List<String> exerciseIds) {
    return Routine(
      id: map['id'],
      name: map['name'],
      exerciseIds: exerciseIds,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
