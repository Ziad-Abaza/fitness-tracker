import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import 'database_helper.dart';

class ExerciseService {
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Exercise> _exercises = [];
  List<Exercise> _jsonExercises = [];
  List<String> _bodyParts = [];
  List<String> _muscles = [];
  List<String> _equipments = [];

  List<Exercise> get exercises => _exercises;
  List<String> get bodyParts => _bodyParts;
  List<String> get muscles => _muscles;
  List<String> get equipments => _equipments;

  Future<void> init() async {
    await Future.wait([
      _loadJsonExercises(),
      _loadBodyParts(),
      _loadMuscles(),
      _loadEquipments(),
    ]);
    await reloadUserExercises();
  }

  Future<void> _loadJsonExercises() async {
    try {
      final String response = await rootBundle.loadString('assets/datasets/exercises.json');
      final List<dynamic> data = json.decode(response);
      _jsonExercises = data.map((json) => Exercise.fromJson(json)).toList();
    } catch (e) {
      print('Error loading json exercises: $e');
    }
  }

  Future<void> reloadUserExercises() async {
    final userExMaps = await _db.getAllUserExercises();
    final userExercises = userExMaps.map((map) {
      // Manual conversion from DB map to Exercise model matching Exercise.fromJson logic
      return Exercise(
        id: map['id'],
        name: map['name'],
        name_ar: map['name_ar'],
        force: map['force'] ?? '',
        level: map['level'] ?? '',
        mechanic: map['mechanic'] ?? '',
        equipment: map['equipment'] ?? '',
        primaryMuscles: (map['primaryMuscles'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
        secondaryMuscles: (map['secondaryMuscles'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
        instructions: (map['instructions'] as String?)?.split('|').where((s) => s.isNotEmpty).toList() ?? [],
        instructions_ar: (map['instructions_ar'] as String?)?.split('|').where((s) => s.isNotEmpty).toList() ?? [],
        category: map['category'] ?? '',
        images: (map['images'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      );
    }).toList();

    _exercises = [...userExercises, ..._jsonExercises];
  }

  Future<void> saveUserExercise(Map<String, dynamic> exercise) async {
    await _db.insertUserExercise(exercise);
    await reloadUserExercises();
  }

  Future<void> _loadBodyParts() async {
    try {
      final String response = await rootBundle.loadString('assets/datasets/bodyParts.json');
      final List<dynamic> data = json.decode(response);
      _bodyParts = data.map((item) => item['name'].toString()).toList();
    } catch (e) {
      print('Error loading body parts: $e');
    }
  }

  Future<void> _loadMuscles() async {
    try {
      final String response = await rootBundle.loadString('assets/datasets/muscles.json');
      final List<dynamic> data = json.decode(response);
      _muscles = data.map((item) => item['name'].toString()).toList();
    } catch (e) {
      print('Error loading muscles: $e');
    }
  }

  Future<void> _loadEquipments() async {
    try {
      final String response = await rootBundle.loadString('assets/datasets/equipments.json');
      final List<dynamic> data = json.decode(response);
      _equipments = data.map((item) => item['name'].toString()).toList();
    } catch (e) {
      print('Error loading equipments: $e');
    }
  }

  List<Exercise> filterExercises({
    String? query,
    String? bodyPart,
    String? muscle,
    String? equipment,
  }) {
    return _exercises.where((exercise) {
      final matchesQuery = query == null || 
          exercise.name.toLowerCase().contains(query.toLowerCase());
      final matchesBodyPart = bodyPart == null || 
          exercise.category.toLowerCase() == bodyPart.toLowerCase();
      final matchesMuscle = muscle == null || 
          exercise.primaryMuscles.contains(muscle) || 
          exercise.secondaryMuscles.contains(muscle);
      final matchesEquipment = equipment == null || 
          exercise.equipment == equipment;
      
      return matchesQuery && matchesBodyPart && matchesMuscle && matchesEquipment;
    }).toList();
  }

  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
