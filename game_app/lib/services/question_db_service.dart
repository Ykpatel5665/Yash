import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../truth_dare_data.dart';

class QuestionDbService {
  static final QuestionDbService _instance = QuestionDbService._internal();
  factory QuestionDbService() => _instance;
  QuestionDbService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'questions.db');
    // For schema change, delete old DB (dev only, for production use migration)
    // await deleteDatabase(path); // Only uncomment for schema changes during development
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE questions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT,
            category TEXT,
            ageGroup TEXT,
            type TEXT,
            language TEXT,
            attempt INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> insertQuestions(List<Question> questions) async {
    final db = await database;
    for (final q in questions) {
      final normalizedAgeGroup = q.ageGroup.toLowerCase();
      await db.insert(
        'questions',
        {
          'text': q.text,
          'category': q.category,
          'ageGroup': normalizedAgeGroup,
          'type': q.type,
          'language': q.language ?? 'en',
          'attempt': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Question>> getQuestions({
    required String type,
    required List<String> selectedCategories,
    required String ageGroup,
    required String language,
  }) async {
    final db = await database;
    final normalizedAgeGroup = ageGroup.toLowerCase();
    final result = await db.rawQuery(
      'SELECT * FROM questions WHERE type = ? AND ageGroup = ? AND language = ? AND category IN (${List.filled(selectedCategories.length, '?').join(',')}) AND attempt = 0 ORDER BY RANDOM()',
      [type, normalizedAgeGroup, language, ...selectedCategories],
    );
    return result.map((q) => Question(
      text: q['text'] as String,
      category: q['category'] as String,
      ageGroup: q['ageGroup'] as String,
      type: q['type'] as String,
      language: q['language'] as String,
    )).toList();
  }

  Future<void> incrementAttempt(String text) async {
    final db = await database;
    await db.rawUpdate('UPDATE questions SET attempt = attempt + 1 WHERE text = ?', [text]);
  }

  Future<void> resetAttempts() async {
    final db = await database;
    await db.rawUpdate('UPDATE questions SET attempt = 0');
  }
}
