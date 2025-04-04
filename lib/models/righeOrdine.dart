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
  List<ScontoRiga> sconti; // Aggiungi questa lista

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
      required this.ocarAppID,
      required this.sconti});

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
        ocarAppID: json["OCAR_APP_ID"],
        sconti: (json["Sconti"] as List<dynamic>?)
                ?.map((scontoJson) => ScontoRiga.fromJson(scontoJson))
                .toList() ??
            [],
      );

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

class ScontoRiga {
  int ocPrior;
  int ocscMbstId;
  double ocscPercVal;
  double ocscBaseAppl;
  double ocscValore;
  int ocscFinale;
  int ocscTipo;
  double ocscFactor;
  int ocscForCfg;

  ScontoRiga({
    required this.ocPrior,
    required this.ocscMbstId,
    required this.ocscPercVal,
    required this.ocscBaseAppl,
    required this.ocscValore,
    required this.ocscFinale,
    required this.ocscTipo,
    required this.ocscFactor,
    required this.ocscForCfg,
  });

  Map<String, dynamic> toJson(int ocarId) {
    return {
      "OCSC_OCAR_ID": ocarId,
      "OCSC_Prior": ocPrior,
      "OCSC_MBST_ID": ocscMbstId,
      "OCSC_percVal": ocscPercVal,
      "OCSC_BaseAppl": ocscBaseAppl,
      "OCSC_Valore": ocscValore,
      "OCSC_Finale": ocscFinale,
      "OCSC_Tipo": ocscTipo,
      "OCSC_Factor": ocscFactor,
      "OCSC_ForCfg": ocscForCfg,
    };
  }

  factory ScontoRiga.fromJson(Map<String, dynamic> json) => ScontoRiga(
        ocPrior: json["OCSC_Prior"] ?? 0,
        ocscMbstId: json["OCSC_MBST_ID"] ?? 0,
        ocscPercVal: (json["OCSC_percVal"] as num?)?.toDouble() ?? 0.0,
        ocscBaseAppl: (json["OCSC_BaseAppl"] as num?)?.toDouble() ?? 0.0,
        ocscValore: (json["OCSC_Valore"] as num?)?.toDouble() ?? 0.0,
        ocscFinale: json["OCSC_Finale"] ?? 0,
        ocscTipo: json["OCSC_Tipo"] ?? 0,
        ocscFactor: (json["OCSC_Factor"] as num?)?.toDouble() ?? 1.0,
        ocscForCfg: json["OCSC_ForCfg"] ?? 0,
      );
}
