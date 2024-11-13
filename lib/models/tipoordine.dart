// To parse this JSON data, do
//
//     final tipoOrdine = tipoOrdineFromJson(jsonString);

import 'dart:convert';

TipoOrdine tipoOrdineFromJson(String str) =>
    TipoOrdine.fromJson(json.decode(str));

String tipoOrdineToJson(TipoOrdine data) => json.encode(data.toJson());

class TipoOrdine {
  int octiId;
  String octiDescr;
  int octiTipNum;
  int octiTipo;

  TipoOrdine({
    required this.octiId,
    required this.octiDescr,
    required this.octiTipNum,
    required this.octiTipo,
  });

  factory TipoOrdine.fromJson(Map<String, dynamic> json) => TipoOrdine(
        octiId: json["OCTI_ID"],
        octiDescr: json["OCTI_Descr"],
        octiTipNum: json["OCTI_TipNum"],
        octiTipo: json["OCTI_Tipo"],
      );

  Map<String, dynamic> toJson() => {
        "OCTI_ID": octiId,
        "OCTI_Descr": octiDescr,
        "OCTI_TipNum": octiTipNum,
        "OCTI_Tipo": octiTipo,
      };
}
