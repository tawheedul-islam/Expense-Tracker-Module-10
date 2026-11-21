
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../features/expenses/models/expense.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // Get database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('expenses.db');

    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create expenses table
  Future<void> _createDB(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');
  }

  // Insert expense
  Future<int> insertExpense(Expense expense) async {
    final db = await database;

    return await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all expenses
  Future<List<Expense>> getExpenses() async {
    final db = await database;

    final result = await db.query(
      'expenses',
      orderBy: 'id DESC',
    );

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  // Delete expense
  Future<int> deleteExpense(int id) async {
    final db = await database;

    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
