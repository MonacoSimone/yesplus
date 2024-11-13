import 'package:intl/intl.dart';

class DocumentoShort {
  final int id;
  final String tipo;
  final String numero;
  final DateTime data;
  final String cliente;
  final String stato;
  final String prefisso;

  DocumentoShort(
      {required this.id,
      required this.tipo,
      required this.numero,
      required this.data,
      required this.cliente,
      required this.stato,
      required this.prefisso});

  factory DocumentoShort.fromJson(Map<String, dynamic> json) {
    return DocumentoShort(
        id: json['Id'],
        tipo: json['Tipo'],
        numero: json['Numero'],
        data: DateFormat('yyyy-MM-dd').parse(json['Data']),
        cliente: json['Cliente'],
        stato: json['Stato'],
        prefisso: json['Prefisso']);
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Tipo': tipo,
      'Numero': numero,
      'Data': DateFormat('yyyy-MM-dd').format(data),
      'Cliente': cliente,
      'Stato': stato,
      'Prefisso': prefisso
    };
  }
}
