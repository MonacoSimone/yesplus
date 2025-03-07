// To parse this JSON data, do
//
//     final partita = partitaFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<Partita> partitaFromJson(String str) =>
    List<Partita>.from(json.decode(str).map((x) => Partita.fromJson(x)));

String partitaToJson(List<Partita> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Partita {
  int capaId;
  int capaCaspStato;
  int capaMbpcId;
  int capaMbdiId;
  int capaMbtdId;
  int capaNumDoc;
  int capaAnnoDoc;
  String capaScadenza;
  String capaDataVal;
  String capaDataDoc;
  String capaRifFat;
  double capaImportoAvere;
  double capaImportoDare;
  double capaResiduo;
  double capaPagamento;
  int capaPagCreate;
  int capaSelected;
  int capaCambio;
  double capaPagCnt;
  double capaPagAss;
  double capaPagTit;
  Rx<Color> colore;
  Partita(
      {required this.capaId,
      required this.capaCaspStato,
      required this.capaMbpcId,
      required this.capaMbdiId,
      required this.capaMbtdId,
      required this.capaNumDoc,
      required this.capaAnnoDoc,
      required this.capaScadenza,
      required this.capaDataVal,
      required this.capaDataDoc,
      required this.capaImportoAvere,
      required this.capaImportoDare,
      required this.capaResiduo,
      required this.capaPagamento,
      required this.capaPagCreate,
      required this.capaSelected,
      required this.capaCambio,
      required this.capaPagCnt,
      required this.capaPagAss,
      required this.capaPagTit,
      required this.capaRifFat,
      required this.colore});

  factory Partita.fromJson(Map<String, dynamic> json) => Partita(
      capaId: json["CAPA_Id"] ?? 0,
      capaCaspStato: json["CAPA_CASP_Stato"] ?? 0,
      capaMbpcId: json["CAPA_MBPC_ID"] ?? 0,
      capaMbdiId: json["CAPA_MBDI_ID"] ?? 0,
      capaMbtdId: json["CAPA_MBTD_ID"] ?? 0,
      capaNumDoc: json["CAPA_NumPart"] ?? 0,
      capaAnnoDoc: json["CAPA_AnnoPart"] ?? 0,
      capaScadenza: json["CAPA_Scadenza"] ?? '',
      capaDataVal: json["CAPA_DataVal"] ?? '',
      capaDataDoc: json["CAPA_DataDoc"] ?? '',
      capaImportoAvere: json["CAPA_ImportoAvere"]?.toDouble() ?? 0.0,
      capaImportoDare: json["CAPA_ImportoDare"]?.toDouble() ?? 0.0,
      capaResiduo: json["CAPA_Residuo"]?.toDouble() ?? 0.0,
      capaPagamento: json["CAPA_Pagamento"]?.toDouble() ?? 0.0,
      capaPagCreate: json["CAPA_PagCreate"] ?? 0,
      capaSelected: json["CAPA_Selected"] ?? 0,
      capaCambio: json["CAPA_Cambio"] ?? 0,
      capaPagCnt: json["CAPA_PagCnt"]?.toDouble() ?? 0.0,
      capaPagAss: json["CAPA_PagAss"]?.toDouble() ?? 0.0,
      capaPagTit: json["CAPA_PagTit"]?.toDouble() ?? 0.0,
      capaRifFat: json["CAPA_RIF_FATT"] ?? '',
      colore: Color.fromARGB(255, 23, 164, 207).obs);

  Map<String, dynamic> toJson() => {
        "CAPA_Id": capaId,
        "CAPA_CASP_Stato": capaCaspStato,
        "CAPA_MBPC_ID": capaMbpcId,
        "CAPA_MBDI_ID": capaMbdiId,
        "CAPA_MBTD_ID": capaMbtdId,
        "CAPA_NumPart": capaNumDoc,
        "CAPA_AnnoPart": capaAnnoDoc,
        "CAPA_Scadenza": capaScadenza,
        "CAPA_DataVal": capaDataVal,
        "CAPA_DataDoc": capaDataDoc,
        "CAPA_ImportoAvere": capaImportoAvere,
        "CAPA_ImportoDare": capaImportoDare,
        "CAPA_Residuo": capaResiduo,
        "CAPA_Pagamento": capaPagamento,
        "CAPA_PagCreate": capaPagCreate,
        "CAPA_Selected": capaSelected,
        "CAPA_Cambio": capaCambio,
        "CAPA_PagCnt": capaPagCnt,
        "CAPA_PagAss": capaPagAss,
        "CAPA_PagTit": capaPagTit,
        "CAPA_RIF_FATT": capaRifFat,
      };
}
