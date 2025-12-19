import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/ticket.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  final _controller = StreamController<List<Ticket>>.broadcast();

  Stream<List<Ticket>> get ticketsStream => _controller.stream;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ticket_saver.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trainName TEXT NOT NULL,
        fromStation TEXT NOT NULL,
        toStation TEXT NOT NULL,
        travelDate TEXT NOT NULL,
        pdfPath TEXT NOT NULL -- This column stores either PDF or Image path
      )
    ''');
  }

  Future<int> insertTicket(Ticket ticket) async {
    final db = await database;
    final id = await db.insert('tickets', ticket.toMap());
    await refreshTickets();
    return id;
  }

  Future<void> refreshTickets() async {
    final tickets = await getTickets();
    _controller.add(tickets);
  }

  Future<List<Ticket>> getTickets() async {
    final db = await database;
    // Using rawQuery as requested by user
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM tickets ORDER BY travelDate DESC',
    );
    return List.generate(maps.length, (i) {
      return Ticket.fromMap(maps[i]);
    });
  }

  Future<int> deleteTicket(int id) async {
    final db = await database;
    final result = await db.rawDelete('DELETE FROM tickets WHERE id = ?', [id]);
    await refreshTickets();
    return result;
  }
}
