// To parse this JSON data, do
//
//     final righeFattura = righeFatturaFromJson(jsonString);

import 'dart:convert';

RigaFattura rigaFatturaFromJson(String str) =>
    RigaFattura.fromJson(json.decode(str));

String rigaFatturaToJson(RigaFattura data) => json.encode(data.toJson());

class RigaFattura {
  int ftarId;
  int ftarFtanId;
  double ftarNumRiga;
  int ftarMgaaId;
  String ftarDescr;
  double ftarQuantita;
  String ftarMbumCodice;
  double ftarPrezzo;
  double ftarTotSconti;
  double ftarScontiFinali;
  String ftarNote;
  double ftarDqta;
  bool ftarRivalsaIva;
  int ftarMbtaCodice;

  RigaFattura(
      {required this.ftarId,
      required this.ftarFtanId,
      required this.ftarNumRiga,
      required this.ftarMgaaId,
      required this.ftarDescr,
      required this.ftarQuantita,
      required this.ftarMbumCodice,
      required this.ftarPrezzo,
      required this.ftarTotSconti,
      required this.ftarScontiFinali,
      required this.ftarNote,
      required this.ftarDqta,
      required this.ftarRivalsaIva,
      required this.ftarMbtaCodice});

  factory RigaFattura.fromJson(Map<String, dynamic> json) => RigaFattura(
      ftarId: json["FTAR_ID"] ?? 0,
      ftarFtanId: json["FTAR_FTAN_ID"] ?? '',
      ftarNumRiga: json["FTAR_NumRiga"]?.toDouble() ?? 0.0,
      ftarMgaaId: json["FTAR_MGAA_ID"] ?? 0,
      ftarDescr: json["FTAR_Descr"] ?? '',
      ftarQuantita: json["FTAR_Quantita"]?.toDouble() ?? 0.0,
      ftarMbumCodice: json["FTAR_MBUM_Codice"] ?? '',
      ftarPrezzo: json["FTAR_Prezzo"]?.toDouble() ?? 0.0,
      ftarTotSconti: json["FTAR_TotSconti"]?.toDouble() ?? 0.0,
      ftarScontiFinali: json["FTAR_ScontiFinali"]?.toDouble() ?? 0.0,
      ftarNote: json["FTAR_Note"] ?? '',
      ftarDqta: json["FTAR_DQTA"]?.toDouble() ?? 0.0,
      ftarRivalsaIva: json["FTAR_RivalsaIva"] ?? false,
      ftarMbtaCodice: json["FTAR_MBTA_Codice"] ?? 1);

  Map<String, dynamic> toJson() => {
        "FTAR_ID": ftarId,
        "FTAR_FTAN_ID": ftarFtanId,
        "FTAR_NumRiga": ftarNumRiga,
        "FTAR_MGAA_ID": ftarMgaaId,
        "FTAR_Descr": ftarDescr,
        "FTAR_Quantita": ftarQuantita,
        "FTAR_MBUM_Codice": ftarMbumCodice,
        "FTAR_Prezzo": ftarPrezzo,
        "FTAR_TotSconti": ftarTotSconti,
        "FTAR_ScontiFinali": ftarScontiFinali,
        "FTAR_Note": ftarNote,
        "FTAR_DQTA": ftarDqta,
        "FTAR_RivalsaIva": ftarRivalsaIva,
        "FTAR_MBTA_Codice": ftarMbtaCodice
      };
}
