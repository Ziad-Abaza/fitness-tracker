import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/exercise.dart';

class ExerciseService {
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  List<Exercise> _exercises = [];
  List<String> _bodyParts = [];
  List<String> _muscles = [];
  List<String> _equipments = [];

  List<Exercise> get exercises => _exercises;
  List<String> get bodyParts => _bodyParts;
  List<String> get muscles => _muscles;
  List<String> get equipments => _equipments;

  Future<void> init() async {
    await Future.wait([
      _loadExercises(),
      _loadBodyParts(),
      _loadMuscles(),
      _loadEquipments(),
    ]);
  }

  Future<void> _loadExercises() async {
    try {
      final String response = await rootBundle.loadString('assets/datasets/exercises.json');
      final List<dynamic> data = json.decode(response);
      _exercises = data.map((json) => Exercise.fromJson(json)).toList();
    } catch (e) {
      print('Error loading exercises: $e');
    }
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
