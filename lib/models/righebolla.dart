// To parse this JSON data, do
//
//     final righeFattura = righeFatturaFromJson(jsonString);

import 'dart:convert';

RigaBolla righeBollaFromJson(String str) =>
    RigaBolla.fromJson(json.decode(str));

String rigaBollaToJson(RigaBolla data) => json.encode(data.toJson());

class RigaBolla {
  int blarId;
  int blarBlanId;
  double blarNumRiga;
  int blarMgaaId;
  double blarQuantita;
  String blarMbumCodice;
  double blarPrezzo;
  String blarDescrArt;
  double blarTotSconti;
  double blarScontiFinali;
  double blarDqta;
  int blarMbtaCodice;

  RigaBolla(
      {required this.blarId,
      required this.blarBlanId,
      required this.blarNumRiga,
      required this.blarMgaaId,
      required this.blarQuantita,
      required this.blarMbumCodice,
      required this.blarPrezzo,
      required this.blarDescrArt,
      required this.blarTotSconti,
      required this.blarScontiFinali,
      required this.blarDqta,
      required this.blarMbtaCodice});

  factory RigaBolla.fromJson(Map<String, dynamic> json) => RigaBolla(
      blarId: json["BLAR_ID"] ?? 0,
      blarBlanId: json["BLAR_BLAN_ID"] ?? 0,
      blarNumRiga: json["BLAR_NumRiga"]?.toDouble() ?? 0.0,
      blarMgaaId: json["BLAR_MGAA_ID"] ?? 0,
      blarQuantita: json["BLAR_Quantita"]?.toDouble() ?? 0.0,
      blarMbumCodice: json["BLAR_MBUM_Codice"] ?? '',
      blarPrezzo: json["BLAR_Prezzo"]?.toDouble() ?? 0.0,
      blarDescrArt: json["BLAR_DescrArt"] ?? '',
      blarTotSconti: json["BLAR_TotSconti"]?.toDouble() ?? 0.0,
      blarScontiFinali: json["BLAR_ScontiFinali"]?.toDouble() ?? 0.0,
      blarDqta: json["BLAR_DQTA"]?.toDouble() ?? 0.0,
      blarMbtaCodice: json["BLAR_MBTA_Codice"] ?? 1);

  Map<String, dynamic> toJson() => {
        "BLAR_ID": blarId,
        "BLAR_BLAN_ID": blarBlanId,
        "BLAR_NumRiga": blarNumRiga,
        "BLAR_MGAA_ID": blarMgaaId,
        "BLAR_Quantita": blarQuantita,
        "BLAR_MBUM_Codice": blarMbumCodice,
        "BLAR_Prezzo": blarPrezzo,
        "BLAR_DescrArt": blarDescrArt,
        "BLAR_TotSconti": blarTotSconti,
        "BLAR_ScontiFinali": blarScontiFinali,
        "BLAR_DQTA": blarDqta,
        "BLAR_MBTA_Codice": blarMbtaCodice
      };
}
