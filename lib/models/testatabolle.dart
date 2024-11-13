// To parse this JSON data, do
//
//     final righeFattura = righeFatturaFromJson(jsonString);

import 'dart:convert';

TestataBolla righeBollaFromJson(String str) =>
    TestataBolla.fromJson(json.decode(str));

String righeBollaToJson(TestataBolla data) => json.encode(data.toJson());

class TestataBolla {
  int blanId;
  int blanBltiId;
  int blanAnnoBol;
  int blanNumBol;
  String blanDataIns;
  int blanMbpcId;
  bool blanStamp;
  bool blanScaric;
  bool blanValor;
  String blanDestinat;
  double blanTotBolla;
  int blanDestMbanId;
  String blanDataCreate;

  TestataBolla({
    required this.blanId,
    required this.blanBltiId,
    required this.blanAnnoBol,
    required this.blanNumBol,
    required this.blanDataIns,
    required this.blanMbpcId,
    required this.blanStamp,
    required this.blanScaric,
    required this.blanValor,
    required this.blanDestinat,
    required this.blanTotBolla,
    required this.blanDestMbanId,
    required this.blanDataCreate,
  });

  factory TestataBolla.fromJson(Map<String, dynamic> json) => TestataBolla(
        blanId: json["BLAN_ID"] ?? 0,
        blanBltiId: json["BLAN_BLTI_ID"] ?? 0,
        blanAnnoBol: json["BLAN_AnnoBol"] ?? 0,
        blanNumBol: json["BLAN_NumBol"] ?? 0,
        blanDataIns: json["BLAN_DataIns"] == null
            ? DateTime.now().toString()
            : DateTime.parse(json["BLAN_DataIns"]).toString(),
        blanMbpcId: json["BLAN_MBPC_ID"] ?? 0,
        blanStamp: json["BLAN_Stamp"] ?? 0,
        blanScaric: json["BLAN_Scaric"] ?? 0,
        blanValor: json["BLAN_Valor"] ?? 0,
        blanDestinat: json["BLAN_Destinat"] ?? '',
        blanTotBolla: json["BLAN_TotBolla"]?.toDouble() ?? 0.0,
        blanDestMbanId: json["BLAN_Dest_MBAN_ID"] ?? 0,
        blanDataCreate: json["BLAN_DataCreate"] == null
            ? DateTime.now().toString()
            : DateTime.parse(json["BLAN_DataCreate"]).toString(),
      );

  Map<String, dynamic> toJson() => {
        "BLAN_ID": blanId,
        "BLAN_BLTI_ID": blanBltiId,
        "BLAN_AnnoBol": blanAnnoBol,
        "BLAN_NumBol": blanNumBol,
        "BLAN_DataIns": blanDataIns,
        "BLAN_MBPC_ID": blanMbpcId,
        "BLAN_Stamp": blanStamp,
        "BLAN_Scaric": blanScaric,
        "BLAN_Valor": blanValor,
        "BLAN_Destinat": blanDestinat,
        "BLAN_TotBolla": blanTotBolla,
        "BLAN_Dest_MBAN_ID": blanDestMbanId,
        "BLAN_DataCreate": blanDataCreate,
      };
}
