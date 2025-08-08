import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/category_model.dart';
import 'category_api_service.dart';

class CategoryDbService {
  /// Fetches categories from API and populates DB if DB is empty (for any age group)
  static Future<void> syncCategoriesFromApiIfNeeded() async {
  // print('[CategoryDbService] syncCategoriesFromApiIfNeeded called');
    try {
      final existing = await getCategoriesByAgeGroup('kids');
  // print('[CategoryDbService] Existing DB count for kids: \'${existing.length}\'');
      if (existing.isEmpty) {
  // print('[CategoryDbService] DB empty, fetching from API...');
        final apiCats = await CategoryApiService.fetchCategories();
  // print('[CategoryDbService] API returned count: \'${apiCats.length}\'');
        await insertCategories(apiCats);
  // print('[CategoryDbService] Categories inserted into DB');
      } else {
  // print('[CategoryDbService] DB already populated, skipping API fetch');
      }
    } catch (e) {
  // print('[CategoryDbService] Error in syncCategoriesFromApiIfNeeded: $e');
      // Ignore errors, app will fallback to API fetch on category screen if needed
    }
  }
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'categories.db');
    // ...existing code...
    return openDatabase(
      fullPath,
      onCreate: (db, version) async {
        // ...existing code...
        await db.execute('''
          CREATE TABLE categories(
            key TEXT PRIMARY KEY,
            age_group TEXT,
            emoji TEXT,
            labels TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  static Future<void> deleteAllCategories() async {
    final db = await database;
    await db.delete('categories');
  }

  static Future<void> insertCategories(List<CategoryModel> categories) async {
    final db = await database;
    final batch = db.batch();
    for (var cat in categories) {
      batch.insert(
        'categories',
        {
          'key': cat.key,
          'age_group': cat.ageGroup,
          'emoji': cat.emoji,
          'labels': jsonEncode(cat.labels),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    // ...existing code...
  }

  static Future<List<CategoryModel>> getCategoriesByAgeGroup(String ageGroup) async {
    final db = await database;
    // ...existing code...
    // Support both singular and plural forms for age group
    String normalized = ageGroup.trim().toLowerCase();
    List<String> possibleValues = [normalized];
    if (!normalized.endsWith('s')) {
      possibleValues.add(normalized + 's');
    } else if (normalized.endsWith('s')) {
      possibleValues.add(normalized.substring(0, normalized.length - 1));
    }
    final maps = await db.query(
      'categories',
      where: possibleValues.length == 1
          ? 'LOWER(age_group) = ?'
          : '(LOWER(age_group) = ? OR LOWER(age_group) = ?)',
      whereArgs: possibleValues,
    );
    return maps.map((e) => CategoryModel(
      key: e['key'] as String,
      ageGroup: e['age_group'] as String,
      emoji: e['emoji'] as String,
      labels: Map<String, String>.from(jsonDecode(e['labels'] as String)),
    )).toList();
  }

  // evalLabels removed, not needed with jsonEncode/decode
}
