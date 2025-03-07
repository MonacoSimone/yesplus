import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../models/messaggio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:connectivity_plus/connectivity_plus.dart';

class WebSocketController extends GetxController {
  static IO.Socket? socket;
  static RxBool isConnected = false.obs;
  RxString indirizzoServer = ''.obs;
  List<Messaggio> messages = [];
  int reconnectionAttempts = 0;
  final int maxReconnectionAttempts = 10;
  Timer? reconnectionTimer;

  @override
  void onInit() {
    super.onInit();
    //isConnected = false.obs;
    connectToWebSocket();
  }

  Future<String> getServerAddress() async {
    indirizzoServer.value = await DatabaseHelper().getServerWSK();
    return indirizzoServer.value;
  }

  Future<void> connectToWebSocket() async {
    debugPrint(await getServerAddress());
    debugPrint('server:${indirizzoServer.value}');

    if (indirizzoServer.value != 'Server WSK') {
      debugPrint('connessione al server in corso...');
      try {
        socket = IO.io(indirizzoServer.value, <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect':
              false, // Se necessario, commenta o rimuovi se non disponibile/applicabile
          'reconnection': true // Numero massimo di tentativi di riconnessione
        });
        await listenForEvent();
        await Future.delayed(
            const Duration(milliseconds: 500)); // Breve ritardo
        socket!.connect();
        update();
      } catch (e) {
        debugPrint('errore durante la connessione al server: $e');
      }
    }
  }

  Future<void> updateParameters(
      int mbtc, int octi, int ftti, int blti1, int blti2, int mbag) async {
    debugPrint(
        'Aggiorna parametri: $mbtc, $octi, $ftti, $blti1, $blti2, $mbag');
    socket!.emit('updateParameters', {
      "status": "success",
      "imei": await DatabaseHelper().getIMEI(),
      "mbtc": mbtc,
      "octi": octi,
      "ftti": ftti,
      "blti1": blti1,
      "blti2": blti2,
      "mbag": mbag
    });
  }

  Future<void> listenForEvent() async {
    // Assicurati che il socket non sia null
    if (socket == null) {
      debugPrint('Socket non è inizializzato.');
      return;
    }

    socket!.on('connect', (_) async {
      isConnected.value = true;
      update();
      debugPrint('Connessione riuscita: $isConnected');
      debugPrint('id socket: ${socket!.id} - ${socket!.connected}');
      socket!.emit('sendIMEI', await DatabaseHelper().getIMEI());
      debugPrint('inviato imei: ${await DatabaseHelper().getIMEI()}');
      /* reconnectionAttempts =
          0; // Reset dei tentativi di riconnessione dopo una connessione riuscita
      if (reconnectionTimer?.isActive ?? false) {
        reconnectionTimer
            ?.cancel(); // Ferma il timer se la connessione è riuscita
      } */
      messages = await DatabaseHelper().getMessages();
      if (messages.isNotEmpty && messages[0].metsId != 0) {
        await sendPendingMessages();
      }
    });

    socket!.on('disconnect', (_) async {
      debugPrint('Disconnesso dal server');
      isConnected.value = false;
      //attemptReconnection();
    });

    socket!.on('connect_error', (data) {
      debugPrint('Errore di connessione: $data');
    });

    socket!.on('connect_timeout', (data) {
      debugPrint('Timeout di connessione');
    });

    socket!.on('updateFromYes', (data) async {
      debugPrint("Dati ricevuti dal server: $data");

      // Invia ack al server
      int result = await execMessage(jsonDecode(data["messaggio"]));
      debugPrint('Invio ack al server: $result');

      if (result >= 0) {
        socket!.emit('ackMessageFromDevice', {
          "status": "success",
          "DISP_ID": data["DISP_ID"],
          "idMessaggio": data["IDmessaggio"],
          "ZAPPRAD_ID": data["ZAPPRAD_ID"]
        });
      } else {
        socket!.emit('ackMessageFromDevice', {
          "status": "error: $result",
          "DISP_ID": data["DISP_ID"],
          "idMessaggio": data["IDmessaggio"],
          "ZAPPRAD_ID": data["ZAPPRAD_ID"]
        });
      }
    });
    //TODO: Ragionare su cosa far rispondere ai messaggi da yes di insermento e cancellazione. se emettere ackMessageFromDevice.
    socket!.on('insertFromYes', (data) {
      debugPrint('insertFromYes: $data');
    });

    socket!.on('deleteFromYes', (data) {
      debugPrint('deleteFromYes: $data');
    });

    return;
  }

  static Future<String> disconnectSocket() async {
    try {
      socket!.disconnect();
      debugPrint('Disconnessione eseguita: ${socket!.connected}');
      return 'Disconnessione eseguita';
    } catch (e) {
      return 'Errore durante la disconnessione: $e';
    }
  }

  Future<int> sendMessage(Messaggio message) async {
    Completer<int> completer = Completer();

    // Verifica della connettività
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    bool connected = false;
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      debugPrint('Connesso a internet');
      connected = true;
    } else {
      debugPrint('Nessuna connessione a Internet');
      connected = false;
    }

    // Se c'è connessione e lo stato dell'app indica che è connessa
    if (isConnected.value && connected) {
      debugPrint('sono connesso');

      // Invia il messaggio tramite il socket
      socket!.emit('messaggio', message);

      // Ascolta la risposta dal server
      void onResponse(data) async {
        // Rimuove subito il listener per evitare che venga chiamato più volte
        socket!.off('messaggio_risposta', onResponse);

        if (data["success"]) {
          // Se il messaggio è stato inviato correttamente
          debugPrint(
              'inviato messaggio: ${message.metsMessage} id_restituito: ${data["id"]}');
          completer.complete(data["id"]);
        } else {
          // Se il messaggio non è stato inviato correttamente
          if (!completer.isCompleted) {
            completer.complete(-1);
          }
          debugPrint('messaggio non inviato: ${message.metsMessage}');
          saveMessageLocally(message);
        }
      }

      // Imposta il listener per la risposta del server
      socket!.on('messaggio_risposta', onResponse);
    } else {
      // Se non c'è connessione, salva il messaggio localmente
      debugPrint(
          'messaggio non inviato per mancanza di connessione: ${message.metsMessage}');
      saveMessageLocally(message);

      // Completa immediatamente con errore
      completer.complete(-1);
    }

    return completer.future;
  }

  Future<int> sendPendingMessages() async {
    Map<int, Map<String, List<Messaggio>>> ordini = {};
    Map<int, Map<String, List<Messaggio>>> pagamentiFornitore = {};

    for (Messaggio message in messages) {
      try {
        var messageData = message.toJson()['METS_Message'];
        messageData = jsonDecode(messageData);
        String table = messageData['TABLE'];
        int? id;

        if (table == 'OC_Anag') {
          id = int.parse(messageData['DATA']['OCAN_APP_ID'].split('-')[1]);
          if (!ordini.containsKey(id)) {
            ordini[id] = {'OC_Anag': [], 'OC_Artic': [], 'OC_Pagam': []};
          }
          ordini[id]![table]?.add(message);
        } else if (table == 'OC_Artic' || table == 'OC_Pagam') {
          id = messageData['DATA']
              [table == 'OC_Artic' ? 'OCAR_OCAN_Id' : 'OCPG_OCAN_Id'];
          if (id != null && ordini.containsKey(id)) {
            ordini[id]![table]?.add(message);
          }
        } else if (table == 'PF_Anag') {
          id = int.parse(messageData['DATA']['PFAN_APP_ID'].split('-')[1]);
          if (!pagamentiFornitore.containsKey(id)) {
            pagamentiFornitore[id] = {'PF_Anag': [], 'PF_Dett': []};
          }
          pagamentiFornitore[id]![table]?.add(message);
        } else if (table == 'PF_Dett') {
          id = messageData['DATA']['PFDT_PFAN_ID'];
          if (id != null && pagamentiFornitore.containsKey(id)) {
            pagamentiFornitore[id]![table]?.add(message);
          }
        }
      } catch (e) {
        debugPrint('Errore durante l\'elaborazione del messaggio: $e');
        return 0;
      }
    }

    // Elaborazione degli ordini (OC)
    for (int ocanId in ordini.keys) {
      var ordine = ordini[ocanId]!;

      try {
        if (ordine['OC_Anag']!.isNotEmpty) {
          Messaggio testataOrdine = ordine['OC_Anag']!.first;
          await DatabaseHelper()
              .deleteMessage(testataOrdine.toJson()['METS_ID']);
          int nuovoOcanId = await sendMessage(testataOrdine);

          await DatabaseHelper().updateOcanAnag(nuovoOcanId, ocanId);
          debugPrint('Nuovo OCAN_ID per OC_Anag: $nuovoOcanId');

          for (Messaggio rigaOrdine in ordine['OC_Artic']!) {
            var rigaData = rigaOrdine.toJson()['METS_Message'];
            rigaData = jsonDecode(rigaData);
            rigaData['DATA']['OCAR_OCAN_Id'] = nuovoOcanId;
            rigaOrdine.metsMessage = jsonEncode(rigaData);
            await DatabaseHelper().updateOcanArtic(nuovoOcanId, ocanId);
            await DatabaseHelper()
                .deleteMessage(rigaOrdine.toJson()['METS_ID']);
            await sendMessage(rigaOrdine);

            debugPrint(
                'Riga ordine aggiornata e inviata: ${rigaOrdine.metsMessage}');
          }

          for (Messaggio pagamento in ordine['OC_Pagam']!) {
            var pagamentoData = pagamento.toJson()['METS_Message'];
            pagamentoData = jsonDecode(pagamentoData);
            pagamentoData['DATA']['OCPG_OCAN_Id'] = nuovoOcanId;
            pagamento.metsMessage = jsonEncode(pagamentoData);
            await DatabaseHelper().deleteMessage(pagamento.toJson()['METS_ID']);
            await sendMessage(pagamento);

            debugPrint(
                'Pagamento aggiornato e inviato: ${pagamento.metsMessage}');
          }
        }
      } catch (e) {
        debugPrint('Errore durante l\'elaborazione dell\'ordine $ocanId: $e');
        return 0;
      }
    }

    // Elaborazione dei pagamenti fornitore (PF)
    for (int pfanId in pagamentiFornitore.keys) {
      var pagamentoFornitore = pagamentiFornitore[pfanId]!;
      debugPrint('Pagamento fornitore: ${pagamentoFornitore.toString()}');
      try {
        if (pagamentoFornitore['PF_Anag']!.isNotEmpty) {
          Messaggio testataPagamentoFornitore =
              pagamentoFornitore['PF_Anag']!.first;
          await DatabaseHelper()
              .deleteMessage(testataPagamentoFornitore.toJson()['METS_ID']);
          int nuovoPfanId = await sendMessage(testataPagamentoFornitore);

          debugPrint('Nuovo PFAN_ID per PF_Anag: $nuovoPfanId');

          for (Messaggio dettaglioPagamentoFornitore
              in pagamentoFornitore['PF_Dett']!) {
            var dettaglioData =
                dettaglioPagamentoFornitore.toJson()['METS_Message'];
            dettaglioData = jsonDecode(dettaglioData);
            dettaglioData['DATA']['PFDT_PFAN_ID'] = nuovoPfanId;
            dettaglioPagamentoFornitore.metsMessage = jsonEncode(dettaglioData);
            await DatabaseHelper()
                .deleteMessage(dettaglioPagamentoFornitore.toJson()['METS_ID']);
            await sendMessage(dettaglioPagamentoFornitore);

            debugPrint(
                'Dettaglio pagamento fornitore aggiornato e inviato: ${dettaglioPagamentoFornitore.metsMessage}');
          }
        }
      } catch (e) {
        debugPrint(
            'Errore durante l\'elaborazione del pagamento fornitore $pfanId: $e');
        return 0;
      }
    }

    return 1;
  }

  /* Future<int> sendPendingMessages() async {
    Map<int, Map<String, List<Messaggio>>> ordini = {};

    for (Messaggio message in messages) {
      try {
        var messageData = message.toJson()['METS_Message'];
        messageData = jsonDecode(messageData);
        String table = messageData['TABLE'];
        int? ocanId;

        if (table == 'OC_Anag') {
          ocanId = int.parse(messageData['DATA']['OCAN_APP_ID'].split('-')[1]);
        } else if (table == 'OC_Artic') {
          ocanId = messageData['DATA']['OCAR_OCAN_Id'];
        } else if (table == 'OC_Pagam') {
          ocanId = messageData['DATA']['OCPG_OCAN_Id'];
        }

        if (ocanId != null) {
          if (!ordini.containsKey(ocanId)) {
            ordini[ocanId] = {
              'OC_Anag': [],
              'OC_Artic': [],
              'OC_Pagam': [],
            };
          }
          ordini[ocanId]![table]?.add(message);
        }
      } catch (e) {
        debugPrint('Errore durante l\'elaborazione del messaggio: $e');
        return 0; // o altra gestione dell'errore
      }
    }

    for (int ocanId in ordini.keys) {
      var ordine = ordini[ocanId]!;

      try {
        if (ordine['OC_Anag']!.isNotEmpty) {
          Messaggio testataOrdine = ordine['OC_Anag']!.first;
          int nuovoOcanId = await sendMessage(testataOrdine);
          await DatabaseHelper()
              .deleteMessage(testataOrdine.toJson()['METS_ID']);
          await DatabaseHelper().updateOcanAnag(nuovoOcanId, ocanId);
          debugPrint('Nuovo OCAN_ID per OC_Anag: $nuovoOcanId');

          // Aggiorna e invia righe e pagamenti
          for (Messaggio rigaOrdine in ordine['OC_Artic']!) {
            var rigaData = rigaOrdine.toJson()['METS_Message'];
            rigaData = jsonDecode(rigaData);
            rigaData['DATA']['OCAR_OCAN_Id'] = nuovoOcanId;
            rigaOrdine.metsMessage = jsonEncode(rigaData);
            await DatabaseHelper().updateOcanArtic(nuovoOcanId, ocanId);
            await sendMessage(rigaOrdine);
            await DatabaseHelper()
                .deleteMessage(rigaOrdine.toJson()['METS_ID']);
            debugPrint(
                'Riga ordine aggiornata e inviata: ${rigaOrdine.metsMessage}');
          }

          for (Messaggio pagamento in ordine['OC_Pagam']!) {
            var pagamentoData = pagamento.toJson()['METS_Message'];
            pagamentoData = jsonDecode(pagamentoData);
            pagamentoData['DATA']['OCPG_OCAN_Id'] = nuovoOcanId;
            pagamento.metsMessage = jsonEncode(pagamentoData);
            await sendMessage(pagamento);
            await DatabaseHelper().deleteMessage(pagamento.toJson()['METS_ID']);
            debugPrint(
                'Pagamento aggiornato e inviato: ${pagamento.metsMessage}');
          }
        }
      } catch (e) {
        debugPrint('Errore durante l\'elaborazione dell\'ordine $ocanId: $e');
        return 0; // o altra gestione dell'errore
      }
    }

    return 1;
  } */

/*   Future<int> sendPendingMessages() async {
    // 2. Raggruppa i messaggi per OCAN_ID (ordine)
    Map<int, Map<String, List<Messaggio>>> ordini = {};

    for (Messaggio message in messages) {
      var messageData = message.toJson()['METS_Message'];
      messageData = jsonDecode(messageData);
      String table = messageData['TABLE'];
      int? ocanId;

      // Identifica l'OCAN_ID in base alla tipologia del messaggio
      if (table == 'OC_Anag') {
        ocanId = int.parse(messageData['DATA']['OCAN_APP_ID'].split('-')[1]);
      } else if (table == 'OC_Artic') {
        ocanId = messageData['DATA']['OCAR_OCAN_Id'];
      } else if (table == 'OC_Pagam') {
        ocanId = messageData['DATA']['OCPG_OCAN_Id'];
      }

      if (ocanId != null) {
        if (!ordini.containsKey(ocanId)) {
          ordini[ocanId] = {
            'OC_Anag': [],
            'OC_Artic': [],
            'OC_Pagam': [],
          };
        }
        ordini[ocanId]![table]?.add(message);
      }
    }

    // 3. Processa e invia i messaggi ordine per ordine
    for (int ocanId in ordini.keys) {
      var ordine = ordini[ocanId]!;

      // 3.1 Invia la testata (OC_Anag) e ottieni il nuovo OCAN_ID
      if (ordine['OC_Anag']!.isNotEmpty) {
        Messaggio testataMessage = ordine['OC_Anag']!.first;
        int newOcanId = await sendMessage(testataMessage);
        await DatabaseHelper()
            .deleteMessage(testataMessage.toJson()['METS_ID']);
        await DatabaseHelper().updateOcanAnag(newOcanId, ocanId);
        debugPrint('nuovo OCAN_ID per OC_Anag: $newOcanId');

        // 3.2 Aggiorna tutte le righe (OC_Artic) e i pagamenti (OC_Pagam) con il nuovo OCAN_ID

        for (Messaggio rigaMessage in ordine['OC_Artic']!) {
          var rigaData = rigaMessage.toJson()['METS_Message'];
          rigaData = jsonDecode(rigaData);
          //int oldOcanId = int.parse(rigaData['DATA']['OCAR_OCAN_Id']);
          rigaData['DATA']['OCAR_OCAN_Id'] = newOcanId;
          await DatabaseHelper().updateOcanArtic(newOcanId, ocanId);
          // Ricodifica i dati aggiornati e sostituisci nel Messaggio
          rigaMessage.metsMessage = jsonEncode(rigaData);
          debugPrint(
              'riga aggiornata: ${rigaMessage.metsMessage}'); // Verifica che l'aggiornamento sia corretto
        }

        for (Messaggio pagamentoMessage in ordine['OC_Pagam']!) {
          var pagamentoData = pagamentoMessage.toJson()['METS_Message'];
          pagamentoData = jsonDecode(pagamentoData);
          pagamentoData['DATA']['OCPG_OCAN_Id'] = newOcanId;

          // Ricodifica i dati aggiornati e sostituisci nel Messaggio
          pagamentoMessage.metsMessage = jsonEncode(pagamentoData);
          try {
            await sendMessage(pagamentoMessage);
            await DatabaseHelper()
                .deleteMessage(pagamentoMessage.toJson()['METS_ID']);
            /*  String ret =
                await DatabaseHelper().updateOcanPagam(oldOcanId, newOcanId);
            debugPrint('pagamento aggiornato1: $ret'); */
          } catch (e) {
            return 0;
          }

          debugPrint('pagamento aggiornato: ${pagamentoMessage.metsMessage}');
        }

        // 3.3 Invia tutte le righe dell'ordine (OC_Artic)
        for (Messaggio rigaMessage in ordine['OC_Artic']!) {
          debugPrint('riga message: ${rigaMessage.toJson()['METS_Message']}');
          try {
            await sendMessage(rigaMessage);
            await DatabaseHelper()
                .deleteMessage(rigaMessage.toJson()['METS_ID']);
          } catch (e) {
            return 0;
          }
        }

        // 3.4 Invia il pagamento (OC_Pagam)
        /*  for (Messaggio pagamentoMessage in ordine['OC_Pagam']!) {
          debugPrint(
              'pagamento message: ${pagamentoMessage.toJson()['METS_Message']}}');
        } */
      }
    }
    return 1;
  } */

// Funzione che invia un messaggio di testata e ritorna l'OCAN_ID
  Future<int> sendMessageAndGetOcanId(Messaggio message) async {
    int ocanId = 0;

    // Invia il messaggio e aspetta la risposta
    int response = await sendMessage(message);

    // Supponiamo che la risposta contenga l'OCAN_ID
    if (response > 0) {
      ocanId = response;
    } else {
      debugPrint(
          'Errore nel ricevere OCAN_ID per il messaggio ${message.metsId}');
    }

    return ocanId;
  }

  Future<void> saveMessageLocally(Messaggio message) async {
    try {
      await DatabaseHelper().saveMessage(message);
    } catch (e) {
      debugPrint('errore salvataggio messaggio locale: $e');
    }
  }

  ///execMessage controlla il contenuto dell'oggetto passato come argomento.
  ///Crea una query e restituisce l'id in caso di [INSERT], il numero di righe
  ///interessate in caso di [UPDATE] o [DELETE], -1 in caso di errore.
  Future<int> execMessage(Map<String, dynamic> oggetto) async {
    debugPrint(oggetto['TABLE']);
    String query = '';
    String tableName = oggetto['TABLE'];
    Map<String, dynamic> data = oggetto['DATA'];
    String whereClause = '';
    List<dynamic> values = [];
    switch (oggetto['QUERY']) {
      case 'UPDATE':
        String setClause = data.keys.map((key) => "$key = ?").join(", ");
        List<dynamic> values = data.values.toList();
        switch (tableName) {
          case 'CA_Partite':
            whereClause = 'CAPA_Id=?';
            values.add(data['CAPA_Id']);
            break;
          case 'MB_Anagr':
            whereClause = 'MBAN_ID=?';
            values.add(data['MBAN_ID']);
            break;
          case 'MB_TipiArticoloVA':
            whereClause = 'MBTA_ID=?';
            values.add(data['MBTA_ID']);
            break;
          case 'FT_Tipo':
            whereClause = 'FTTI_ID=?';
            values.add(data['FTTI_ID']);
            break;
          case 'BL_Tipo':
            whereClause = 'BLTI_ID=?';
            values.add(data['BLTI_ID']);
            break;
          case 'OC_Tipo':
            whereClause = 'OCTI_ID=?';
            values.add(data['OCTI_ID']);
            break;
          case 'MB_Agenti':
            whereClause = 'MBAG_ID=?';
            values.add(data['MBAG_ID']);
            break;
          case 'MB_IVA':
            whereClause = 'MBIV_ID=?';
            values.add(data['MBIV_ID']);
            break;
          case 'MB_TipoPag':
            whereClause = 'MBTP_ID=?';
            values.add(data['MBTP_ID']);
            break;
          case 'MB_SolPag':
            whereClause = 'MBSP_ID=?';
            values.add(data['MBSP_ID']);
            break;
          case 'BL_Pagam':
            whereClause = 'BLPG_ID=?';
            values.add(data['BLPG_ID']);
            break;
          /* case 'OC_Pagam':
            whereClause = 'OCPG_OCAN_ID=?';
            values.add(data['OCPG_OCAN_ID']);
            break; */
          case 'FT_Pagam':
            whereClause = 'FTPG_ID=?';
            values.add(data['FTPG_ID']);
            break;
          case 'MB_TipoConto':
            whereClause = 'MBTC_Id=?';
            values.add(data['MBTC_Id']);
            break;
          case 'MG_AnaArt':
            whereClause = 'MGAA_ID=?';
            values.add(data['MGAA_ID']);
            break;
          default:
            break;
        }
        query = "UPDATE $tableName SET $setClause WHERE $whereClause";
        debugPrint(query);
        debugPrint(jsonEncode(values));
        return await DatabaseHelper().rawUpd(query, values);
      //await db.rawUpdate(query, values);

      case 'INSERT':
        data = data.map((key, value) => MapEntry(
            key, (key == "ZPTV_MBPC_ID" && value == "0") ? null : value));
        String columns = data.keys.join(", ");
        String valueHolders = data.keys.map((_) => "?").join(", ");
        List<dynamic> values = data.values.toList();
        query =
            "INSERT OR IGNORE INTO $tableName ($columns) VALUES ($valueHolders)";
        //await db.rawInsert(query, values);
        int res = await DatabaseHelper().rawIns(query, values);
        try {
          return res;
        } catch (e) {
          debugPrint('Errore durante l\'inserimento nel database: $e');
          return res;
        }

      case 'DELETE':
        String whereClause = '';
        List<dynamic> values = [];
        List<dynamic> valuesFTAN = [];
        switch (tableName) {
          case 'CA_Partite':
            whereClause = 'CAPA_Id=?';
            values.add(data['CAPA_Id']);
            break;
          case 'MB_Anagr':
            whereClause = 'MBAN_ID=?';
            values.add(data['MBAN_ID']);
            break;
          case 'MB_TipiArticoloVA':
            whereClause = 'MBTA_ID=?';
            values.add(data['MBTA_ID']);
            break;
          case 'FT_Tipo':
            whereClause = 'FTTI_ID=?';
            values.add(data['FTTI_ID']);
            break;
          case 'BL_Tipo':
            whereClause = 'BLTI_ID=?';
            values.add(data['BLTI_ID']);
            break;
          case 'OC_Tipo':
            whereClause = 'OCTI_ID=?';
            values.add(data['OCTI_ID']);
            break;
          case 'MB_Agenti':
            whereClause = 'MBAG_ID=?';
            values.add(data['MBAG_ID']);
            break;
          case 'MB_IVA':
            whereClause = 'MBIV_ID=?';
            values.add(data['MBIV_ID']);
            break;
          case 'MB_TipoPag':
            whereClause = 'MBTP_ID=?';
            values.add(data['MBTP_ID']);
            break;
          case 'MB_SolPag':
            whereClause = 'MBSP_ID=?';
            values.add(data['MBSP_ID']);
            break;
          case 'BL_Pagam':
            whereClause = 'BLPG_ID=?';
            values.add(data['BLPG_ID']);
            break;
          case 'OC_Pagam':
            whereClause = 'OCPG_OCAN_ID=?';
            values.add(data['OCPG_OCAN_ID']);
            break;
          case 'FT_Pagam':
            whereClause = 'FTPG_ID=?';
            values.add(data['FTPG_ID']);
            break;
          case 'MB_TipoConto':
            whereClause = 'MBTC_Id=?';
            values.add(data['MBTC_Id']);
            break;
          case 'MG_AnaArt':
            whereClause = 'MGAA_ID=?';
            values.add(data['MGAA_ID']);
            break;
          case 'MB_CliForDest':
            whereClause = 'MBDT_ID=?';
            values.add(data['MBDT_ID']);
            break;
          case 'OC_Artic':
            if (data['OCAR_APP_ID'] == null || data['OCAR_APP_ID'].isEmpty) {
              whereClause =
                  'OCAR_Id=?'; // Usa OCAR_Id se OCAR_APP_ID è null o vuoto
              values.add(data['OCAR_Id']);
            } else {
              whereClause = 'OCAR_APP_ID=?'; // Usa OCAR_APP_ID se è presente
              values.add(data['OCAR_APP_ID']);
            }
            break;
          case 'OC_Anag':
            if (data['OCAN_APP_ID'] == null || data['OCAN_APP_ID'].isEmpty) {
              whereClause =
                  'OCAN_ID=?'; // Usa OCAR_Id se OCAR_APP_ID è null o vuoto
              values.add(data['OCAN_ID']);
            } else {
              whereClause = 'OCAN_APP_ID=?'; // Usa OCAR_APP_ID se è presente
              values.add(data['OCAN_APP_ID']);
            }

            await DatabaseHelper().rawDelete(
                'DELETE FROM OC_ARTIC WHERE OCAR_OCAN_ID=?', [data['OCAN_ID']]);
            await DatabaseHelper().rawDelete(
                'DELETE FROM OC_Pagam WHERE OCPG_OCAN_ID=?', [data['OCAN_ID']]);
            break;
          case 'FT_Anagr':
            whereClause = 'FTAN_ID=?';
            values.add(data['FTAN_ID']);
            await DatabaseHelper()
                .rawDelete('DELETE FROM FT_Pagam WHERE FTPG_FTAN_ID=?', values);
            await DatabaseHelper()
                .rawDelete('DELETE FROM FT_Artic WHERE FTAR_FTAN_ID=?', values);
            break;

          case 'BL_Anag':
            whereClause = 'BLAN_ID=?';
            values.add(data['BLAN_ID']);
            await DatabaseHelper()
                .rawDelete('DELETE FROM BL_Pagam WHERE BLPG_BLAN_ID=?', values);
            await DatabaseHelper()
                .rawDelete('DELETE FROM BL_Artic WHERE BLAR_BLAN_ID=?', values);
            break;
          case 'Z_PrezziTv':
            whereClause = 'ZPTV_ID=?';
            values.add(data['ZPTV_ID']);
            break;
          default:
            break;
        }
        query = "DELETE FROM $tableName WHERE $whereClause";
        debugPrint('$query - ${jsonEncode(values)}');
        return await DatabaseHelper().rawDelete(query, values);
      //await db.rawDelete(query, values);
      case 'PROC':
        // Per PROC, controlla se la riga esiste e decidi tra INSERT o UPDATE
        bool exists = false;

        switch (tableName) {
          case 'OC_Anag':
            whereClause =
                data['OCAN_APP_ID'] == 0 ? 'OCAN_APP_ID = ?' : 'OCAN_ID = ?';
            values.add(
                data[whereClause.contains('APP') ? 'OCAN_APP_ID' : 'OCAN_ID']);
            exists = await DatabaseHelper()
                .recordExists(tableName, whereClause, values);
            debugPrint('Esiste una riga con questa chiave: $exists');
            break;

          case 'OC_Artic':
            whereClause = data['OCAR_APP_ID']?.isNotEmpty == 0
                ? 'OCAR_APP_ID = ?'
                : 'OCAR_Id = ?';
            values.add(
                data[whereClause.contains('APP') ? 'OCAR_APP_ID' : 'OCAR_Id']);
            exists = await DatabaseHelper()
                .recordExists(tableName, whereClause, values);
            break;

          case 'OC_Pagam':
            whereClause = 'OCPG_OCAN_ID = ?';
            values.add(data['OCPG_OCAN_ID']);
            exists = await DatabaseHelper()
                .recordExists(tableName, whereClause, values);
            break;

          case 'FT_Anagr':
            whereClause = 'FTAN_ID = ?';
            values.add(data['FTAN_ID']);
            exists = await DatabaseHelper()
                .recordExists(tableName, whereClause, values);
            break;
          case 'FT_Artic':
            whereClause = 'FTAR_ID = ?';
            values.add(data['FTAR_ID']);
            exists = await DatabaseHelper()
                .recordExists(tableName, whereClause, values);
            break;
          case 'FT_Pagam':
            whereClause = 'FTPG_FTAN_ID = ?';
            values.add(data['FTPG_FTAN_ID']);
            exists = await DatabaseHelper()
                .recordExists(tableName, whereClause, values);
            break;
          case 'BL_Anag':
            whereClause = 'BLAN_ID = ?';
            values.add(data['BLAN_ID']);
            exists = await DatabaseHelper()
                .recordExists(tableName, whereClause, values);
            break;
          case 'BL_Artic':
            whereClause = 'BLAR_ID = ?';
            values.add(data['BLAR_ID']);
            exists = await DatabaseHelper()
                .recordExists(tableName, whereClause, values);
            break;
          case 'BL_Pagam':
            whereClause = 'BLPG_BLAN_ID = ?';
            values.add(data['BLPG_BLAN_ID']);
            exists = await DatabaseHelper()
                .recordExists(tableName, whereClause, values);
            break;

          default:
            throw Exception('Tabella non supportata per PROC: $tableName');
        }

        if (exists) {
          // Se la riga esiste, esegui l'UPDATE
          String setClause = data.keys.map((key) => "$key = ?").join(", ");
          List<dynamic> updateValues = data.values.toList() + values;
          query = "UPDATE $tableName SET $setClause WHERE $whereClause";
          return await DatabaseHelper().rawUpd(query, updateValues);
        } else {
          // Se la riga non esiste, esegui l'INSERT
          String columns = data.keys.join(", ");
          String valueHolders = data.keys.map((_) => "?").join(", ");
          List<dynamic> insertValues = data.values.toList();
          query = "INSERT INTO $tableName ($columns) VALUES ($valueHolders)";
          return await DatabaseHelper().rawIns(query, insertValues);
        }

      default:
        throw Exception("Tipo di query non supportato: ${oggetto['QUERY']}");
    }
  }

  // Funzione di supporto per verificare se una riga esiste

  @override
  void onClose() {
    socket!.disconnect();
    super.onClose();
  }

  @override
  void dispose() {
    socket!.dispose();
    super.dispose();
  }
}
