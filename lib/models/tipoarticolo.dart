// To parse this JSON data, do
//
//     final tipoArticolo = tipoArticoloFromJson(jsonString);

import 'dart:convert';

TipoArticolo tipoArticoloFromJson(String str) =>
    TipoArticolo.fromJson(json.decode(str));

String tipoArticoloToJson(TipoArticolo data) => json.encode(data.toJson());

class TipoArticolo {
  int mbtaId;
  String mbtaDescr;
  int mbtaCodice;

  TipoArticolo({
    required this.mbtaId,
    required this.mbtaDescr,
    required this.mbtaCodice,
  });

  factory TipoArticolo.fromJson(Map<String, dynamic> json) => TipoArticolo(
        mbtaId: json["MBTA_ID"],
        mbtaDescr: json["MBTA_Descr"] ?? '',
        mbtaCodice: json["MBTA_Codice"],
      );

  Map<String, dynamic> toJson() => {
        "MBTA_ID": mbtaId,
        "MBTA_Descr": mbtaDescr,
        "MBTA_Codice": mbtaCodice,
      };
}
