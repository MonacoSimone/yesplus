// To parse this JSON data, do
//
//     final righeFattura = righeFatturaFromJson(jsonString);

import 'dart:convert';

TestataOrdine testataOrdineFromJson(String str) =>
    TestataOrdine.fromJson(json.decode(str));

String testataOrdineToJson(TestataOrdine data) => json.encode(data.toJson());

class TestataOrdine {
  int ocanId;
  int ocanAnnoOrd;
  int ocanOctiId;
  int ocanNumOrd;
  String ocanDataIns;
  int ocanMbpcId;
  String ocanDataConf;
  String ocanDataEvas;
  int ocanStamp;
  int ocanEvaso;
  int ocanParzEvaso;
  int ocanEvasoForz;
  String ocanNoteIniz;
  String ocanNoteFin;
  String ocanDestinat;
  String ocanDestinaZ;
  double ocanTotOrdine;
  int ocanDestMbanId;
  int ocanDeszMbanId;
  int ocanConfermato;
  String ocanDataCreate;
  String? ocanAppId;

  TestataOrdine({
    required this.ocanId,
    required this.ocanAnnoOrd,
    required this.ocanOctiId,
    required this.ocanNumOrd,
    required this.ocanDataIns,
    required this.ocanMbpcId,
    required this.ocanDataConf,
    required this.ocanDataEvas,
    required this.ocanStamp,
    required this.ocanEvaso,
    required this.ocanParzEvaso,
    required this.ocanEvasoForz,
    required this.ocanNoteIniz,
    required this.ocanNoteFin,
    required this.ocanDestinat,
    required this.ocanDestinaZ,
    required this.ocanTotOrdine,
    required this.ocanDestMbanId,
    required this.ocanDeszMbanId,
    required this.ocanConfermato,
    required this.ocanDataCreate,
    required this.ocanAppId,
  });

  factory TestataOrdine.fromJson(Map<String, dynamic> json) => TestataOrdine(
        ocanId: json["OCAN_ID"] ?? 0,
        ocanAnnoOrd: json["OCAN_AnnoOrd"] ?? 0,
        ocanOctiId: json["OCAN_OCTI_ID"] ?? 0,
        ocanNumOrd: json["OCAN_NumOrd"] ?? 0,
        ocanDataIns: json["OCAN_DataIns"] == null
            ? DateTime.now().toString()
            : DateTime.parse(json["OCAN_DataIns"]).toString(),
        ocanMbpcId: json["OCAN_MBPC_ID"] ?? 0,
        ocanDataConf: json["OCAN_DataConf"] == null
            ? DateTime.now().toString()
            : DateTime.parse(json["OCAN_DataConf"]).toString(),
        ocanDataEvas: json["OCAN_DataEvas"] == null
            ? DateTime.now().toString()
            : DateTime.parse(json["OCAN_DataEvas"]).toString(),
        ocanStamp: json["OCAN_Stamp"] ? 1 : 0,
        ocanEvaso: json["OCAN_Evaso"] ? 1 : 0,
        ocanParzEvaso: json["OCAN_ParzEvaso"] ? 1 : 0,
        ocanEvasoForz: json["OCAN_EvasoForz"] ? 1 : 0,
        ocanNoteIniz: json["OCAN_NoteIniz"] ?? '',
        ocanNoteFin: json["OCAN_NoteFin"] ?? '',
        ocanDestinat: json["OCAN_Destinat"] ?? '',
        ocanDestinaZ: json["OCAN_DestinaZ"] ?? '',
        ocanTotOrdine: json["OCAN_TotOrdine"]?.toDouble() ?? 0.0,
        ocanDestMbanId: json["OCAN_Dest_MBAN_ID"] ?? 0,
        ocanDeszMbanId: json["OCAN_Desz_MBAN_ID"] ?? 0,
        ocanConfermato: json["OCAN_Confermato"] ? 1 : 0,
        ocanDataCreate: json["OCAN_DataCreate"] == null
            ? DateTime.now().toString()
            : DateTime.parse(json["OCAN_DataCreate"]).toString(),
        ocanAppId: json["OCAN_APP_ID"],
      );

  Map<String, dynamic> toJson() => {
        "OCAN_ID": ocanId,
        "OCAN_AnnoOrd": ocanAnnoOrd,
        "OCAN_OCTI_ID": ocanOctiId,
        "OCAN_NumOrd": ocanNumOrd,
        "OCAN_DataIns": ocanDataIns,
        "OCAN_MBPC_ID": ocanMbpcId,
        "OCAN_DataConf": ocanDataConf,
        "OCAN_DataEvas": ocanDataEvas,
        "OCAN_Stamp": ocanStamp,
        "OCAN_Evaso": ocanEvaso,
        "OCAN_ParzEvaso": ocanParzEvaso,
        "OCAN_EvasoForz": ocanEvasoForz,
        "OCAN_NoteIniz": ocanNoteIniz,
        "OCAN_NoteFin": ocanNoteFin,
        "OCAN_Destinat": ocanDestinat,
        "OCAN_DestinaZ": ocanDestinaZ,
        "OCAN_TotOrdine": ocanTotOrdine,
        "OCAN_Dest_MBAN_ID": ocanDestMbanId,
        "OCAN_Desz_MBAN_ID": ocanDeszMbanId,
        "OCAN_Confermato": ocanConfermato,
        "OCAN_DataCreate": ocanDataCreate,
        "OCAN_APP_ID": ocanAppId,
      };
}
