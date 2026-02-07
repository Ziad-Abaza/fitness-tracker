class Exercise {
  final String id;
  final String name;
  final String force;
  final String level;
  final String mechanic;
  final String equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final String category;
  final List<String> images;

  Exercise({
    required this.id,
    required this.name,
    required this.force,
    required this.level,
    required this.mechanic,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.category,
    required this.images,
  });

  String get gifPath => 'assets/datasets/gifs/$id.gif';

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: (json['id'] ?? json['exerciseId'])?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Exercise',
      force: json['force']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      mechanic: json['mechanic']?.toString() ?? '',
      equipment: (json['equipments'] as List?)?.isNotEmpty == true 
          ? (json['equipments'] as List).first.toString() 
          : (json['equipment']?.toString() ?? ''),
      primaryMuscles: List<String>.from(json['targetMuscles'] ?? json['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      category: (json['bodyParts'] as List?)?.isNotEmpty == true 
          ? (json['bodyParts'] as List).first.toString() 
          : (json['category']?.toString() ?? ''),
      images: json['gifUrl'] != null ? [json['gifUrl'].toString()] : List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'force': force,
      'level': level,
      'mechanic': mechanic,
      'equipment': equipment,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
      'category': category,
      'images': images,
    };
  }
}
