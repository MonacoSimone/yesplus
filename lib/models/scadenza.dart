// To parse this JSON data, do
//
//     final scadenziario = scadenziarioFromJson(jsonString);

import 'dart:convert';

Scadenziario scadenziarioFromJson(String str) =>
    Scadenziario.fromJson(json.decode(str));

String scadenziarioToJson(Scadenziario data) => json.encode(data.toJson());

class Scadenziario {
  List<Scadenza> scadenze;
  Scadenziario({
    required this.scadenze,
  });

  factory Scadenziario.fromJson(Map<String, dynamic> json) => Scadenziario(
        scadenze: List<Scadenza>.from(
            json["Scadenze"].map((x) => Scadenza.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Scadenze": List<dynamic>.from(scadenze.map((x) => x.toJson())),
      };
}

class Scadenza {
  int caspStato;
  int capaId;
  int capaMbpcId;
  String capaNumDoc;
  String capaDataDoc;
  String capaScadenza;
  double capaImportoAvere;
  double capaImportoDare;
  double capaResiduo;
  int capaPartPag;
  bool capaPagCreate;
  bool capaSelected;
  double capaPagCnt;
  double capaPagAss;
  double capaPagTit;

  Scadenza(
      {required this.caspStato,
      required this.capaId,
      required this.capaMbpcId,
      required this.capaNumDoc,
      required this.capaDataDoc,
      required this.capaScadenza,
      required this.capaImportoAvere,
      required this.capaImportoDare,
      required this.capaResiduo,
      required this.capaPartPag,
      required this.capaPagCreate,
      required this.capaSelected,
      required this.capaPagCnt,
      required this.capaPagAss,
      required this.capaPagTit});

  factory Scadenza.fromJson(Map<String, dynamic> json) => Scadenza(
      caspStato: json["CAPA_CASP_Stato"] ?? 0,
      capaId: json["CAPA_Id"] ?? 0,
      capaMbpcId: json["CAPA_MBPC_ID"] ?? 0,
      capaNumDoc: json["CAPA_NumDoc"] ?? '',
      capaDataDoc:
          DateTime.parse(json["CAPA_DataDoc"] ?? '1970-01-01').toString(),
      capaScadenza:
          DateTime.parse(json["CAPA_Scadenza"] ?? '1970-01-01').toString(),
      capaImportoAvere: json["CAPA_ImportoAvere"]?.toDouble(),
      capaImportoDare: json["CAPA_ImportoDare"]?.toDouble(),
      capaResiduo: json["CAPA_Residuo"]?.toDouble(),
      capaPartPag: json["CAPA_PartPag"] ?? 0,
      capaPagCreate: json["CAPA_PagCreate"] ?? 0,
      capaSelected: json["CAPA_Selected"] ?? 0,
      capaPagCnt:
          json["CAPA_PagCnt"] == null ? 0.0 : json["CAPA_PagCnt"]?.toDouble(),
      capaPagAss:
          json["CAPA_PagAss"] == null ? 0.0 : json["CAPA_PagAss"]?.toDouble(),
      capaPagTit:
          json["CAPA_PagTit"] == null ? 0.0 : json["CAPA_PagTit"]?.toDouble());

  Map<String, dynamic> toJson() => {
        "CAPA_CASP_Sato": caspStato,
        "CAPA_Id": capaId,
        "CAPA_MBPC_ID": capaMbpcId,
        "CAPA_NumDoc": capaNumDoc,
        "CAPA_DataDoc": capaDataDoc,
        "CAPA_Scadenza": capaScadenza,
        "CAPA_ImportoAvere": capaImportoAvere,
        "CAPA_ImportoDare": capaImportoDare,
        "CAPA_Residuo": capaResiduo,
        "CAPA_PartPag": capaPartPag,
        "CAPA_PagCreate": capaPagCreate,
        "CAPA_Selected": capaSelected,
        "CAPA_PagCnt": capaPagCnt,
        "CAPA_PagAss": capaPagAss,
        "CAPA_PagTit": capaPagTit
      };
}
