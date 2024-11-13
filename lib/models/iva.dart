// To parse this JSON data, do
//
//     final iva = ivaFromJson(jsonString);

import 'dart:convert';

Iva ivaFromJson(String str) => Iva.fromJson(json.decode(str));

String ivaToJson(Iva data) => json.encode(data.toJson());

class Iva {
  int mbivId;
  int mbivIva;
  String mbivDescr;
  int mbivPerc;

  Iva({
    required this.mbivId,
    required this.mbivIva,
    required this.mbivDescr,
    required this.mbivPerc,
  });

  factory Iva.fromJson(Map<String, dynamic> json) => Iva(
        mbivId: json["MBIV_ID"] ?? 0,
        mbivIva: json["MBIV_IVA"] ?? 0,
        mbivDescr: json["MBIV_Descr"] ?? '',
        mbivPerc: json["MBIV_Perc"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "MBIV_ID": mbivId,
        "MBIV_IVA": mbivIva,
        "MBIV_Descr": mbivDescr,
        "MBIV_Perc": mbivPerc,
      };
}
