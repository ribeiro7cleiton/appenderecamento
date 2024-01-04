import 'package:enderecamento/controllers/registro_pendente.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'enderecamento.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE enderecamento(id INTEGER PRIMARY KEY AUTOINCREMENT,codbar TEXT, codori TEXT,codend TEXT, datent TEXT, horent TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertRegistro(Registro registro) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.insert('enderecamento', registro.toMap());
    return result;
  }

  Future<List<Registro>> retrieveUsers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object>> queryResult =
        await db.query('enderecamento');
    return queryResult.map((e) => Registro.fromMap(e)).toList();
  }

  Future<int> deleteRegistro(int id) async {
    final db = await initializeDB();
    await db.delete(
      'enderecamento',
      where: "id = ?",
      whereArgs: [id],
    );
    return 1;
  }
}
