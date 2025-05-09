import 'dart:convert';
import 'dart:collection';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/messaggio.dart';
import '../models/pagamenti.dart';
import '../controllers/controller_soket.dart';
import '../models/anagrafica.dart';
import '../models/carrello.dart' as cart;
import '../models/catalogo.dart' as cata;
import '../database/db_helper.dart';
import '../models/righeOrdine.dart';
import '../models/testataordine.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OrdineController extends GetxController {
  RxDouble totale = 0.00.obs;
  RxDouble subTotale = 0.00.obs;
  RxDouble tasse = 0.0.obs;
  RxDouble sconto = 0.0.obs;
  RxDouble qtaProdotto = 1.0.obs;
  RxBool omaggio = false.obs;
  RxBool acquistati = false.obs;
  RxBool isKeyboardOpen = false.obs;
  RxDouble dialogHeight = 500.0.obs;
  RxDouble dialogHeightBack = 0.0.obs;
  TextEditingController textQta = TextEditingController(text: '1.0');
  TextEditingController textDescr =
      TextEditingController(text: 'Descrizione Prodotto');
  FocusNode textDescrNode = FocusNode();

  TextEditingController textSc1 = TextEditingController(text: 'Sconto 1');
  FocusNode textSc1Node = FocusNode();
  TextEditingController textSc2 = TextEditingController(text: 'Sconto 2');
  FocusNode textSc2Node = FocusNode();
  TextEditingController textSc3 = TextEditingController(text: 'Sconto 3');
  FocusNode textSc3Node = FocusNode();
  TextEditingController noteController = TextEditingController();

  //Carrello cart = Carrello(prodotti: <Prodotti>[].obs).obs;
  RxList<cart.ProdottoCarrello> prodottiCarrello =
      <cart.ProdottoCarrello>[].obs;
  List<String> classi = <String>[];
  RxList<cata.Prodotto> prodotti = <cata.Prodotto>[].obs;
  RxList<cata.Prodotto> prodottiOri = <cata.Prodotto>[].obs;
  RxString selectedItem = ''.obs;
  List<RigaOrdine> righeOrdine = <RigaOrdine>[].obs;

  RxList<DataRow> righeStorico = <DataRow>[].obs;
  RxString serverApi = ''.obs;
  RxString disponibilita = ''.obs;
  RxString selectedValue = ''.obs;
  RxList<String> destinatari = <String>[].obs;

  Future<void> loadDestinatari(int mbanid) async {
    debugPrint('carico destinatari');
    // destinatari = <String>[].obs;
    // selectedValue = ''.obs;
    final data = await DatabaseHelper().getDestinatariByMBANId(mbanid);
    print(mbanid);
    destinatari.value = data;
    if (destinatari.isNotEmpty) {
      selectedValue.value =
          destinatari.first; // Imposta il primo valore come predefinito
    }
  }

  Future<void> resetDestinatari() async {
    destinatari.clear();
    selectedValue.value = '';
  }

  void resetOrdine() {
    totale = 0.00.obs;
    subTotale = 0.00.obs;
    tasse = 0.0.obs;
    sconto = 0.0.obs;
    prodottiCarrello.clear();
    righeOrdine.clear();
    righeStorico.clear();
    omaggio = false.obs;
    acquistati = false.obs;
    selectedValue = ''.obs;
  }

  Future<void> getServerApi() async {
    serverApi.value = await DatabaseHelper().getServerAPI();
  }

  @override
  void onInit() {
    super.onInit();

    getServerApi();
    // Impostiamo un semplice listener sul contatore
    textSc1Node.addListener(() {
      if (textSc1Node.hasFocus) {
        dialogHeightBack.value = dialogHeight.value;
        dialogHeight.value = 380;
        if (textSc1.text == 'Sconto 1') {
          textSc1.clear();
        }
      } else {
        dialogHeight.value = dialogHeightBack.value;
        if (textSc1.text.isEmpty) {
          textSc1.text = 'Sconto 1';
        }
      }
    });

    textSc2Node.addListener(() {
      if (textSc2Node.hasFocus) {
        dialogHeightBack.value = dialogHeight.value;
        dialogHeight.value = 380;
        if (textSc2.text == 'Sconto 2') {
          textSc2.clear();
        }
      } else {
        dialogHeight.value = dialogHeightBack.value;
        if (textSc2.text.isEmpty) {
          textSc2.text = 'Sconto 2';
        }
      }
    });

    textSc3Node.addListener(() {
      if (textSc3Node.hasFocus) {
        dialogHeightBack.value = dialogHeight.value;
        dialogHeight.value = 380;
        if (textSc3.text == 'Sconto 3') {
          textSc3.clear();
        }
      } else {
        dialogHeight.value = dialogHeightBack.value;
        if (textSc3.text.isEmpty) {
          textSc3.text = 'Sconto 3';
        }
      }
    });

    textDescrNode.addListener(() {
      // Controlla se il TextField ha ottenuto il focus
      if (textDescrNode.hasFocus) {
        // Se sì, cancella il testo
        if (textDescr.text == 'Descrizione Prodotto') {
          textDescr.clear();
        }
      } else {
        if (textDescr.text.isEmpty) {
          textDescr.text = 'Descrizione Prodotto';
        }
      }
    });
  }

  void selectItem(String value) {
    selectedItem.value = value;
  }

  piuProdotto(index) async {
    prodottiCarrello[index].quantita.value++;
    prodottiCarrello[index].totale.value += prodottiCarrello[index].prezzo;
    updateCart(prodottiCarrello[index].prezzo, 1, prodottiCarrello[index].iva);
  }

  menoProdotto(index) {
    prodottiCarrello[index].totale.value -= prodottiCarrello[index].prezzo;
    updateCart(prodottiCarrello[index].prezzo, 0, prodottiCarrello[index].iva);
    if (prodottiCarrello[index].quantita.value - 1 == 0) {
      prodottiCarrello.removeAt(index);
      if (prodottiCarrello.isEmpty) {
        totale.value = 0;
        subTotale.value = 0;
        sconto.value = 0;
        tasse.value = 0;
        return;
      }
    } else {
      prodottiCarrello[index].quantita.value--;
    }
  }

  updateCart(double prezzo, int operazione, int iva) {
    if (operazione == 1) {
      subTotale.value += prezzo;
      tasse.value = tasse.value + ((prezzo * iva) / 100);
    } else {
      subTotale.value -= prezzo;
      tasse.value = tasse.value - ((prezzo * iva) / 100);
    }

    totale.value = subTotale.value + tasse.value;
  }

  addInCart(cata.Prodotto prod, RxDouble qta) async {
    int iva = await DatabaseHelper().getIva(prod.idIva);
    double prezzoScontato =
        omaggio.value == true ? prod.prezzo : calcolaSconto(prod.prezzo);
    debugPrint('iva: $iva');

    prodottiCarrello.add(cart.ProdottoCarrello(
        idProdotto: prod.id,
        nomeProdotto: prod.descrizione,
        quantita: RxDouble(qta.value),
        prezzoListino: prod.prezzo,
        prezzo: omaggio.value == true ? 0 : prezzoScontato,
        totale: omaggio.value == true
            ? 0.0.obs
            : RxDouble(prezzoScontato * qtaProdotto.value),
        iva: iva,
        idIva: prod.idIva,
        sconti: prod.prezzo - prezzoScontato,
        UM: prod.unMis,
        sconto1: textSc1.text == 'Sconto 1' ? 0 : double.parse(textSc1.text),
        sconto2: textSc2.text == 'Sconto 2' ? 0 : double.parse(textSc2.text),
        sconto3: textSc3.text == 'Sconto 3' ? 0 : double.parse(textSc3.text)));

    subTotale.value += omaggio.value ? 0 : (prezzoScontato * qtaProdotto.value);
    tasse.value +=
        omaggio.value ? 0 : ((prezzoScontato * qtaProdotto.value) * iva) / 100;

    totale.value = subTotale.value + tasse.value;
    sconto.value = sconto.value + (prod.prezzo - prezzoScontato);
  }

  double calcolaSconto(double prezzo) {
    debugPrint(textSc1.text);
    debugPrint(textSc2.text);
    debugPrint(textSc3.text);
    // Applica il primo sconto se è stato impostato
    if (textSc1.text != 'Sconto 1' &&
        textSc1.text != '' &&
        textSc1.text != ' ') {
      prezzo *= (1 - double.parse(textSc1.text) / 100);
    }

    // Applica il secondo sconto se è stato impostato
    if (textSc2.text != 'Sconto 2' &&
        textSc2.text != '' &&
        textSc2.text != ' ') {
      prezzo *= (1 - double.parse(textSc2.text) / 100);
    }

    // Applica il terzo sconto se è stato impostato
    if (textSc3.text != 'Sconto 3' &&
        textSc3.text != '' &&
        textSc3.text != ' ') {
      prezzo *= (1 - double.parse(textSc3.text) / 100);
    }

    return prezzo;
  }

  Future<List<cata.Prodotto>> caricaProdotti(int mbpc_id) async {
    List<cata.Prodotto> prodotti = await DatabaseHelper().getArticoli(mbpc_id);
    //final data = await json.decode(response);

    return prodotti;
  }

  clearProdotti() {
    prodotti.clear();
    prodottiOri.clear();
  }

  resetProdotti() {
    prodotti.clear();
    prodotti.addAll(prodottiOri);
  }

  filtraProdotti(String classe) {
    prodotti.clear();
    if (classe == 'TUTTI') {
      resetProdotti();
    } else {
      var prodottiTemp = prodottiOri.where((p0) {
        return p0.classe == classe;
      }).toList();
      for (var prodotto in prodottiTemp) {
        prodotti.add(prodotto);
      }
    }
  }

  Future<void> filtraProdottiAcquistati(int mbpcId) async {
    var prodottiTemp = await DatabaseHelper().getProdottiAcquistati(mbpcId);
    List<int> ids = prodottiTemp.map((e) => e['FTAR_MGAA_ID'] as int).toList();
    debugPrint(ids.toString());
    prodotti.clear();
    for (int id in ids) {
      for (var prodotto in prodottiOri) {
        if (prodotto.id == id) {
          prodotti.add(prodotto);
          break;
        }
      }
    }
  }

  filtraProdottiDescr(String descr) {
    prodotti.clear();
    var prodottiTemp = prodottiOri.where((p0) {
      if (descr == '') {
        return true;
      } else {
        return p0.descrizione.isCaseInsensitiveContainsAny(descr);
      }
    }).toList();
    for (var prodotto in prodottiTemp) {
      prodotti.add(prodotto);
    }
  }

  Future<void> geDisponibilita(int mgaaid) async {
    var dioClient = dio.Dio();
    String ipAddressApi = await DatabaseHelper().getServerAPI();
    try {
      final response =
          await dioClient.get('$ipAddressApi/disponibilita/$mgaaid');
      debugPrint('response: ${response.toString()}');

      disponibilita.value = jsonDecode(response.toString())['disp'].toString();
    } catch (e) {
      // Gestione degli errori di Dio (come timeout, connessione persa, ecc.)
      debugPrint('Errore durante la chiamata API: $e');
      disponibilita.value = 'N/D'; // Valore di fallback in caso di errore
    }
    /* final response = await dioClient.get('$ipAddressApi/disponibilita/$mgaaid');
    debugPrint(response.toString());
    disponibilita.value = jsonDecode(response.toString())['disp'].toString(); */
  }

  Future<int> salvaOrdine(int mbpc_id, int mban_id, double totale,
      WebSocketController wc, String note) async {
    String imei = await DatabaseHelper().getIMEI();
    int? ocanAppId = (await DatabaseHelper().getOcanAppId())!;
    int octiId = await DatabaseHelper().getTipoOrdine();
    int ocanNumOrd = await DatabaseHelper().getLastOrderNum() + 1;
    debugPrint('ocannumId: $ocanNumOrd');
    String indirizzo = await DatabaseHelper().getIndirizzo(mban_id);
    int mbsc_id = await DatabaseHelper().getMBSCID();
    int mbdv_id = await DatabaseHelper().getMBDVID();
    List<Map<String, dynamic>> list = [];
    Map<String, dynamic> head = {};
    List<RigaOrdine> righe = <RigaOrdine>[];
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    bool connected = false;
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Connesso a una rete mobile
      debugPrint('Connesso a rete mobile');
      connected = true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Connesso a una rete Wi-Fi
      debugPrint('Connesso a rete Wi-Fi');
      connected = true;
    } else {
      // Nessuna connessione
      debugPrint('Nessuna connessione a Internet');
      connected = false;
    }

    debugPrint('Salvataggio ordine...$octiId');
    debugPrint('mpc_id: $mbpc_id- mban_id: $mban_id- totale: $totale');
    debugPrint('OCAN_APP_ID: $imei-$ocanAppId');
    TestataOrdine testata = TestataOrdine(
      ocanId: 0,
      ocanMbpcId: mbpc_id,
      ocanAnnoOrd: DateTime.now().year,
      ocanOctiId: octiId,
      ocanNumOrd: ocanNumOrd,
      ocanDataIns: DateTime.now().toString(),
      ocanDataConf: DateTime.now().toString(),
      ocanStamp: 1,
      ocanNoteIniz: '',
      ocanNoteFin: '',
      ocanDataEvas: '',
      ocanEvaso: 0,
      ocanParzEvaso: 0,
      ocanEvasoForz: 0,
      ocanDestinat: selectedValue.value,
      ocanDestinaZ: selectedValue.value,
      ocanTotOrdine: totale,
      ocanDestMbanId: mban_id,
      ocanDeszMbanId: mban_id,
      ocanConfermato: 1,
      ocanDataCreate: '',
      ocanAppId: '$imei-$ocanAppId',
    );
    head = {
      "QUERY": "INSERT",
      "TABLE": "OC_Anag",
      "DATA": {
        "OCAN_NumOrd": ocanNumOrd,
        "OCAN_MBDV_Id": mbdv_id,
        "OCAN_MBSC_Id": mbsc_id,
        "OCAN_MBPC_Id": mbpc_id,
        "OCAN_OCTI_Id": octiId,
        "OCAN_AnnoOrd": "@ANNO_ORD",
        "OCAN_DataIns": "@DATA_INS",
        "OCAN_DataConf": "@DATA_CONF",
        "OCAN_Stamp": 0,
        "OCAN_NoteIniz": note,
        "OCAN_NoteFin": "",
        "OCAN_Evaso": 0,
        "OCAN_Cambio": 1,
        "OCAN_ParzEvaso": 0,
        "OCAN_EvasoForz": 0,
        "OCAN_MBDI_ID": 59,
        "OCAN_MBLN_ID": 13,
        "OCAN_Destinat":
            selectedValue.value.trim().isEmpty ? null : selectedValue.value,
        "OCAN_Destinaz":
            selectedValue.value.trim().isEmpty ? null : selectedValue.value,
        "OCAN_TotOrdine": totale,
        "OCAN_Dest_MBAN_Id": mban_id,
        "OCAN_Desz_MBAN_Id": mban_id,
        "OCAN_Confermato": 1,
        "OCAN_APP_ID": "$imei-$ocanAppId"
      }
    };
    list.add(head);

    double numRiga = 1;
    for (var prodotto in prodottiCarrello) {
      int ocarAppId = (await DatabaseHelper().getOcarAppId())!;

      RigaOrdine riga = RigaOrdine(
        ocarId: ocarAppId,
        ocarOcanId: ocanAppId,
        ocarNumRiga: numRiga, // Use ocarNumRiga from prodotto
        ocarMgaaId: prodotto.idProdotto,
        ocarQuantita: prodotto.quantita.value,
        ocarMbumCodice: prodotto.UM,
        ocarPrezzo: double.parse(prodotto.prezzo.toStringAsFixed(2)),
        ocarDescrArt: prodotto.nomeProdotto,
        ocarTotSconti: prodotto.sconti,
        ocarScontiFinali: prodotto.sconti,
        ocarPrezzoListino: prodotto.prezzoListino,
        ocarDqta: prodotto.quantita.value,
        ocarEForz: 0,
        ocarMbtaCodice: prodotto.prezzo == 0 ? 5 : 1,
        ocarAppID: '$imei-$ocarAppId',
        sconti: [
          if (prodotto.sconto1 != 0)
            ScontoRiga(
              ocPrior: 1,
              ocscMbstId: 23,
              ocscPercVal: 0,
              ocscBaseAppl: 1,
              ocscValore: prodotto.sconto1!,
              ocscFinale: 0,
              ocscTipo: 1,
              ocscFactor: 1,
              ocscForCfg: 0,
            ),
          if (prodotto.sconto2 != 0)
            ScontoRiga(
              ocPrior: 2,
              ocscMbstId: 25,
              ocscPercVal: 0,
              ocscBaseAppl: 0,
              ocscValore: prodotto.sconto2!,
              ocscFinale: 0,
              ocscTipo: 2,
              ocscFactor: 1,
              ocscForCfg: 0,
            ),
          if (prodotto.sconto3 != 0)
            ScontoRiga(
              ocPrior: 3,
              ocscMbstId: 26,
              ocscPercVal: 0,
              ocscBaseAppl: 0,
              ocscValore: prodotto.sconto3!,
              ocscFinale: 0,
              ocscTipo: 3,
              ocscFactor: 1,
              ocscForCfg: 0,
            ),
        ],
      );
      righe.add(riga);

      list.add({
        "QUERY": "INSERT",
        "TABLE": "OC_Artic",
        "DATA": {
          "OCAR_OCAN_Id": "@OCAN_ID",
          "OCAR_NumRiga": numRiga,
          "OCAR_MGAA_Id": prodotto.idProdotto,
          "OCAR_Quantita": prodotto.quantita.value,
          "OCAR_MBUM_Codice": prodotto.UM,
          "OCAR_Prezzo": prodotto.prezzoListino,
          "OCAR_DescrArt": prodotto.nomeProdotto,
          "OCAR_TotSconti": prodotto.sconti,
          "OCAR_ScontiFinali": prodotto.sconti,
          "OCAR_PrezzoListino": prodotto.prezzoListino,
          "OCAR_MBIV_ID": prodotto.idIva,
          "OCAR_DQTA": prodotto.quantita.value,
          "OCAR_EForz": 0,
          "OCAR_MBTA_Codice": prodotto.prezzo == 0 ? 5 : 1,
          "OCAR_APP_ID": "$imei-$ocarAppId"
        }
      });

      try {
        await DatabaseHelper().updateDbApprId(ocarAppId);
        numRiga++;
      } catch (e) {
        debugPrint(jsonEncode(e));
      }
    }

    list.add({
      "QUERY": "INSERT",
      "TABLE": "OC_Pagam",
      "DATA": {
        "MBPC_ID": mbpc_id,
        "OCPG_OCAN_Id": 0,
        "OCPG_MBTP_Id": "@MBTP_ID",
        "OCPG_MBSP_Id": "@MBSP_ID",
        "OCPG_Importo": "@IMPORTO",
        "OCPG_Perc": "@PERC"
      }
    });

    try {
      debugPrint('Testa ordine salvato con successo');
      await DatabaseHelper().updateDbApptId(ocanAppId);
    } catch (e) {
      debugPrint(jsonEncode(e));
    }

    try {
      int OCAN_ID = 0;

      for (var ele in list) {
        debugPrint("TABLE VALUE: '${ele['TABLE']}'");

        if (ele['TABLE'] == 'OC_Anag') {
          debugPrint('sto dentro l\'inserimento della testata');
          OCAN_ID = await wc.sendMessage(
              Messaggio(metsMessage: jsonEncode(ele), metsDataSave: 'diretto'));
          if (OCAN_ID == -1) {
            OCAN_ID = ocanAppId;
          }
          debugPrint('OCAN_ID: $OCAN_ID');
        } else if (ele['TABLE'] == 'OC_Artic') {
          ele["DATA"]["OCAR_OCAN_Id"] = OCAN_ID;
          int ocarId = await wc.sendMessage(
              Messaggio(metsMessage: jsonEncode(ele), metsDataSave: 'diretto'));

          // Genera e invia gli sconti per questa riga

          List<ScontoRiga> sconti = righe.firstWhere((r) {
            String ocarAppId = ele["DATA"]["OCAR_APP_ID"].toString();
            String idDaConfrontare = ocarAppId.split('-').last;

            return r.ocarId.toString() == idDaConfrontare;
          } //Aggiunto orElse per evitare l'errore "No element"
              ).sconti;

          for (int i = 0; i < sconti.length; i++) {
            Map<String, dynamic> scontoJson = {
              "QUERY": "INSERT",
              "TABLE": "OC_Sconti",
              "DATA": {
                "OCSC_OCAR_ID": ocarId,
                "OCSC_Prior": sconti[i].ocPrior,
                "OCSC_MBST_ID": sconti[i].ocscMbstId,
                "OCSC_percVal": sconti[i].ocscPercVal,
                "OCSC_BaseAppl": sconti[i].ocscBaseAppl,
                "OCSC_Valore": sconti[i].ocscValore,
                "OCSC_Finale": sconti[i].ocscFinale,
                "OCSC_Tipo": sconti[i].ocscTipo,
                "OCSC_Factor": sconti[i].ocscFactor,
                "OCSC_ForCfg": sconti[i].ocscForCfg,
              }
            };

            await wc.sendMessage(Messaggio(
                metsMessage: jsonEncode(scontoJson), metsDataSave: 'diretto'));
          }
        } else {
          ele["DATA"]["OCPG_OCAN_Id"] = OCAN_ID;
          await wc.sendMessage(
              Messaggio(metsMessage: jsonEncode(ele), metsDataSave: 'diretto'));
        }
      }
      /*  for (var ele in list) {
        debugPrint(
            "TABLE VALUE: '${ele['TABLE']}'"); // Stampa il valore preciso

        if (ele['TABLE'] == 'OC_Anag') {
          debugPrint('sto dentro l\'inserimento della testata');
          OCAN_ID = await wc.sendMessage(
              Messaggio(metsMessage: jsonEncode(ele), metsDataSave: 'diretto'));
          if (OCAN_ID == -1) {
            OCAN_ID = ocanAppId;
          }
          debugPrint('OCAN_ID: $OCAN_ID');
        } else if (ele['TABLE'] == 'OC_Artic') {
          ele["DATA"]["OCAR_OCAN_Id"] = OCAN_ID;
          await wc.sendMessage(
              Messaggio(metsMessage: jsonEncode(ele), metsDataSave: 'diretto'));
        } else {
          ele["DATA"]["OCPG_OCAN_Id"] = OCAN_ID;
          await wc.sendMessage(
              Messaggio(metsMessage: jsonEncode(ele), metsDataSave: 'diretto'));
        }
      } */
      testata.ocanId = OCAN_ID;
      await DatabaseHelper().insertTestataOrdine(testata);

      for (RigaOrdine riga in righe) {
        riga.ocarOcanId = OCAN_ID;
        await DatabaseHelper().insertRigaOrdine(riga);
      }
      //await DatabaseHelper().updateOcanId(OCAN_ID, "$imei-$ocanAppId");
      Get.back();
      Get.snackbar('Inserimento Ordine', 'Ordine Salvato con successo');
      return 1;
    } catch (e) {
      debugPrint('Errore: ${e.toString()}');
      Get.snackbar('Errore',
          'Errore durante il salvataggio dell\'ordine ${e.toString()}');
      // Gestisci l'errore come preferisci
      // Ad esempio, puoi mostrare un messaggio di errore all'utente
      // oppure registrare l'errore in un file di log
      // In questo caso, restituiamo -1 per indicare un errore
      return -1;
    }
  }

  Future<void> getInfoProdotto(int prodottoId, int mbpcId) async {
    righeStorico.clear();
    List<Map<String, dynamic>> righe =
        await DatabaseHelper().getFattureProdotto(prodottoId, mbpcId);

    for (var riga in righe) {
      String prezzo = riga['prezzo'].toStringAsFixed(2);
      righeStorico.add(
        DataRow(
          cells: <DataCell>[
            DataCell(Text(riga['FTAN_NumFatt'].toString())),
            DataCell(Text(DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(riga['FTAN_DataIns'])))),
            //DataCell(Text(riga['FTAR_Quantita'].toString())),
            DataCell(Text(double.parse(riga['FTAR_Quantita'].toString())
                .toStringAsFixed(2))),
            DataCell(Text(prezzo)),
            DataCell(Text(riga['unitario'].toStringAsFixed(2))),
          ],
        ),
      );
    }
  }

  switchOmaggio() {
    omaggio.value = !omaggio.value;
  }

  Future<void> switchAcquistati() async {
    acquistati.value = !acquistati.value;
  }
}
