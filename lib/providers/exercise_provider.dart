import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';

class ExerciseProvider with ChangeNotifier {
  final ExerciseService _exerciseService = ExerciseService();
  
  List<Exercise> _filteredExercises = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String? _selectedBodyPart;
  String? _selectedMuscle;
  String? _selectedEquipment;

  List<Exercise> get exercises => _filteredExercises;
  bool get isLoading => _isLoading;

  String? get selectedBodyPart => _selectedBodyPart;
  String? get selectedMuscle => _selectedMuscle;
  String? get selectedEquipment => _selectedEquipment;

  List<String> get bodyParts => _exerciseService.bodyParts;
  List<String> get muscles => _exerciseService.muscles;
  List<String> get equipments => _exerciseService.equipments;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    await _exerciseService.init();
    _filteredExercises = _exerciseService.exercises;
    
    _isLoading = false;
    notifyListeners();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setBodyPart(String? bodyPart) {
    _selectedBodyPart = bodyPart;
    _applyFilters();
  }

  void setMuscle(String? muscle) {
    _selectedMuscle = muscle;
    _applyFilters();
  }

  void setEquipment(String? equipment) {
    _selectedEquipment = equipment;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredExercises = _exerciseService.filterExercises(
      query: _searchQuery,
      bodyPart: _selectedBodyPart,
      muscle: _selectedMuscle,
      equipment: _selectedEquipment,
    );
    notifyListeners();
  }

  Exercise? getExerciseById(String id) => _exerciseService.getExerciseById(id);

  Future<void> addCustomExercise(Exercise exercise) async {
    final Map<String, dynamic> map = {
      'id': exercise.id,
      'name': exercise.name,
      'name_ar': exercise.name_ar,
      'force': exercise.force,
      'level': exercise.level,
      'mechanic': exercise.mechanic,
      'equipment': exercise.equipment,
      'primaryMuscles': exercise.primaryMuscles.join(','),
      'secondaryMuscles': exercise.secondaryMuscles.join(','),
      'instructions': exercise.instructions.join('|'),
      'instructions_ar': exercise.instructions_ar?.join('|') ?? '',
      'category': exercise.category,
      'images': exercise.images.join(','),
    };
    
    await _exerciseService.saveUserExercise(map);
    _applyFilters();
  }
}
