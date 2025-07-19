import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/report_data.dart';
import '../models/expense_data.dart';
import '../models/stock_item.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseService {
  static Database? _database;
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Initialize sqflite for different platforms
    if (kIsWeb) {
      // Web platform
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop platforms
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // Mobile platforms use default sqflite
    
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'temple_management.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        opening_balance REAL NOT NULL,
        upi_total REAL NOT NULL,
        expense_total REAL NOT NULL,
        grand_total REAL NOT NULL,
        cash_total REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        name TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL UNIQUE,
        purchase_price REAL NOT NULL,
        sale_price REAL NOT NULL,
        stock_quantity INTEGER NOT NULL,
        items_sold INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<List<ReportData>> getReportsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reports',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(maps.length, (i) => ReportData.fromMap(maps[i]));
  }

  static Future<List<ExpenseData>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(maps.length, (i) => ExpenseData.fromMap(maps[i]));
  }

  static Future<void> updateOrCreateStockItem(StockItem stockItem) async {
    final db = await database;
    await db.insert(
      'stock_items',
      stockItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertReport(ReportData report) async {
    final db = await database;
    return await db.insert('reports', report.toMap());
  }

  static Future<int> insertExpense(ExpenseData expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  static Future<List<ReportData>> getReportsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'reports',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return List.generate(maps.length, (i) => ReportData.fromMap(maps[i]));
  }

  static Future<List<ExpenseData>> getExpensesByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return List.generate(maps.length, (i) => ExpenseData.fromMap(maps[i]));
  }

  static Future<void> deleteReportsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    await db.delete(
      'reports',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    
    await db.delete(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
  }

  // Stock management methods
  static Future<void> insertOrUpdateStockItem(Map<String, dynamic> stockItem) async {
    final db = await database;
    await db.insert(
      'inventory_items_stock',
      stockItem,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getAllStockItems() async {
    final db = await database;
    return await db.query('inventory_items_stock');
  }

  static Future<Map<String, dynamic>?> getStockItemByName(String itemName) async {
    final db = await database;
    final result = await db.query(
      'inventory_items_stock',
      where: 'items = ?',
      whereArgs: [itemName],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> updateStockOnSale(String itemName, int quantitySold) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE inventory_items_stock 
      SET item_sold = item_sold + ?, 
          items_in_stock = items_in_stock - ? 
      WHERE items = ? AND items_in_stock >= ?
    ''', [quantitySold, quantitySold, itemName, quantitySold]);
  }

  static Future<void> updateStockQuantity(String itemName, int newStock) async {
    final db = await database;
    await db.update(
      'inventory_items_stock',
      {'items_in_stock': newStock},
      where: 'items = ?',
      whereArgs: [itemName],
    );
  }

  static Future<void> deleteStockItem(String itemName) async {
    final db = await database;
    await db.delete(
      'inventory_items_stock',
      where: 'items = ?',
      whereArgs: [itemName],
    );
  }
}









