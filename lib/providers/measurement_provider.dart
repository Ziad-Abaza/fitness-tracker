import 'package:flutter/material.dart';
import '../models/body_measurement.dart';
import '../services/database_helper.dart';

class MeasurementProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<BodyMeasurement> _measurements = [];
  List<BodyMeasurement> get measurements => _measurements;

  Future<void> init() async {
    await fetchMeasurements();
  }

  Future<void> fetchMeasurements() async {
    _measurements = await _db.getMeasurements();
    notifyListeners();
  }

  Future<void> addMeasurement(BodyMeasurement measurement) async {
    await _db.insertMeasurement(measurement);
    await fetchMeasurements();
  }
}
