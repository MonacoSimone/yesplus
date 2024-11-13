// To parse this JSON data, do
//
//     final testataFattura = testataFatturaFromJson(jsonString);

import 'dart:convert';

TestataFattura testataFatturaFromJson(String str) =>
    TestataFattura.fromJson(json.decode(str));

String testataFatturaToJson(TestataFattura data) => json.encode(data.toJson());

class TestataFattura {
  int ftanId;
  int ftanAnnoFatt;
  int ftanFttiId;
  int ftanNumFatt;
  String ftanDataIns;
  int ftanMbpcId;
  bool ftanStamp;
  bool ftanScaric;
  bool ftanContab;
  double ftanTotFattura;
  double ftanSpese;
  String ftanDataCreate;

  TestataFattura({
    required this.ftanId,
    required this.ftanAnnoFatt,
    required this.ftanFttiId,
    required this.ftanNumFatt,
    required this.ftanDataIns,
    required this.ftanMbpcId,
    required this.ftanStamp,
    required this.ftanContab,
    required this.ftanScaric,
    required this.ftanTotFattura,
    required this.ftanSpese,
    required this.ftanDataCreate,
  });

  factory TestataFattura.fromJson(Map<String, dynamic> json) => TestataFattura(
        ftanId: json["FTAN_ID"] ?? 0,
        ftanAnnoFatt: json["FTAN_AnnoFatt"] ?? 0,
        ftanFttiId: json["FTAN_FTTI_ID"] ?? 0,
        ftanNumFatt: json["FTAN_NumFatt"] ?? 0,
        ftanDataIns: json["FTAN_DataIns"] == null
            ? DateTime.now().toString()
            : DateTime.parse(json["FTAN_DataIns"]).toString(),
        ftanMbpcId: json["FTAN_MBPC_ID"] ?? 0,
        ftanStamp: json["FTAN_Stamp"] ?? false,
        ftanContab: json["FTAN_Contab"] ?? false,
        ftanScaric: json["FTAN_Scaric"] ?? false,
        ftanTotFattura: json["FTAN_TotFattura"]?.toDouble() ?? 0.0,
        ftanSpese: json["FTAN_Spese"]?.toDouble() ?? 0.0,
        ftanDataCreate: json["FTAN_DataCreate"] == null
            ? DateTime.now().toString()
            : DateTime.parse(json["FTAN_DataCreate"]).toString(),
      );

  Map<String, dynamic> toJson() => {
        "FTAN_ID": ftanId,
        "FTAN_AnnoFatt": ftanAnnoFatt,
        "FTAN_FTTI_ID": ftanFttiId,
        "FTAN_NumFatt": ftanNumFatt,
        "FTAN_DataIns": ftanDataIns,
        "FTAN_MBPC_ID": ftanMbpcId,
        "FTAN_Stamp": ftanStamp,
        "FTAN_TotFattura": ftanTotFattura,
        "FTAN_Spese": ftanSpese,
        "FTAN_DataCreate": ftanDataCreate,
      };
}
