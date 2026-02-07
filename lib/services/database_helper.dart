import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/routine.dart';
import '../models/workout_session.dart';
import '../models/set_log.dart';
import '../models/body_measurement.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE routines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routineId INTEGER NOT NULL,
        exerciseId TEXT NOT NULL,
        position INTEGER NOT NULL,
        FOREIGN KEY (routineId) REFERENCES routines (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routineId INTEGER,
        routineName TEXT,
        startTime TEXT NOT NULL,
        endTime TEXT,
        FOREIGN KEY (routineId) REFERENCES routines (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER NOT NULL,
        exerciseId TEXT NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE body_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        neck REAL,
        waist REAL,
        hip REAL,
        height REAL,
        bodyFat REAL NOT NULL,
        date TEXT NOT NULL,
        isManualBodyFat INTEGER NOT NULL
      )
    ''');
  }

  // Body Measurement Methods
  Future<int> insertMeasurement(BodyMeasurement measurement) async {
    final db = await instance.database;
    return await db.insert('body_measurements', measurement.toMap());
  }

  Future<List<BodyMeasurement>> getMeasurements() async {
    final db = await instance.database;
    final result = await db.query('body_measurements', orderBy: 'date DESC');
    return result.map((json) => BodyMeasurement.fromMap(json)).toList();
  }

  // Routine Methods
  Future<int> insertRoutine(Routine routine) async {
    final db = await instance.database;
    final routineId = await db.insert('routines', routine.toMap());
    
    for (int i = 0; i < routine.exerciseIds.length; i++) {
      await db.insert('routine_exercises', {
        'routineId': routineId,
        'exerciseId': routine.exerciseIds[i],
        'position': i,
      });
    }
    return routineId;
  }

  Future<List<Routine>> getAllRoutines() async {
    final db = await instance.database;
    final result = await db.query('routines', orderBy: 'createdAt DESC');
    
    List<Routine> routines = [];
    for (var row in result) {
      final exercises = await db.query(
        'routine_exercises',
        where: 'routineId = ?',
        whereArgs: [row['id']],
        orderBy: 'position ASC',
      );
      final exerciseIds = exercises.map((e) => e['exerciseId'] as String).toList();
      routines.add(Routine.fromMap(row, exerciseIds));
    }
    return routines;
  }

  // Session Methods
  Future<int> startSession({int? routineId, String? routineName}) async {
    final db = await instance.database;
    return await db.insert('sessions', {
      'routineId': routineId,
      'routineName': routineName,
      'startTime': DateTime.now().toIso8601String(),
    });
  }

  Future<void> endSession(int sessionId) async {
    final db = await instance.database;
    await db.update(
      'sessions',
      {'endTime': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Set Methods
  Future<int> insertSet(SetLog setLog) async {
    final db = await instance.database;
    return await db.insert('sets', setLog.toMap());
  }

  Future<List<SetLog>> getSetsForSession(int sessionId) async {
    final db = await instance.database;
    final result = await db.query(
      'sets',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return result.map((json) => SetLog.fromMap(json)).toList();
  }

  // Smart History: Get last performance for an exercise
  Future<SetLog?> getLastPerformance(String exerciseId) async {
    final db = await instance.database;
    final result = await db.query(
      'sets',
      where: 'exerciseId = ? AND isCompleted = 1',
      whereArgs: [exerciseId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return SetLog.fromMap(result.first);
    }
    return null;
  }

  Future<double> getMaxWeightForExercise(String exerciseId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT MAX(weight) as maxWeight FROM sets WHERE exerciseId = ? AND isCompleted = 1',
      [exerciseId],
    );
    return (result.first['maxWeight'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> deleteSession(int sessionId) async {
    final db = await instance.database;
    await db.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
  }

  Future<List<Map<String, dynamic>>> getWeightHistory(String exerciseId) async {
    final db = await instance.database;
    return await db.rawQuery(
      'SELECT weight, reps, timestamp FROM sets WHERE exerciseId = ? AND isCompleted = 1 ORDER BY timestamp ASC',
      [exerciseId],
    );
  }

  Future<List<WorkoutSession>> getAllSessions() async {
    final db = await instance.database;
    final result = await db.query('sessions', orderBy: 'startTime DESC');
    
    List<WorkoutSession> sessions = [];
    for (var row in result) {
      final sets = await getSetsForSession(row['id'] as int);
      sessions.add(WorkoutSession.fromMap(row, sets: sets));
    }
    return sessions;
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('sets');
    await db.delete('sessions');
    await db.delete('routine_exercises');
    await db.delete('routines');
    await db.delete('body_measurements');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
