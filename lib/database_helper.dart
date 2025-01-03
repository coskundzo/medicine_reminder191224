import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db/medicine.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medicines.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT UNIQUE,
        dosage TEXT,
        startDate TEXT NOT NULL,
        time TEXT NOT NULL,
        frequency INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    return await db.insert('medicines', medicine.toMap());
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await database;
    final result = await db.query('medicines');

    return result.map((map) => Medicine.fromMap(map)).toList();
  }

  Future<int> deleteMedicine(int id) async {
    final db = await database;
    return await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateMedicine(Medicine medicine) async {
    final db = await instance.database;
    return await db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<bool> isMedicineNameExists(String name) async {
    final db = await database;
    final result = await db.query(
      'medicines',
      where: 'name = ?',
      whereArgs: [name],
    );
    return result.isNotEmpty;
  }
}
