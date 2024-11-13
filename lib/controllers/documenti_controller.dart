import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../models/documento.dart';

class DocumentiController extends GetxController {
  List<String> tipi = ['', 'Ordine', 'Fattura', 'Bolla'];
  RxString tipoSelezionato = ''.obs;
  TextEditingController anno = TextEditingController(text: 'Anno');
  TextEditingController numeroDoc = TextEditingController(text: 'Num. Doc.');
  FocusNode numeroDocNode = FocusNode();
  Rx<DateTime?> picked = Rx<DateTime?>(DateTime.now());
  RxInt idDocSel = RxInt(-1);
  RxInt fattAnno1 = 0.obs;
  RxInt ordAnno1 = 0.obs;
  RxInt boll1Anno1 = 0.obs;
  RxInt boll2Anno1 = 0.obs;
  RxInt fattAnno2 = 0.obs;
  RxInt ordAnno2 = 0.obs;
  RxInt boll1Anno2 = 0.obs;
  RxInt boll2Anno2 = 0.obs;
  RxString tipoBollaDescr1 = ''.obs;
  RxString tipoBollaDescr2 = ''.obs;
  RxList<DocumentoShort> documenti = <DocumentoShort>[].obs;
  List<DataColumn> header = const [
    DataColumn(
      label: Expanded(
        child: Text(
          'Tipo Doc.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: Text(
          'Numero',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: Text(
          'Data',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: Text(
          'Cliente',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: Text(
          'Stato',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // Qui puoi inizializzare i tuoi dati o impostare listener
    // Ad esempio, potresti voler chiamare un API per ottenere dati quando il controller viene inizializzato

    // Impostiamo un semplice listener sul contatore

    numeroDocNode.addListener(() {
      // Controlla se il TextField ha ottenuto il focus
      if (numeroDocNode.hasFocus) {
        // Se sì, cancella il testo
        if (numeroDoc.text == 'Num. Doc.') {
          numeroDoc.clear();
        }
      } else {
        if (numeroDoc.text.isEmpty) {
          numeroDoc.text = 'Num. Doc.';
        }
      }
    });
  }

  cambiaTipo(String? tipo) {
    if (tipo != null) {
      tipoSelezionato.value = tipo;
    }
  }

  Future<void> getNumDocumenti(int mbpcid) async {
    int tipoFattura = await DatabaseHelper().getTipoFattura();
    int tipoOrdine = await DatabaseHelper().getTipoOrdine();
    int tipoBolla1 = await DatabaseHelper().getTipoBolla1();
    int tipoBolla2 = await DatabaseHelper().getTipoBolla2();

    tipoBollaDescr1.value =
        await DatabaseHelper().getTipoBollaDescr(tipoBolla1);
    tipoBollaDescr2.value =
        await DatabaseHelper().getTipoBollaDescr(tipoBolla2);

    fattAnno1.value = await DatabaseHelper()
        .getNumFatture(tipoFattura, DateTime.now().year, mbpcid);
    fattAnno2.value = await DatabaseHelper()
        .getNumFatture(tipoFattura, DateTime.now().year - 1, mbpcid);

    ordAnno1.value = await DatabaseHelper()
        .getNumOrdini(tipoOrdine, DateTime.now().year, mbpcid);
    ordAnno2.value = await DatabaseHelper()
        .getNumOrdini(tipoOrdine, DateTime.now().year - 1, mbpcid);

    boll1Anno1.value = await DatabaseHelper()
        .getNumBolla(tipoBolla1, DateTime.now().year, mbpcid);
    boll1Anno2.value = await DatabaseHelper()
        .getNumBolla(tipoBolla1, DateTime.now().year - 1, mbpcid);

    boll2Anno1.value = await DatabaseHelper()
        .getNumBolla(tipoBolla2, DateTime.now().year, mbpcid);
    boll2Anno2.value = await DatabaseHelper()
        .getNumBolla(tipoBolla2, DateTime.now().year - 1, mbpcid);
  }

  void resetDocumenti() {
    documenti.clear();
    update();
  }

  Future<void> getDocumenti(int mbpcId) async {
    List<Map<String, dynamic>> map = await DatabaseHelper().getDocumenti(
        tipoSelezionato.value, numeroDoc.text, picked.value.toString(), mbpcId);
    documenti.clear();
    for (var doc in map) {
      debugPrint(jsonEncode(doc));
      String cli = await DatabaseHelper().getCliente(doc["ID_CLIENTE"]);
      debugPrint(cli);

      documenti.add(DocumentoShort(
          id: doc["ID_DOC"],
          tipo: doc["TIPO_DOC"],
          numero: doc["NUM_DOC"].toString(),
          data: DateTime.parse(doc["DATA_DOC"]),
          cliente: cli,
          stato: doc["STATO_DOC"] ?? '',
          prefisso: doc["PREF_DOC"]));
    }

    update();
  }
}
