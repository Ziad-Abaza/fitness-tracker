class BodyMeasurement {
  final int? id;
  final double weight;
  final double? neck;
  final double? waist;
  final double? hip;
  final double? height;
  final double bodyFat;
  final DateTime date;
  final bool isManualBodyFat;

  BodyMeasurement({
    this.id,
    required this.weight,
    this.neck,
    this.waist,
    this.hip,
    this.height,
    required this.bodyFat,
    required this.date,
    this.isManualBodyFat = false,
  });

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id: map['id'],
      weight: map['weight'],
      neck: map['neck'],
      waist: map['waist'],
      hip: map['hip'],
      height: map['height'],
      bodyFat: map['bodyFat'],
      date: DateTime.parse(map['date']),
      isManualBodyFat: map['isManualBodyFat'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'neck': neck,
      'waist': waist,
      'hip': hip,
      'height': height,
      'bodyFat': bodyFat,
      'date': date.toIso8601String(),
      'isManualBodyFat': isManualBodyFat ? 1 : 0,
    };
  }
}
