import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import '../controllers/controller_soket.dart';
import '../database/db_helper.dart';
import '../models/messaggio.dart';
import '../models/partita.dart';
import 'package:intl/intl.dart';

//TODO: ELIMINARE LE RIGHE CHE VENGONO MESSE A 0.
class IncassiController extends GetxController {
  RxDouble totale_residuo = 0.0.obs;

  final contantiController = TextEditingController();
  final assegniController = TextEditingController();
  final titoliController = TextEditingController();
  RxString contanti = '0'.obs;
  RxString assegni = '0'.obs;
  RxString titoli = '0'.obs;
  RxDouble saldo = 0.0.obs;
  List<Partita> scadenziario = <Partita>[].obs;
  List<Partita> scadenziarioOriginale = <Partita>[].obs;
  List<Partita> partiteSelezionate = <Partita>[];
  String formato = 'yyyy-MM-dd HH:mm:ss';
  double importoselezionatodapagare = 0.0;
  RxSet<int> selectedRows = <int>{}.obs;

  Color coloreNormale = const Color.fromARGB(255, 23, 164, 207);
  Color coloreSelezionato = const Color.fromARGB(255, 244, 67, 54);
  Rx<Color> colore = const Color.fromARGB(255, 23, 164, 207).obs;

  List<DataColumn> header = const [
    DataColumn(
      label: Expanded(
        child: Text(
          'Documento.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: Text(
          'Data Doc.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: Text(
          'Scadenza',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: Text(
          'Dare',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: Text(
          'Avere',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: Text(
          'Residuo',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
  ];

  void toggleRowSelection(int index, bool isSelected) {
    if (isSelected) {
      selectedRows.add(index);
    } else {
      selectedRows.remove(index);
    }
    update();
  }

  /* Future<int> paga(int MBPC_ID, WebSocketController wc) async {
    String imei = await DatabaseHelper().getIMEI();
    int? pfanAppId;

    int MBAG_ID = await DatabaseHelper().getMBAGID();
    double contanti = double.parse(this.contanti.value);
    double assegni = double.parse(this.assegni.value);
    double titoli = double.parse(this.titoli.value);
    double importo = 0.0;
    List<Map<String, dynamic>> list = [];
    Map<String, dynamic> head = {};

    if (contanti > 0) {
      pfanAppId = (await DatabaseHelper().getPFANAppId())!;
      importo = 0.0;
      head = {
        "QUERY": "INSERT",
        "TABLE": "PF_Anag",
        "DATA": {
          "PFAN_MBSC_ID": "@MBDV_MBSC_ID",
          "PFAN_MBDV_ID": "@MBDV_ID",
          "PFAN_MBTP_ID":
              23, //TODO AGGIUNGERE TABELLA PER TIPO PAGAMENTO DA SCEGLIERE NEI PARAMETRI
          "PFAN_DataEmiss": '@DATAEMISS',
          "PFAN_AnnoPag": '@ANNOPAG',
          "PFAN_NumPag": "@NUMPAG",
          "PFAN_MBPC_ID": 8951,
          "PFAN_NoteIniziali": "@CONTANTI",
          "PFAN_MBAG_Id": MBAG_ID,
          "PFAN_APP_ID": "$imei-$pfanAppId"
        }
      };
      list.add(head);

      for (Partita riga in partiteSelezionate) {
        int? pfarAppId = (await DatabaseHelper().getPFARAppId())!;
        if (riga.capaResiduo >= contanti) {
          importo = contanti;
          riga.capaResiduo = riga.capaResiduo - contanti;
        } else {
          importo = riga.capaResiduo;
          contanti = contanti - importo;
          riga.capaResiduo = 0;
        }

        DateFormat dateFormat = DateFormat(formato);
        DateTime dataVal = DateTime.parse(riga.capaDataVal);
        String capaDataVal = dateFormat.format(dataVal);
        DateTime dataScad = DateTime.parse(riga.capaScadenza);
        String capaScadenza = dateFormat.format(dataScad);
        DateTime dataDoc = DateTime.parse(riga.capaDataDoc);
        String capaDataDoc = dateFormat.format(dataDoc);

        list.add({
          "QUERY": "INSERT",
          "TABLE": "PF_Dett",
          "DATA": {
            "PFDT_PFAN_ID": "@PFAN_ID",
            "PFDT_MBPC_ID": MBPC_ID,
            "PFDT_CAPA_ID": riga.capaId,
            "PFDT_Creditore": "",
            "PFDT_Piazza": "",
            "PFDT_MBTP_ID": 23,
            "PFDT_MBDI_ID": riga.capaMbdiId,
            "PFDT_Cambio": riga.capaCambio,
            "PFDT_DataVal": riga.capaDataVal.substring(0, capaDataVal.length),
            "PFDT_ImportoValuta": riga.capaCambio * importo,
            "PFDT_ImportoDare": riga.capaImportoDare > 0.0 ? 0.0 : importo,
            "PFDT_ImportoAvere": riga.capaImportoAvere == 0.0 ? importo : 0.0,
            "PFDT_Scadenza":
                riga.capaScadenza.substring(0, capaScadenza.length),
            "PFDT_DataDoc": riga.capaDataDoc.substring(0, capaDataDoc.length),
            "PFDT_NumDoc": riga.capaNumDoc,
            "PFDT_MBTD_ID": riga.capaMbtdId,
            "PFDT_APP_ID": "$imei-$pfarAppId"
          }
        });
        try {
          await DatabaseHelper().updateDbIdRighePagam(pfarAppId);
        } catch (e) {
          debugPrint(jsonEncode(e));
        }
      }
      try {
        await DatabaseHelper().updateDbIdTestatePagam(pfanAppId);
      } catch (e) {
        debugPrint(jsonEncode(e));
      }
    }

    if (assegni > 0) {
      pfanAppId = (await DatabaseHelper().getPFANAppId())!;
      importo = 0.0;
      Map<String, dynamic> head = {
        "QUERY": "INSERT",
        "TABLE": "PF_Anag",
        "DATA": {
          "PFAN_MBSC_ID": "@MBDV_MBSC_ID",
          "PFAN_MBDV_ID": "@MBDV_ID",
          "PFAN_MBTP_ID": "23",
          "PFAN_DataEmiss": '@DATAEMISS',
          "PFAN_AnnoPag": '@ANNOPAG',
          "PFAN_NumPag": "@NUMPAG",
          "PFAN_MBPC_ID": 8951,
          "PFAN_NoteIniziali": "@ASSEGNI",
          "PFAN_MBAG_Id": MBAG_ID,
          "PFAN_APP_ID": "$imei-$pfanAppId"
        }
      };
      list.add(head);

      for (Partita riga in partiteSelezionate) {
        int? pfarAppId = (await DatabaseHelper().getPFARAppId())!;
        if (riga.capaResiduo >= assegni) {
          importo = assegni;
          riga.capaResiduo = riga.capaResiduo - importo;
        } else {
          importo = riga.capaResiduo;
          assegni = assegni - importo;
          riga.capaResiduo = 0.0;
        }

        DateFormat dateFormat = DateFormat(formato);
        DateTime dataVal = DateTime.parse(riga.capaDataVal);
        String capaDataVal = dateFormat.format(dataVal);
        DateTime dataScad = DateTime.parse(riga.capaScadenza);
        String capaScadenza = dateFormat.format(dataScad);
        DateTime dataDoc = DateTime.parse(riga.capaDataDoc);
        String capaDataDoc = dateFormat.format(dataDoc);

        list.add({
          "QUERY": "INSERT",
          "TABLE": "PF_Dett",
          "DATA": {
            "PFDT_PFAN_ID": "@PFAN_ID",
            "PFDT_MBPC_ID": MBPC_ID,
            "PFDT_CAPA_ID": riga.capaId,
            "PFDT_Creditore": "",
            "PFDT_Piazza": "",
            "PFDT_MBTP_ID": "23",
            "PFDT_MBDI_ID": riga.capaMbdiId,
            "PFDT_Cambio": riga.capaCambio,
            "PFDT_DataVal": riga.capaDataVal.substring(0, capaDataVal.length),
            "PFDT_ImportoValuta": riga.capaCambio * importo,
            "PFDT_ImportoDare": riga.capaImportoDare > 0.0 ? 0.0 : importo,
            "PFDT_ImportoAvere": riga.capaImportoAvere == 0.0 ? importo : 0.0,
            "PFDT_Scadenza":
                riga.capaScadenza.substring(0, capaScadenza.length),
            "PFDT_DataDoc": riga.capaDataDoc.substring(0, capaDataDoc.length),
            "PFDT_NumDoc": riga.capaNumDoc,
            "PFDT_MBTD_ID": riga.capaMbtdId,
            "PFDT_APP_ID": "$imei-$pfarAppId"
          }
        });
        try {
          await DatabaseHelper().updateDbIdRighePagam(pfarAppId);
        } catch (e) {
          debugPrint(jsonEncode(e));
        }
      }
      try {
        await DatabaseHelper().updateDbIdTestatePagam(pfanAppId);
      } catch (e) {
        debugPrint(jsonEncode(e));
      }
    }

    if (titoli > 0) {
      pfanAppId = (await DatabaseHelper().getPFANAppId())!;
      importo = 0.0;
      Map<String, dynamic> head = {
        "QUERY": "INSERT",
        "TABLE": "PF_Anag",
        "DATA": {
          "PFAN_MBSC_ID": "@MBDV_MBSC_ID",
          "PFAN_MBDV_ID": "@MBDV_ID",
          "PFAN_MBTP_ID": "23",
          "PFAN_DataEmiss": '@DATAEMISS',
          "PFAN_AnnoPag": '@ANNOPAG',
          "PFAN_NumPag": "@NUMPAG",
          "PFAN_MBPC_ID": 8951,
          "PFAN_NoteIniziali": "@TITOLI",
          "PFAN_MBAG_Id": MBAG_ID,
          "PFAN_APP_ID": "$imei-$pfanAppId"
        }
      };
      list.add(head);

      for (Partita riga in partiteSelezionate) {
        int? pfarAppId = (await DatabaseHelper().getPFARAppId())!;
        if (riga.capaResiduo >= titoli) {
          importo = titoli;
          riga.capaResiduo = riga.capaResiduo - titoli;
        } else {
          importo = riga.capaResiduo;
          titoli = titoli - importo;
          riga.capaResiduo = 0.0;
        }

        DateFormat dateFormat = DateFormat(formato);
        DateTime dataVal = DateTime.parse(riga.capaDataVal);
        String capaDataVal = dateFormat.format(dataVal);
        DateTime dataScad = DateTime.parse(riga.capaScadenza);
        String capaScadenza = dateFormat.format(dataScad);
        DateTime dataDoc = DateTime.parse(riga.capaDataDoc);
        String capaDataDoc = dateFormat.format(dataDoc);

        list.add({
          "QUERY": "INSERT",
          "TABLE": "PF_Dett",
          "DATA": {
            "PFDT_PFAN_ID": "@PFAN_ID",
            "PFDT_MBPC_ID": MBPC_ID,
            "PFDT_CAPA_ID": riga.capaId,
            "PFDT_Creditore": "",
            "PFDT_Piazza": "",
            "PFDT_MBTP_ID": "23",
            "PFDT_MBDI_ID": riga.capaMbdiId,
            "PFDT_Cambio": riga.capaCambio,
            "PFDT_DataVal": riga.capaDataVal.substring(0, capaDataVal.length),
            "PFDT_ImportoValuta": riga.capaCambio * importo,
            "PFDT_ImportoDare": riga.capaImportoDare > 0.0 ? 0.0 : importo,
            "PFDT_ImportoAvere": riga.capaImportoAvere == 0.0 ? importo : 0.0,
            "PFDT_Scadenza":
                riga.capaScadenza.substring(0, capaScadenza.length),
            "PFDT_DataDoc": riga.capaDataDoc.substring(0, capaDataDoc.length),
            "PFDT_NumDoc": riga.capaNumDoc,
            "PFDT_MBTD_ID": riga.capaMbtdId,
            "PFDT_APP_ID": "$imei-$pfarAppId"
          }
        });
        try {
          await DatabaseHelper().updateDbIdRighePagam(pfarAppId);
        } catch (e) {
          debugPrint(jsonEncode(e));
        }
      }
      try {
        await DatabaseHelper().updateDbIdTestatePagam(pfanAppId);
      } catch (e) {
        debugPrint(jsonEncode(e));
      }
    }

    try {
      int PFAN_ID = 0;

      for (var ele in list) {
        if (ele['TABLE'] == 'PF_Anag') {
          PFAN_ID = await wc.sendMessage(
              Messaggio(metsMessage: jsonEncode(ele), metsDataSave: 'diretto'));
          if (PFAN_ID == -1) {
            PFAN_ID = pfanAppId!;
          }
        } else {
          ele["DATA"]["PFDT_PFAN_ID"] = PFAN_ID;
          if (ele["DATA"]["PFDT_ImportoAvere"] != 0) {
            await wc.sendMessage(Messaggio(
                metsMessage: jsonEncode(ele), metsDataSave: 'diretto'));
          }
        }
      }

      return 1;
    } catch (e) {
      return -1;
    }

    //inviaMessaggi(list);
  } */
  // Sostituisci l'intero metodo paga con questa nuova versione atomica.

  // Sostituisci il metodo paga con questa versione finale

  Future<int> paga(int mbpcId, WebSocketController wc) async {
    String imei = await DatabaseHelper().getIMEI();
    int mbagId = await DatabaseHelper().getMBAGID();

    // --- 1. PREPARA I DATI (invariato) ---
    List<Map<String, dynamic>> payments = [];
    double contanti = double.tryParse(contantiController.text) ?? 0.0;
    double assegni = double.tryParse(assegniController.text) ?? 0.0;
    double titoli = double.tryParse(titoliController.text) ?? 0.0;

    if (contanti > 0) payments.add({"type": "CONTANTI", "amount": contanti});
    if (assegni > 0) payments.add({"type": "ASSEGNI", "amount": assegni});
    if (titoli > 0) payments.add({"type": "TITOLI", "amount": titoli});

    if (payments.isEmpty) {
      Get.snackbar('Attenzione', 'Nessun importo di pagamento inserito.');
      return 0;
    }

    List<int> selectedInvoiceIds = selectedRows.toList();
    if (selectedInvoiceIds.isEmpty) {
      Get.snackbar('Attenzione', 'Nessuna partita selezionata da pagare.');
      return 0;
    }

    // --- 2. COSTRUISCI IL MESSAGGIO ATOMICO (invariato) ---
    Map<String, dynamic> fullPaymentMessage = {
      "QUERY": "INSERT_FULL_PAYMENT",
      "DATA": {
        "mbpcId": mbpcId,
        "mbagId": mbagId,
        "imei": imei,
        "payments": payments,
        "invoiceIds": selectedInvoiceIds,
      }
    };

    // --- 3. INVIA IL MESSAGGIO E GESTISCI LA RISPOSTA ---
    try {
  // `sendMessage` invia il messaggio e lo mette in coda se offline.
  await wc.sendMessage(Messaggio(
    metsMessage: jsonEncode(fullPaymentMessage),
    metsDataSave: 'diretto',
  ));

  // Azioni da eseguire SEMPRE dopo aver catturato l'intento dell'utente.
  resetFiltroIncassi();
  
  // NON mostriamo nessuna snackbar qui. Lasciamo che sia il listener
  // a notificare l'utente quando l'operazione sarà davvero completata.
  
  // NON ricarichiamo la lista. Si aggiornerà quando il listener riceverà la conferma.
  // filtraIncassi(mbpcId);

  return 1;
} catch (e) {
  debugPrint('Errore durante l\'invio del pagamento: ${e.toString()}');
  // L'unica snackbar che mostriamo da qui è in caso di errore grave.
  Get.snackbar('Errore', 'Impossibile inviare o salvare il pagamento.');
  return -1;
}
  }

  filtraIncassi(int mbpc_id) async {
    scadenziario.clear();
    totale_residuo.value = 0.0;

    scadenziario = await DatabaseHelper().getPartite(mbpc_id);
    for (var scadenza in scadenziario) {
      if (scadenza.capaImportoAvere == 0.0) {
        totale_residuo.value += scadenza.capaResiduo;
      } else {
        totale_residuo.value -= scadenza.capaResiduo;
      }
    }
  }

  resetFiltroIncassi() {
    scadenziario.clear();
    resetSelection();
    contantiController.text = '';
    assegniController.text = '';
    titoliController.text = '';
    /* for (var scadenza in scadenziarioOriginale) {
      scadenziario.add(scadenza);
    } */
  }

  String getScadenza(index) {
    String dateTime = scadenziario[index].capaScadenza.replaceAll(' ', 'T');
    String s1 = dateTime.split('T')[0].toString();
    List<String> s2 = s1.split('-');

    return '${s2[2]}-${s2[1]}-${s2[0]}';
  }

  void resetSelection() {
    partiteSelezionate.clear();
    selectedRows.clear();
    update(); // Aggiorna lo stato dell'interfaccia utente per riflettere i cambiamenti
  }

  int countSelectedRows() {
    partiteSelezionate = scadenziario
        .where((scadenziario) => selectedRows.contains(scadenziario.capaId))
        .toList();
    return partiteSelezionate
        .length; // Restituisce il numero totale di elementi selezionati
  }

  double sommaImportoPartiteSelezionate() {
    double importo = 0;
    for (Partita item in partiteSelezionate) {
      importo += item.capaResiduo;
    }
    debugPrint('sommaImportoPartiteSelezionate $importo');
    return importo;
  }

  double getValorePagamentoTotale() {
    debugPrint(this.contanti.value);
    debugPrint(this.contanti.value.runtimeType.toString());
    if (this.contanti.value.isEmpty) {
      this.contanti.value = '0';
    }
    if (this.assegni.value.isEmpty) {
      this.assegni.value = "0";
    }
    if (this.titoli.value.isEmpty) {
      this.titoli.value = "0";
    }
    double contanti = double.parse(this.contanti.value);
    double assegni = double.parse(this.assegni.value);
    double titoli = double.parse(this.titoli.value);
    debugPrint('getValorePagamentoTotale: ${contanti + assegni + titoli} ');
    return contanti + assegni + titoli;
  }
}
