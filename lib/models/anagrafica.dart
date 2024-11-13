// To parse this JSON data, do
//
//     final anagrafica = anagraficaFromJson(jsonString);

import 'dart:convert';

import 'package:get/get.dart';

Anagrafica anagraficaFromJson(String str) =>
    Anagrafica.fromJson(json.decode(str));

String anagraficaToJson(Anagrafica data) => json.encode(data.toJson());

class Anagrafica {
  RxList<Cliente> clienti;

  Anagrafica({
    required this.clienti,
  });

  factory Anagrafica.fromJson(Map<String, dynamic> json) => Anagrafica(
        clienti: RxList<Cliente>.from(
            json["Clienti"].map((x) => Cliente.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Clienti": List<dynamic>.from(clienti.map((x) => x.toJson())),
      };
}

class Cliente {
  int mbpcId;
  String mbpcConto;
  String mbpcSottoConto;
  String mbanRagSoc;
  String mbanIndirizzo;
  String mbanComune;
  String mbanTelefono;
  String mbanEmail;
  String mbanEmail2;
  String mbanGpse;
  String mbanGpsn;
  String mbanPartitaIva;
  String mbanCodFiscale;
  double? sconto1;
  double? sconto2;
  double? sconto3;
  int mbanId;
  String mbanDataFineVal;

  Cliente(
      {required this.mbpcId,
      required this.mbpcConto,
      required this.mbpcSottoConto,
      required this.mbanRagSoc,
      required this.mbanIndirizzo,
      required this.mbanComune,
      required this.mbanTelefono,
      required this.mbanEmail,
      required this.mbanEmail2,
      required this.mbanGpse,
      required this.mbanGpsn,
      this.mbanPartitaIva = '',
      this.mbanCodFiscale = '',
      required this.mbanId,
      required this.mbanDataFineVal,
      required this.sconto1,
      required this.sconto2,
      required this.sconto3});

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
      mbpcId: json["MBPC_ID"] ?? 0,
      mbpcConto: json["MBPC_Conto"] ?? '',
      mbpcSottoConto: json["MBPC_SottoConto"] ?? '',
      mbanRagSoc: json["MBAN_RagSoc"] ?? '',
      mbanComune: json["MBAN_Comune"] ?? '',
      mbanIndirizzo: json["MBAN_Indirizzo"] ?? '',
      mbanTelefono: json["MBAN_Telefono"] ?? '',
      mbanEmail: json["MBAN_Email"] ?? '',
      mbanEmail2: json["MBAN_EMail2"] ?? '',
      mbanGpse: json["MBAN_GPSE"] ?? '',
      mbanGpsn: json["MBAN_GPSN"] ?? '',
      mbanPartitaIva: json["MBAN_PartitaIva"] ?? '',
      mbanCodFiscale: json["MBAN_CodFiscale"] ?? '',
      mbanId: json["MBAN_ID"] ?? 0,
      mbanDataFineVal: json["MBAN_DataFineVal"] ?? '',
      sconto1: json["MBAN_Sconto1"]?.toDouble(),
      sconto2: json["MBAN_Sconto2"]?.toDouble(),
      sconto3: json["MBAN_Sconto3"]?.toDouble());

  Map<String, dynamic> toJson() => {
        "MBPC_ID": mbpcId,
        "MBPC_Conto": mbpcConto,
        "MBPC_SottoConto": mbpcSottoConto,
        "MBAN_RagSoc": mbanRagSoc,
        "MBAN_Comune": mbanComune,
        "MBAN_Indirizzo": mbanIndirizzo,
        "MBAN_Telefono": mbanTelefono,
        "MBAN_Email": mbanEmail,
        "MBAN_Email2": mbanEmail2,
        "MBAN_GPSE": mbanGpse,
        "MBAN_GPSN": mbanGpsn,
        "MBAN_PartitaIva": mbanPartitaIva,
        "MBAN_CodFiscale": mbanCodFiscale,
        "MBAN_ID": mbanId,
        "MBAN_DataFineVal": mbanDataFineVal,
        "MBAN_Sconto1": sconto1,
        "MBAN_Sconto2": sconto2,
        "MBAN_Sconto3": sconto3
      };
}
/* class Cliente {
  int mbpcId;
  int mbanId;
  String mbanRagSoc;
  String mbanIndirizzo;
  String mbanCap;
  String mbanComune;
  String mbanCodFiscale;
  String mbanPartitaIva;

  Cliente({
    required this.mbpcId,
    required this.mbanId,
    required this.mbanRagSoc,
    required this.mbanIndirizzo,
    required this.mbanCap,
    required this.mbanComune,
    required this.mbanCodFiscale,
    required this.mbanPartitaIva,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        mbpcId: json["MBPC_ID"],
        mbanId: json["MBAN_ID"],
        mbanRagSoc: json["MBAN_RagSoc"] ?? '',
        mbanIndirizzo: json["MBAN_Indirizzo"] ?? '',
        mbanCap: json["MBAN_Cap"] ?? '',
        mbanComune: json["MBAN_Comune"] ?? '',
        mbanCodFiscale: json["MBAN_CodFiscale"] ?? '',
        mbanPartitaIva: json["MBAN_PartitaIva"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "MBPC_ID": mbpcId,
        "MBAN_ID": mbanId,
        "MBAN_RagSoc": mbanRagSoc,
        "MBAN_Indirizzo": mbanIndirizzo,
        "MBAN_Cap": mbanCap,
        "MBAN_Comune": mbanComune,
        "MBAN_CodFiscale": mbanCodFiscale,
        "MBAN_PartitaIva": mbanPartitaIva,
      };
}
 */