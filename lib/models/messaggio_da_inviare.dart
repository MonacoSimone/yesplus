import 'dart:convert';

class Messaggio {
  final int? id;
  final String query;
  final String table;
  final Map<String, dynamic> data;

  Messaggio(
      {this.id, required this.query, required this.table, required this.data});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'query': query,
      'table': table,
      'data': data.toString(),
    };
  }

  factory Messaggio.fromMap(Map<String, dynamic> map) {
    // Ottieni il campo METS_Message, che dovrebbe essere una stringa JSON.
    final messaggioJson = map['METS_Message'];

    // Decodifica il JSON per ottenere una mappa.
    final messageMap =
        messaggioJson is String ? jsonDecode(messaggioJson) : messaggioJson;

    return Messaggio(
      id: map['METS_ID'], // Usa la chiave corretta per l'ID
      query: messageMap['QUERY'] ?? '',
      table: messageMap['TABLE'] ?? '',
      data: messageMap['DATA'] != null
          ? Map<String, dynamic>.from(messageMap['DATA'])
          : {},
    );
  }
}
