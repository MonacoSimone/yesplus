import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseController extends GetxController {
  RxString query = ''.obs; // Contiene la query inserita
  RxList<Map<String, dynamic>> queryResults =
      <Map<String, dynamic>>[].obs; // Contiene i risultati

  Database? _db;

  // Inizializza il database
  @override
  void onInit() {
    super.onInit();
    _initDb();
  }

  Future<void> _initDb() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'order_entry.db'),
    );
  }

  // Funzione per eseguire la query
  Future<void> executeQuery() async {
    if (_db != null && query.value.isNotEmpty) {
      try {
        final List<Map<String, dynamic>> results =
            await _db!.rawQuery(query.value);
        queryResults.assignAll(results); // Aggiorna i risultati
      } catch (e) {
        Get.snackbar("Errore", "Errore nell'esecuzione della query: $e");
      }
    } else {
      Get.snackbar("Errore", "Query vuota o database non inizializzato");
    }
  }
}
