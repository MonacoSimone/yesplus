// To parse this JSON data, do
//
//     final righeFattura = righeFatturaFromJson(jsonString);

import 'dart:convert';

RigaOrdine righeOrdineFromJson(String str) =>
    RigaOrdine.fromJson(json.decode(str));

String righeOrdineToJson(RigaOrdine data) => json.encode(data.toJson());

class RigaOrdine {
  int ocarId;
  int ocarOcanId;
  double ocarNumRiga;
  int ocarMgaaId;
  double ocarQuantita;
  String ocarMbumCodice;
  double ocarPrezzo;
  String ocarDescrArt;
  double ocarTotSconti;
  double ocarScontiFinali;
  double? ocarPrezzoListino;
  double ocarDqta;
  int ocarEForz;
  int ocarMbtaCodice;
  String? ocarAppID;

  RigaOrdine(
      {required this.ocarId,
      required this.ocarOcanId,
      required this.ocarNumRiga,
      required this.ocarMgaaId,
      required this.ocarQuantita,
      required this.ocarMbumCodice,
      required this.ocarPrezzo,
      required this.ocarDescrArt,
      required this.ocarTotSconti,
      required this.ocarScontiFinali,
      required this.ocarPrezzoListino,
      required this.ocarDqta,
      required this.ocarEForz,
      required this.ocarMbtaCodice,
      required this.ocarAppID});

  factory RigaOrdine.fromJson(Map<String, dynamic> json) => RigaOrdine(
      ocarId: json["OCAR_ID"] ?? 0,
      ocarOcanId: json["OCAR_OCAN_ID"] ?? 0,
      ocarNumRiga: json["OCAR_NumRiga"]?.toDouble() ?? 0.0,
      ocarMgaaId: json["OCAR_MGAA_ID"] ?? 0,
      ocarQuantita: json["OCAR_Quantita"]?.toDouble() ?? 0.0,
      ocarMbumCodice: json["OCAR_MBUM_Codice"] ?? '',
      ocarPrezzo: json["OCAR_Prezzo"]?.toDouble() ?? 0.0,
      ocarDescrArt: json["OCAR_DescrArt"] ?? '',
      ocarTotSconti: json["OCAR_TotSconti"]?.toDouble() ?? 0.0,
      ocarScontiFinali: json["OCAR_ScontiFinali"]?.toDouble() ?? 0.0,
      ocarPrezzoListino: json["OCAR_PrezzoListino"]?.toDouble(),
      ocarDqta: json["OCAR_DQTA"]?.toDouble() ?? 0.0,
      ocarEForz: json["OCAR_EForz"] ?? 0,
      ocarMbtaCodice: json["OCAR_MBTA_Codice"] ?? 1,
      ocarAppID: json["OCAR_APP_ID"]);

  Map<String, dynamic> toJson() => {
        "OCAR_ID": ocarId,
        "OCAR_OCAN_ID": ocarOcanId,
        "OCAR_NumRiga": ocarNumRiga,
        "OCAR_MGAA_ID": ocarMgaaId,
        "OCAR_Quantita": ocarQuantita,
        "OCAR_MBUM_Codice": ocarMbumCodice,
        "OCAR_Prezzo": ocarPrezzo,
        "OCAR_DescrArt": ocarDescrArt,
        "OCAR_TotSconti": ocarTotSconti,
        "OCAR_ScontiFinali": ocarScontiFinali,
        "OCAR_PrezzoListino": ocarPrezzoListino,
        "OCAR_DQTA": ocarDqta,
        "OCAR_EForz": ocarEForz,
        "OCAR_MBTA_Codice": ocarMbtaCodice,
        "OCAR_APP_ID": ocarAppID
      };
}
