import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // Mengambil database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('catatan_keuangan.db');

    return _database!;
  }

  // Membuka database
  Future<Database> _initDB(String fileName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  // Membuat tabel database
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id)
          REFERENCES users (id)
          ON DELETE CASCADE
      )
    ''');
  }

  // ==============================
  // FUNGSI PENGGUNA
  // ==============================

  // Menambahkan pengguna
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;

    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Mengambil pengguna berdasarkan email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // ==============================
  // FUNGSI TRANSAKSI
  // ==============================

  // Menambahkan transaksi
  Future<int> insertTransaction(
    Map<String, dynamic> transaction,
  ) async {
    final db = await database;

    return await db.insert(
      'transactions',
      transaction,
    );
  }

  // Mengambil seluruh transaksi
  Future<List<Map<String, dynamic>>> getTransactions(
    int userId,
  ) async {
    final db = await database;

    return await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
  }

  // Mengambil detail transaksi berdasarkan ID
  Future<Map<String, dynamic>?> getTransactionById(
    int id,
  ) async {
    final db = await database;

    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // Mengubah transaksi
  Future<int> updateTransaction(
    int id,
    Map<String, dynamic> transaction,
  ) async {
    final db = await database;

    return await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menghapus transaksi
  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menghitung total pengeluaran pengguna
  Future<int> getTotalExpense(int userId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE user_id = ?
      ''',
      [userId],
    );

    return (result.first['total'] as num).toInt();
  }

  // Memeriksa tabel database
  Future<List<String>> getTableNames() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      AND name NOT LIKE 'sqlite_%'
    ''');

    return result.map((row) => row['name'] as String).toList();
  }

  // Menutup koneksi database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}