// To parse this JSON data, do
//
//     final soluzionePagamento = soluzionePagamentoFromJson(jsonString);

import 'dart:convert';

SoluzionePagamento soluzionePagamentoFromJson(String str) =>
    SoluzionePagamento.fromJson(json.decode(str));

String soluzionePagamentoToJson(SoluzionePagamento data) =>
    json.encode(data.toJson());

class SoluzionePagamento {
  int mbspId;
  int mbspSoluzione;
  String mbspDescr;
  String mbspCode;

  SoluzionePagamento({
    required this.mbspId,
    required this.mbspSoluzione,
    required this.mbspDescr,
    required this.mbspCode,
  });

  factory SoluzionePagamento.fromJson(Map<String, dynamic> json) =>
      SoluzionePagamento(
        mbspId: json["MBSP_ID"],
        mbspSoluzione: json["MBSP_Soluzione"],
        mbspDescr: json["MBSP_Descr"],
        mbspCode: json["MBSP_Code"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "MBSP_ID": mbspId,
        "MBSP_Soluzione": mbspSoluzione,
        "MBSP_Descr": mbspDescr,
        "MBSP_Code": mbspCode,
      };
}

/*TIPO PAGAMENTO */

TipoPagamento tipoPagamentoFromJson(String str) =>
    TipoPagamento.fromJson(json.decode(str));

String tipoPagamentoToJson(TipoPagamento data) => json.encode(data.toJson());

class TipoPagamento {
  int mbtpId;
  String mbtpPagamento;
  String mbtpDescr;
  int mbtpEffetto;

  TipoPagamento({
    required this.mbtpId,
    required this.mbtpPagamento,
    required this.mbtpDescr,
    required this.mbtpEffetto,
  });

  factory TipoPagamento.fromJson(Map<String, dynamic> json) => TipoPagamento(
        mbtpId: json["MBTP_ID"],
        mbtpPagamento: json["MBTP_Pagamento"],
        mbtpDescr: json["MBTP_Descr"],
        mbtpEffetto: json["MBTP_Effetto"],
      );

  Map<String, dynamic> toJson() => {
        "MBTP_ID": mbtpId,
        "MBTP_Pagamento": mbtpPagamento,
        "MBTP_Descr": mbtpDescr,
        "MBTP_Effetto": mbtpEffetto,
      };
}

/*PAGAMENTO BOLLE */

// To parse this JSON data, do
//
//     final pagamentoBolla = pagamentoBollaFromJson(jsonString);

PagamentoBolla pagamentoBollaFromJson(String str) =>
    PagamentoBolla.fromJson(json.decode(str));

String pagamentoBollaToJson(PagamentoBolla data) => json.encode(data.toJson());

class PagamentoBolla {
  int blpgId;
  int blpgBlanId;
  int blpgMbtpId;
  int blpgMbspId;

  PagamentoBolla({
    required this.blpgId,
    required this.blpgBlanId,
    required this.blpgMbtpId,
    required this.blpgMbspId,
  });

  factory PagamentoBolla.fromJson(Map<String, dynamic> json) => PagamentoBolla(
        blpgId: json["BLPG_ID"] ?? 0,
        blpgBlanId: json["BLPG_BLAN_ID"] ?? 0,
        blpgMbtpId: json["BLPG_MBTP_ID"] ?? 0,
        blpgMbspId: json["BLPG_MBSP_ID"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "BLPG_ID": blpgId,
        "BLPG_BLAN_ID": blpgBlanId,
        "BLPG_MBTP_ID": blpgMbtpId,
        "BLPG_MBSP_ID": blpgMbspId,
      };
}

/*PAGAMENTI ORDINI */
// To parse this JSON data, do
//
//     final pagamentoOrdine = pagamentoOrdineFromJson(jsonString);

PagamentoOrdine pagamentoOrdineFromJson(String str) =>
    PagamentoOrdine.fromJson(json.decode(str));

String pagamentoOrdineToJson(PagamentoOrdine data) =>
    json.encode(data.toJson());

class PagamentoOrdine {
  int ocpgId;
  int ocpgOcanId;
  int ocpgMbtpId;
  int ocpgMbspId;

  PagamentoOrdine({
    required this.ocpgId,
    required this.ocpgOcanId,
    required this.ocpgMbtpId,
    required this.ocpgMbspId,
  });

  factory PagamentoOrdine.fromJson(Map<String, dynamic> json) =>
      PagamentoOrdine(
        ocpgId: json["OCPG_ID"] ?? 0,
        ocpgOcanId: json["OCPG_OCAN_ID"] ?? 0,
        ocpgMbtpId: json["OCPG_MBTP_ID"] ?? 0,
        ocpgMbspId: json["OCPG_MBSP_ID"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "OCPG_ID": ocpgId,
        "OCPG_OCAN_ID": ocpgOcanId,
        "OCPG_MBTP_ID": ocpgMbtpId,
        "OCPG_MBSP_ID": ocpgMbspId,
      };
}

/*PAGAMENTO FATTURE*/

// To parse this JSON data, do
//
//     final pagamentoFattura = pagamentoFatturaFromJson(jsonString);
PagamentoFattura pagamentoFatturaFromJson(String str) =>
    PagamentoFattura.fromJson(json.decode(str));

String pagamentoFatturaToJson(PagamentoFattura data) =>
    json.encode(data.toJson());

class PagamentoFattura {
  int ftpgId;
  int ftpgBlanId;
  int ftpgMbtpId;
  int ftpgMbspId;

  PagamentoFattura({
    required this.ftpgId,
    required this.ftpgBlanId,
    required this.ftpgMbtpId,
    required this.ftpgMbspId,
  });

  factory PagamentoFattura.fromJson(Map<String, dynamic> json) =>
      PagamentoFattura(
        ftpgId: json["FTPG_ID"] ?? 0,
        ftpgBlanId: json["FTPG_FTAN_ID"] ?? 0,
        ftpgMbtpId: json["FTPG_MBTP_ID"] ?? 0,
        ftpgMbspId: json["FTPG_MBSP_ID"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "FTPG_ID": ftpgId,
        "FTPG_FTAN_ID": ftpgBlanId,
        "FTPG_MBTP_ID": ftpgMbtpId,
        "FTPG_MBSP_ID": ftpgMbspId,
      };
}
