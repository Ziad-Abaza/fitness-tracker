class Exercise {
  final String id;
  final String name;
  final String? name_ar;
  final String force;
  final String level;
  final String mechanic;
  final String equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final List<String>? instructions_ar;
  final String category;
  final List<String> images;

  static String currentLocale = 'en';

  Exercise({
    required this.id,
    required this.name,
    this.name_ar,
    required this.force,
    required this.level,
    required this.mechanic,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    this.instructions_ar,
    required this.category,
    required this.images,
  });

  String get localizedName => (currentLocale == 'ar' && name_ar != null) ? name_ar! : name;
  
  List<String> get localizedInstructions => (currentLocale == 'ar' && instructions_ar != null) ? instructions_ar! : instructions;

  String get gifPath {
    if (id.startsWith('custom_')) {
      return images.isNotEmpty ? images[0] : '';
    }
    return 'assets/datasets/gifs/$id.gif';
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: (json['id'] ?? json['exerciseId'])?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Exercise',
      name_ar: json['name_ar']?.toString(),
      force: json['force']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      mechanic: json['mechanic']?.toString() ?? '',
      equipment: (json['equipments'] as List?)?.isNotEmpty == true 
          ? (json['equipments'] as List).first.toString() 
          : (json['equipment']?.toString() ?? ''),
      primaryMuscles: List<String>.from(json['targetMuscles'] ?? json['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      instructions_ar: json['instructions_ar'] != null ? List<String>.from(json['instructions_ar']) : null,
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
      'name_ar': name_ar,
      'force': force,
      'level': level,
      'mechanic': mechanic,
      'equipment': equipment,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
      'instructions_ar': instructions_ar,
      'category': category,
      'images': images,
    };
  }
}
