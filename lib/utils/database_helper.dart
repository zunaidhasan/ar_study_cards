import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/flashcard.dart';

class DatabaseHelper {
  static const _databaseName = 'ar_study_cards.db';
  static const _databaseVersion = 1;
  static const _table = 'flashcards';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_table (
        id TEXT PRIMARY KEY,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        category TEXT NOT NULL,
        completed INTEGER NOT NULL,
        reviewCount INTEGER NOT NULL,
        lastReviewed TEXT
      )
    ''');
  }

  Future<void> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    await db.insert(_table, flashcard.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertFlashcards(List<Flashcard> flashcards) async {
    final db = await database;
    final batch = db.batch();
    for (var flashcard in flashcards) {
      batch.insert(_table, flashcard.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<List<Flashcard>> getFlashcards() async {
    final db = await database;
    final maps = await db.query(_table);
    return maps.map((map) => Flashcard.fromJson(map)).toList();
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    final db = await database;
    await db.update(
      _table,
      flashcard.toJson(),
      where: 'id = ?',
      whereArgs: [flashcard.id],
    );
  }
}