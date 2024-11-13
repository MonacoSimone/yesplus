// To parse this JSON data, do
//
//     final carrello = carrelloFromJson(jsonString);

import 'dart:convert';
import 'dart:ffi';

import 'package:get/get.dart';

Carrello carrelloFromJson(String str) => Carrello.fromJson(json.decode(str));

String carrelloToJson(Carrello data) => json.encode(data.toJson());

class Carrello {
  RxDouble totale;
  RxDouble subtotale;
  RxDouble tasse;
  int sconti;
  List<ProdottoCarrello> prodotto;

  Carrello({
    required this.totale,
    required this.subtotale,
    required this.tasse,
    this.sconti = 0,
    required this.prodotto,
  });

  factory Carrello.fromJson(Map<String, dynamic> json) => Carrello(
        totale: json["totale"],
        subtotale: json["subtotale"],
        tasse: json["tasse"],
        sconti: json["sconti"],
        prodotto: List<ProdottoCarrello>.from(
            json["prodotti"].map((x) => ProdottoCarrello.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totale": totale,
        "subtotale": subtotale,
        "tasse": tasse,
        "sconti": sconti,
        "prodotti": List<dynamic>.from(prodotto.map((x) => x.toJson())),
      };
}

class ProdottoCarrello {
  int idProdotto;
  String nomeProdotto;
  RxDouble quantita;
  double? prezzoListino;
  double prezzo;
  RxDouble totale;
  double sconti;
  int iva;
  int idIva;
  String UM;

  ProdottoCarrello(
      {required this.idProdotto,
      required this.nomeProdotto,
      required this.quantita,
      required this.prezzo,
      required this.totale,
      required this.iva,
      required this.idIva,
      required this.sconti,
      required this.prezzoListino,
      required this.UM});

  factory ProdottoCarrello.fromJson(Map<String, dynamic> json) =>
      ProdottoCarrello(
        idProdotto: json["idProdotto"],
        nomeProdotto: json["nomeProdotto"],
        quantita: json["quantita"],
        prezzo: json["prezzo"],
        totale: json["totale"],
        iva: json["iva"],
        idIva: json["idIva"],
        sconti: json["sconti"],
        prezzoListino: json["prezzoListino"]?.toDouble(),
        UM: json["UM"],
      );

  Map<String, dynamic> toJson() => {
        "idProdotto": idProdotto,
        "nomeProdotto": nomeProdotto,
        "quantita": quantita,
        "prezzo": prezzo,
        "sconti": sconti,
        "iva": iva,
        "idIva": idIva,
        "prezzoListino": prezzoListino,
        "UM": UM,
      };
}
