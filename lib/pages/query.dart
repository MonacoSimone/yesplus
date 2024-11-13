import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/database_controller.dart'; // Aggiorna il percorso del controller

class QueryPage extends StatelessWidget {
  final DatabaseController dbController = Get.put(DatabaseController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esegui Query Manuali'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField per inserire la query
            TextField(
              onChanged: (value) => dbController.query.value = value,
              decoration: const InputDecoration(
                labelText: 'Inserisci la tua query',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            // Pulsante per eseguire la query
            ElevatedButton(
              onPressed: dbController.executeQuery,
              child: const Text('Esegui Query'),
            ),
            const SizedBox(height: 20),
            // Sezione per mostrare i risultati della query
            Expanded(
              child: Obx(() {
                if (dbController.queryResults.isEmpty) {
                  return const Center(child: Text('Nessun risultato trovato'));
                }

                // Mostra i risultati in una DataTable
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: dbController.queryResults.isNotEmpty
                        ? dbController.queryResults.first.keys
                            .map((key) => DataColumn(label: Text(key)))
                            .toList()
                        : [],
                    rows: dbController.queryResults
                        .map(
                          (result) => DataRow(
                            cells: result.values
                                .map(
                                    (value) => DataCell(Text(value.toString())))
                                .toList(),
                          ),
                        )
                        .toList(),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
