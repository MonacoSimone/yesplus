// To parse this JSON data, do
//
//     final tipoBolla = tipoBollaFromJson(jsonString);

import 'dart:convert';

TipoBolla tipoBollaFromJson(String str) => TipoBolla.fromJson(json.decode(str));

String tipoBollaToJson(TipoBolla data) => json.encode(data.toJson());

class TipoBolla {
  int bltiId;
  String bltiDescr;
  int bltiTipNum;
  int bltiTipo;
  int bltiNaturaDdt;

  TipoBolla({
    required this.bltiId,
    required this.bltiDescr,
    required this.bltiTipNum,
    required this.bltiTipo,
    required this.bltiNaturaDdt,
  });

  factory TipoBolla.fromJson(Map<String, dynamic> json) => TipoBolla(
        bltiId: json["BLTI_ID"],
        bltiDescr: json["BLTI_Descr"] ?? '',
        bltiTipNum: json["BLTI_TipNum"],
        bltiTipo: json["BLTI_Tipo"],
        bltiNaturaDdt: json["BLTI_NaturaDDT"],
      );

  Map<String, dynamic> toJson() => {
        "BLTI_ID": bltiId,
        "BLTI_Descr": bltiDescr,
        "BLTI_TipNum": bltiTipNum,
        "BLTI_Tipo": bltiTipo,
        "BLTI_NaturaDDT": bltiNaturaDdt,
      };
}
