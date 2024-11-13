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
    return Messaggio(
      id: map['id'],
      query: map['query'],
      table: map['table'],
      data: Map<String, dynamic>.from(map['data']),
    );
  }
}
