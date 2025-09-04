/* import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../models/messaggio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/testataordine.dart';
import '../models/righeOrdine.dart';

class WebSocketController extends GetxController {
  static IO.Socket? socket;
  static RxBool isConnected = false.obs;
  RxString indirizzoServer = ''.obs;
  List<Messaggio> messages = [];
  final Rx<Map<String, dynamic>> backgroundSyncResult = Rx({});

  @override
  void onInit() {
    super.onInit();
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
          'autoConnect': false,
          'reconnection': true
        });
        await _listenForEvents();
        await Future.delayed(const Duration(milliseconds: 500));
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

  Future<void> _checkPendingSyncs() async {
    debugPrint('Controllo ordini con sincronizzazione in sospeso...');
    final pendingOrders = await DatabaseHelper().getPendingSyncOrders();
    if (pendingOrders.isEmpty) {
      debugPrint('Nessun ordine in sospeso trovato.');
      return;
    }

    debugPrint(
        'Trovati ${pendingOrders.length} ordini in sospeso. Chiedo lo stato al server...');
    for (final order in pendingOrders) {
      if (order.ocanAppId != null) {
        socket!.emit('sync_check', {'ocanAppId': order.ocanAppId});
      }
    }
  }

  Future<void> _resendFullOrder(String ocanAppId) async {
    debugPrint('Il server non ha trovato l\'ordine $ocanAppId. Lo reinvio...');
    final fullOrderData = await DatabaseHelper().getFullOrderByAppId(ocanAppId);

    if (fullOrderData.isEmpty) {
      debugPrint(
          'ERRORE CRITICO: Impossibile trovare l\'ordine $ocanAppId nel DB locale per il reinvio.');
      return;
    }

    final testata = TestataOrdine.fromJson(fullOrderData['header']);
    final righe = (fullOrderData['lines'] as List)
        .map((r) => RigaOrdine.fromJson(r))
        .toList();

    Map<String, dynamic> fullOrderMessage = {
      "QUERY": "INSERT_FULL_ORDER",
      "DATA": {
        "header": testata.toJson(),
        "lines": righe.map((r) => r.toJson()).toList(),
      }
    };

    sendMessage(Messaggio(
      metsMessage: jsonEncode(fullOrderMessage),
      metsDataSave: 'diretto',
    ));
  }

  Future<void> _listenForEvents() async {
    if (socket == null) {
      debugPrint('Socket non è inizializzato.');
      return;
    }

    socket!.on('connect', (_) async {
      isConnected.value = true;
      update();
      debugPrint('Connessione riuscita: ${socket!.id}');
      socket!.emit('sendIMEI', await DatabaseHelper().getIMEI());

      await _checkPendingSyncs();

      sendPendingMessages();
    });

    socket!.on('disconnect', (_) async {
      debugPrint('Disconnesso dal server');
      isConnected.value = false;
    });

    socket!.on('connect_error', (data) {
      debugPrint('Errore di connessione: $data');
    });

    socket!.on('sync_check_response', (data) async {
      final String ocanAppId = data['ocanAppId'];
      final String status = data['status'];

      if (status == 'not_found') {
        await _resendFullOrder(ocanAppId);
      } else {
        debugPrint('Risposta sync_check per $ocanAppId non gestita: $status');
      }
    });

    socket!.on('updateFromYes', (data) async {
      debugPrint("Dati ricevuti dal server: $data");
      int result = await execMessage(jsonDecode(data["messaggio"]));
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
  }

  static Future<String> disconnectSocket() async {
    try {
      if (socket != null && socket!.connected) {
        socket!.disconnect();
        debugPrint('Disconnessione eseguita: ${socket!.connected}');
        return 'Disconnessione eseguita';
      }
      return 'Socket non connesso.';
    } catch (e) {
      return 'Errore durante la disconnessione: $e';
    }
  }

  Future<int> sendMessage(Messaggio message) async {
    Completer<int> completer = Completer();
    final connectivityResult = await (Connectivity().checkConnectivity());
    bool connected = connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);

    if (isConnected.value && connected) {
      debugPrint('Invio messaggio al server...');
      socket!.emit('messaggio', message.toJson());

      void onResponse(data) async {
        socket!.off('messaggio_risposta', onResponse);
        if (!completer.isCompleted) {
          if (data["success"]) {
            if (data["permanentIds"] != null) {
              final ids = data["permanentIds"];
              final String ocanAppId = ids["ocanAppId"];
              final int permanentOcanId = ids["permanentOcanId"];
              final Map<String, int> ocarIdMapping =
                  Map<String, int>.from(ids["ocarIdMapping"]);
              debugPrint(
                  'Ricevuta conferma e mappatura ID per ordine $ocanAppId.');
              await DatabaseHelper().updateOrderAsSynced(
                  ocanAppId, permanentOcanId, ocarIdMapping);
              completer.complete(permanentOcanId);
            } else if (data["id"] != null) {
              debugPrint('inviato messaggio, id_restituito: ${data["id"]}');
              completer.complete(data["id"]);
            } else {
              debugPrint(
                  'Ricevuta conferma generica dal server: ${data["message"]}');
              completer.complete(1);
            }
          } else {
            debugPrint('Il server ha risposto con un errore: ${data["error"]}');
            completer.complete(-1);
          }
        }
      }

      socket!.on('messaggio_risposta', onResponse);
    } else {
      debugPrint('Connessione assente. Messaggio salvato in coda locale.');
      saveMessageLocally(message);
      completer.complete(-1);
    }
    return completer.future;
  }

  Future<void> saveMessageLocally(Messaggio message) async {
    try {
      await DatabaseHelper().saveMessage(message);
    } catch (e) {
      debugPrint('errore salvataggio messaggio locale: $e');
    }
  }

  Future<int> sendPendingMessages() async {
    Map<int, Map<String, List<Messaggio>>> ordini = {};
    Map<int, Map<String, List<Messaggio>>> pagamentiFornitore = {};

    messages = await DatabaseHelper().getMessages();
    if (messages.isEmpty) {
      debugPrint("Nessun messaggio in coda da inviare.");
      return 1;
    }

    for (Messaggio message in messages) {
      try {
        final messageContent = message.metsMessage;
        if (messageContent == null || messageContent.isEmpty) {
          debugPrint(
              'Messaggio pendente con contenuto nullo o vuoto (METS_ID: ${message.metsId}). Lo salto.');
          continue;
        }

        var messageData = jsonDecode(messageContent);
        // Aggiunto controllo per robustezza
        if (messageData is! Map || !messageData.containsKey('TABLE')) {
          debugPrint(
              'Messaggio pendente malformato (METS_ID: ${message.metsId}). Lo salto.');
          continue;
        }

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
        debugPrint(
            'Errore durante l\'elaborazione del messaggio (METS_ID: ${message.metsId}): $e');
        continue;
      }
    }

    for (int ocanId in ordini.keys) {
      var ordine = ordini[ocanId]!;
      try {
        if (ordine['OC_Anag']!.isNotEmpty) {
          Messaggio testataOrdine = ordine['OC_Anag']!.first;
          await DatabaseHelper()
              .deleteMessage(testataOrdine.toJson()['METS_ID']);
          int nuovoOcanId = await sendMessage(testataOrdine);

          if (nuovoOcanId != -1) {
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
            }

            for (Messaggio pagamento in ordine['OC_Pagam']!) {
              var pagamentoData = pagamento.toJson()['METS_Message'];
              pagamentoData = jsonDecode(pagamentoData);
              pagamentoData['DATA']['OCPG_OCAN_Id'] = nuovoOcanId;
              pagamento.metsMessage = jsonEncode(pagamentoData);
              await DatabaseHelper()
                  .deleteMessage(pagamento.toJson()['METS_ID']);
              await sendMessage(pagamento);
            }
          } else {
            await saveMessageLocally(testataOrdine);
            debugPrint(
                "Invio testata ordine $ocanId fallito. L'ordine è stato rimesso in coda.");
          }
        }
      } catch (e) {
        debugPrint('Errore durante l\'elaborazione dell\'ordine $ocanId: $e');
      }
    }

    for (int pfanId in pagamentiFornitore.keys) {
      var pagamentoFornitore = pagamentiFornitore[pfanId]!;
      try {
        if (pagamentoFornitore['PF_Anag']!.isNotEmpty) {
          Messaggio testataPagamentoFornitore =
              pagamentoFornitore['PF_Anag']!.first;
          await DatabaseHelper()
              .deleteMessage(testataPagamentoFornitore.toJson()['METS_ID']);
          int nuovoPfanId = await sendMessage(testataPagamentoFornitore);

          if (nuovoPfanId != -1) {
            debugPrint('Nuovo PFAN_ID per PF_Anag: $nuovoPfanId');

            for (Messaggio dettaglioPagamentoFornitore
                in pagamentoFornitore['PF_Dett']!) {
              var dettaglioData =
                  dettaglioPagamentoFornitore.toJson()['METS_Message'];
              dettaglioData = jsonDecode(dettaglioData);
              dettaglioData['DATA']['PFDT_PFAN_ID'] = nuovoPfanId;
              dettaglioPagamentoFornitore.metsMessage =
                  jsonEncode(dettaglioData);
              await DatabaseHelper().deleteMessage(
                  dettaglioPagamentoFornitore.toJson()['METS_ID']);
              await sendMessage(dettaglioPagamentoFornitore);
            }
          } else {
            await saveMessageLocally(testataPagamentoFornitore);
            debugPrint(
                "Invio testata pagamento $pfanId fallito. Il pagamento è stato rimesso in coda.");
          }
        }
      } catch (e) {
        debugPrint(
            'Errore durante l\'elaborazione del pagamento fornitore $pfanId: $e');
      }
    }

    return 1;
  }

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

      case 'INSERT':
        data = data.map((key, value) => MapEntry(
            key, (key == "ZPTV_MBPC_ID" && value == "0") ? null : value));
        String columns = data.keys.join(", ");
        String valueHolders = data.keys.map((_) => "?").join(", ");
        List<dynamic> values = data.values.toList();
        query =
            "INSERT OR IGNORE INTO $tableName ($columns) VALUES ($valueHolders)";
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
              whereClause = 'OCAR_Id=?';
              values.add(data['OCAR_Id']);
            } else {
              whereClause = 'OCAR_APP_ID=?';
              values.add(data['OCAR_APP_ID']);
            }
            break;
          case 'OC_Anag':
            if (data['OCAN_APP_ID'] == null || data['OCAN_APP_ID'].isEmpty) {
              whereClause = 'OCAN_ID=?';
              values.add(data['OCAN_ID']);
            } else {
              whereClause = 'OCAN_APP_ID=?';
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

      case 'PROC':
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
          String setClause = data.keys.map((key) => "$key = ?").join(", ");
          List<dynamic> updateValues = data.values.toList() + values;
          query = "UPDATE $tableName SET $setClause WHERE $whereClause";
          return await DatabaseHelper().rawUpd(query, updateValues);
        } else {
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

  @override
  void onClose() {
    socket?.disconnect();
    super.onClose();
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }
} */
//-- versione ultima
/* import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../models/messaggio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/testataordine.dart';
import '../models/righeOrdine.dart';

class WebSocketController extends GetxController {
  static IO.Socket? socket;
  static RxBool isConnected = false.obs;
  RxString indirizzoServer = ''.obs;
  List<Messaggio> messages = [];
  final Rx<Map<String, dynamic>> backgroundSyncResult = Rx({});

  @override
  void onInit() {
    super.onInit();
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
          'autoConnect': false,
          'reconnection': true
        });
        await _listenForEvents();
        await Future.delayed(const Duration(milliseconds: 500));
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

  Future<void> _checkPendingSyncs() async {
    debugPrint('Controllo ordini con sincronizzazione in sospeso...');
    final pendingOrders = await DatabaseHelper().getPendingSyncOrders();
    if (pendingOrders.isEmpty) {
      debugPrint('Nessun ordine in sospeso trovato.');
      return;
    }

    debugPrint('Trovati ${pendingOrders.length} ordini in sospeso. Chiedo lo stato al server...');
    for (final order in pendingOrders) {
      if (order.ocanAppId != null) {
        socket!.emit('sync_check', {'ocanAppId': order.ocanAppId});
      }
    }
  }
  
  Future<void> _resendFullOrder(String ocanAppId) async {
      debugPrint('Il server non ha trovato l\'ordine $ocanAppId. Lo reinvio...');
      final fullOrderData = await DatabaseHelper().getFullOrderByAppId(ocanAppId);

      if (fullOrderData.isEmpty) {
          debugPrint('ERRORE CRITICO: Impossibile trovare l\'ordine $ocanAppId nel DB locale per il reinvio.');
          return;
      }
      
      final testata = TestataOrdine.fromJson(fullOrderData['header']);
      final righe = (fullOrderData['lines'] as List).map((r) => RigaOrdine.fromJson(r)).toList();

      Map<String, dynamic> fullOrderMessage = {
          "QUERY": "INSERT_FULL_ORDER",
          "DATA": {
              "header": testata.toJson(),
              "lines": righe.map((r) => r.toJson()).toList(),
          }
      };

      sendMessage(Messaggio(
          metsMessage: jsonEncode(fullOrderMessage),
          metsDataSave: 'diretto',
      ));
  }

  Future<void> _listenForEvents() async {
    if (socket == null) {
      debugPrint('Socket non è inizializzato.');
      return;
    }

    socket!.on('connect', (_) async {
      isConnected.value = true;
      update();
      debugPrint('Connessione riuscita: ${socket!.id}');
      socket!.emit('sendIMEI', await DatabaseHelper().getIMEI());
      
      await _checkPendingSyncs();
      
      sendPendingMessages();
    });

    socket!.on('disconnect', (_) async {
      debugPrint('Disconnesso dal server');
      isConnected.value = false;
    });

    socket!.on('connect_error', (data) {
      debugPrint('Errore di connessione: $data');
    });

    socket!.on('sync_check_response', (data) async {
        final String ocanAppId = data['ocanAppId'];
        final String status = data['status'];

        if (status == 'not_found') {
            await _resendFullOrder(ocanAppId);
        } else {
            debugPrint('Risposta sync_check per $ocanAppId non gestita: $status');
        }
    });

    socket!.on('updateFromYes', (data) async {
      debugPrint("Dati ricevuti dal server: $data");
      int result = await execMessage(jsonDecode(data["messaggio"]));
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
  }
  
  static Future<String> disconnectSocket() async {
    try {
      if (socket != null && socket!.connected) {
        socket!.disconnect();
        debugPrint('Disconnessione eseguita: ${socket!.connected}');
        return 'Disconnessione eseguita';
      }
      return 'Socket non connesso.';
    } catch (e) {
      return 'Errore durante la disconnessione: $e';
    }
  }

  Future<int> sendMessage(Messaggio message) async {
    Completer<int> completer = Completer();
    final connectivityResult = await (Connectivity().checkConnectivity());
    bool connected = connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);

    if (isConnected.value && connected) {
      debugPrint('Invio messaggio al server...');
      socket!.emit('messaggio', message.toJson());

      void onResponse(data) async {
        socket!.off('messaggio_risposta', onResponse);
        if (!completer.isCompleted) {
          if (data["success"]) {
            if (data["permanentIds"] != null) {
              final ids = data["permanentIds"];
              final String ocanAppId = ids["ocanAppId"];
              final int permanentOcanId = ids["permanentOcanId"];
              final Map<String, int> ocarIdMapping = Map<String, int>.from(ids["ocarIdMapping"]);
              debugPrint('Ricevuta conferma e mappatura ID per ordine $ocanAppId.');
              await DatabaseHelper().updateOrderAsSynced(ocanAppId, permanentOcanId, ocarIdMapping);
              completer.complete(permanentOcanId);
            } else if (data["id"] != null) {
              debugPrint('inviato messaggio, id_restituito: ${data["id"]}');
              completer.complete(data["id"]);
            } else {
              debugPrint('Ricevuta conferma generica dal server: ${data["message"]}');
              completer.complete(1); 
            }
          } else {
            debugPrint('Il server ha risposto con un errore: ${data["error"]}');
            completer.complete(-1);
          }
        }
      }

      socket!.on('messaggio_risposta', onResponse);
    } else {
      debugPrint('Connessione assente. Messaggio salvato in coda locale.');
      saveMessageLocally(message);
      completer.complete(-1);
    }
    return completer.future;
  }

  Future<void> saveMessageLocally(Messaggio message) async {
    try {
      await DatabaseHelper().saveMessage(message);
    } catch (e) {
      debugPrint('errore salvataggio messaggio locale: $e');
    }
  }

  Future<int> sendPendingMessages() async {
    Map<int, Map<String, List<Messaggio>>> ordini = {};
    Map<int, Map<String, List<Messaggio>>> pagamentiFornitore = {};
  
    messages = await DatabaseHelper().getMessages();
    if (messages.isEmpty) {
      debugPrint("Nessun messaggio in coda da inviare.");
      return 1;
    }
  
    for (Messaggio message in messages) {
      try {
        final messageContent = message.metsMessage;
        if (messageContent == null || messageContent.isEmpty) {
          debugPrint('Messaggio pendente con contenuto nullo o vuoto (METS_ID: ${message.metsId}). Lo salto.');
          continue;
        }
  
        var messageData = jsonDecode(messageContent);
        // Aggiunto controllo per robustezza
        if (messageData is! Map || !messageData.containsKey('TABLE')) {
            debugPrint('Messaggio pendente malformato (METS_ID: ${message.metsId}). Lo salto.');
            continue;
        }

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
        debugPrint('Errore durante l\'elaborazione del messaggio (METS_ID: ${message.metsId}): $e');
        continue; 
      }
    }
  
    for (int ocanId in ordini.keys) {
      var ordine = ordini[ocanId]!;
      try {
        if (ordine['OC_Anag']!.isNotEmpty) {
          Messaggio testataOrdine = ordine['OC_Anag']!.first;
          await DatabaseHelper().deleteMessage(testataOrdine.toJson()['METS_ID']);
          int nuovoOcanId = await sendMessage(testataOrdine);
  
          if (nuovoOcanId != -1) {
              await DatabaseHelper().updateOcanAnag(nuovoOcanId, ocanId);
              debugPrint('Nuovo OCAN_ID per OC_Anag: $nuovoOcanId');
  
              for (Messaggio rigaOrdine in ordine['OC_Artic']!) {
                var rigaData = rigaOrdine.toJson()['METS_Message'];
                rigaData = jsonDecode(rigaData);
                rigaData['DATA']['OCAR_OCAN_Id'] = nuovoOcanId;
                rigaOrdine.metsMessage = jsonEncode(rigaData);
                await DatabaseHelper().updateOcanArtic(nuovoOcanId, ocanId);
                await DatabaseHelper().deleteMessage(rigaOrdine.toJson()['METS_ID']);
                await sendMessage(rigaOrdine);
              }
  
              for (Messaggio pagamento in ordine['OC_Pagam']!) {
                var pagamentoData = pagamento.toJson()['METS_Message'];
                pagamentoData = jsonDecode(pagamentoData);
                pagamentoData['DATA']['OCPG_OCAN_Id'] = nuovoOcanId;
                pagamento.metsMessage = jsonEncode(pagamentoData);
                await DatabaseHelper().deleteMessage(pagamento.toJson()['METS_ID']);
                await sendMessage(pagamento);
              }
          } else {
              await saveMessageLocally(testataOrdine);
              debugPrint("Invio testata ordine $ocanId fallito. L'ordine è stato rimesso in coda.");
          }
        }
      } catch (e) {
        debugPrint('Errore durante l\'elaborazione dell\'ordine $ocanId: $e');
      }
    }
  
    for (int pfanId in pagamentiFornitore.keys) {
      var pagamentoFornitore = pagamentiFornitore[pfanId]!;
      try {
        if (pagamentoFornitore['PF_Anag']!.isNotEmpty) {
          Messaggio testataPagamentoFornitore = pagamentoFornitore['PF_Anag']!.first;
          await DatabaseHelper().deleteMessage(testataPagamentoFornitore.toJson()['METS_ID']);
          int nuovoPfanId = await sendMessage(testataPagamentoFornitore);
  
          if (nuovoPfanId != -1) {
              debugPrint('Nuovo PFAN_ID per PF_Anag: $nuovoPfanId');
  
              for (Messaggio dettaglioPagamentoFornitore in pagamentoFornitore['PF_Dett']!) {
                var dettaglioData = dettaglioPagamentoFornitore.toJson()['METS_Message'];
                dettaglioData = jsonDecode(dettaglioData);
                dettaglioData['DATA']['PFDT_PFAN_ID'] = nuovoPfanId;
                dettaglioPagamentoFornitore.metsMessage = jsonEncode(dettaglioData);
                await DatabaseHelper().deleteMessage(dettaglioPagamentoFornitore.toJson()['METS_ID']);
                await sendMessage(dettaglioPagamentoFornitore);
              }
          } else {
              await saveMessageLocally(testataPagamentoFornitore);
              debugPrint("Invio testata pagamento $pfanId fallito. Il pagamento è stato rimesso in coda.");
          }
        }
      } catch (e) {
        debugPrint('Errore durante l\'elaborazione del pagamento fornitore $pfanId: $e');
      }
    }
  
    return 1;
  }

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

      case 'INSERT':
        data = data.map((key, value) => MapEntry(
            key, (key == "ZPTV_MBPC_ID" && value == "0") ? null : value));
        String columns = data.keys.join(", ");
        String valueHolders = data.keys.map((_) => "?").join(", ");
        List<dynamic> values = data.values.toList();
        query =
            "INSERT OR IGNORE INTO $tableName ($columns) VALUES ($valueHolders)";
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
              whereClause = 'OCAR_Id=?';
              values.add(data['OCAR_Id']);
            } else {
              whereClause = 'OCAR_APP_ID=?';
              values.add(data['OCAR_APP_ID']);
            }
            break;
          case 'OC_Anag':
            if (data['OCAN_APP_ID'] == null || data['OCAN_APP_ID'].isEmpty) {
              whereClause = 'OCAN_ID=?';
              values.add(data['OCAN_ID']);
            } else {
              whereClause = 'OCAN_APP_ID=?';
              values.add(data['OCAN_APP_ID']);
            }
            await DatabaseHelper().rawDelete('DELETE FROM OC_ARTIC WHERE OCAR_OCAN_ID=?', [data['OCAN_ID']]);
            await DatabaseHelper().rawDelete('DELETE FROM OC_Pagam WHERE OCPG_OCAN_ID=?', [data['OCAN_ID']]);
            break;
          case 'FT_Anagr':
            whereClause = 'FTAN_ID=?';
            values.add(data['FTAN_ID']);
            await DatabaseHelper().rawDelete('DELETE FROM FT_Pagam WHERE FTPG_FTAN_ID=?', values);
            await DatabaseHelper().rawDelete('DELETE FROM FT_Artic WHERE FTAR_FTAN_ID=?', values);
            break;
          case 'BL_Anag':
            whereClause = 'BLAN_ID=?';
            values.add(data['BLAN_ID']);
            await DatabaseHelper().rawDelete('DELETE FROM BL_Pagam WHERE BLPG_BLAN_ID=?', values);
            await DatabaseHelper().rawDelete('DELETE FROM BL_Artic WHERE BLAR_BLAN_ID=?', values);
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

      case 'PROC':
        bool exists = false;
        switch (tableName) {
          case 'OC_Anag':
            whereClause = data['OCAN_APP_ID'] == 0 ? 'OCAN_APP_ID = ?' : 'OCAN_ID = ?';
            values.add(data[whereClause.contains('APP') ? 'OCAN_APP_ID' : 'OCAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            debugPrint('Esiste una riga con questa chiave: $exists');
            break;
          case 'OC_Artic':
            whereClause = data['OCAR_APP_ID']?.isNotEmpty == 0 ? 'OCAR_APP_ID = ?' : 'OCAR_Id = ?';
            values.add(data[whereClause.contains('APP') ? 'OCAR_APP_ID' : 'OCAR_Id']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'OC_Pagam':
            whereClause = 'OCPG_OCAN_ID = ?';
            values.add(data['OCPG_OCAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'FT_Anagr':
            whereClause = 'FTAN_ID = ?';
            values.add(data['FTAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'FT_Artic':
            whereClause = 'FTAR_ID = ?';
            values.add(data['FTAR_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'FT_Pagam':
            whereClause = 'FTPG_FTAN_ID = ?';
            values.add(data['FTPG_FTAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'BL_Anag':
            whereClause = 'BLAN_ID = ?';
            values.add(data['BLAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'BL_Artic':
            whereClause = 'BLAR_ID = ?';
            values.add(data['BLAR_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'BL_Pagam':
            whereClause = 'BLPG_BLAN_ID = ?';
            values.add(data['BLPG_BLAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          default:
            throw Exception('Tabella non supportata per PROC: $tableName');
        }

        if (exists) {
          String setClause = data.keys.map((key) => "$key = ?").join(", ");
          List<dynamic> updateValues = data.values.toList() + values;
          query = "UPDATE $tableName SET $setClause WHERE $whereClause";
          return await DatabaseHelper().rawUpd(query, updateValues);
        } else {
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

  @override
  void onClose() {
    socket?.disconnect();
    super.onClose();
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }
}
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../models/messaggio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/testataordine.dart';
import '../models/righeOrdine.dart';

class WebSocketController extends GetxController {
  static IO.Socket? socket;
  static RxBool isConnected = false.obs;
  RxString indirizzoServer = ''.obs;
  List<Messaggio> messages = [];
  final Rx<Map<String, dynamic>> backgroundSyncResult = Rx({});

  @override
  void onInit() {
    super.onInit();
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
          'autoConnect': false,
          'reconnection': true
        });
        await _listenForEvents();
        await Future.delayed(const Duration(milliseconds: 500));
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

  Future<void> _checkPendingSyncs() async {
    debugPrint('Controllo ordini con sincronizzazione in sospeso...');
    final pendingOrders = await DatabaseHelper().getPendingSyncOrders();
    if (pendingOrders.isEmpty) {
      debugPrint('Nessun ordine in sospeso trovato.');
      return;
    }

    debugPrint('Trovati ${pendingOrders.length} ordini in sospeso. Chiedo lo stato al server...');
    for (final order in pendingOrders) {
      if (order.ocanAppId != null) {
        socket!.emit('sync_check', {'ocanAppId': order.ocanAppId});
      }
    }
  }
  
  Future<void> _resendFullOrder(String ocanAppId) async {
      debugPrint('Il server non ha trovato l\'ordine $ocanAppId. Lo reinvio...');
      final fullOrderData = await DatabaseHelper().getFullOrderByAppId(ocanAppId);

      if (fullOrderData.isEmpty) {
          debugPrint('ERRORE CRITICO: Impossibile trovare l\'ordine $ocanAppId nel DB locale per il reinvio.');
          return;
      }
      
      final testata = TestataOrdine.fromJson(fullOrderData['header']);
      final righe = (fullOrderData['lines'] as List).map((r) => RigaOrdine.fromJson(r)).toList();

      Map<String, dynamic> fullOrderMessage = {
          "QUERY": "INSERT_FULL_ORDER",
          "DATA": {
              "header": testata.toJson(),
              "lines": righe.map((r) => r.toJson()).toList(),
          }
      };

      sendMessage(Messaggio(
          metsMessage: jsonEncode(fullOrderMessage),
          metsDataSave: 'diretto',
      ));
  }

  Future<void> _listenForEvents() async {
    if (socket == null) {
      debugPrint('Socket non è inizializzato.');
      return;
    }

    socket!.on('connect', (_) async {
      isConnected.value = true;
      update();
      debugPrint('Connessione riuscita: ${socket!.id}');
      socket!.emit('sendIMEI', await DatabaseHelper().getIMEI());
      
      await _checkPendingSyncs();
      
      await sendPendingMessages();
    });

    socket!.on('disconnect', (_) async {
      debugPrint('Disconnesso dal server');
      isConnected.value = false;
    });

    socket!.on('connect_error', (data) {
      debugPrint('Errore di connessione: $data');
    });

    socket!.on('sync_check_response', (data) async {
        final String ocanAppId = data['ocanAppId'];
        final String status = data['status'];

        if (status == 'not_found') {
            await _resendFullOrder(ocanAppId);
        } else {
            debugPrint('Risposta sync_check per $ocanAppId non gestita: $status');
        }
    });

    socket!.on('updateFromYes', (data) async {
      debugPrint("Dati ricevuti dal server: $data");
      int result = await execMessage(jsonDecode(data["messaggio"]));
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
  }
  
  static Future<String> disconnectSocket() async {
    try {
      if (socket != null && socket!.connected) {
        socket!.disconnect();
        debugPrint('Disconnessione eseguita: ${socket!.connected}');
        return 'Disconnessione eseguita';
      }
      return 'Socket non connesso.';
    } catch (e) {
      return 'Errore durante la disconnessione: $e';
    }
  }

  Future<int> sendMessage(Messaggio message) async {
  Completer<int> completer = Completer();
  final connectivityResult = await (Connectivity().checkConnectivity());
  bool connected = connectivityResult.contains(ConnectivityResult.mobile) ||
      connectivityResult.contains(ConnectivityResult.wifi);

  if (isConnected.value && connected) {
    debugPrint('Invio messaggio al server...');
    socket!.emit('messaggio', message.toJson());

    void onResponse(data) async {
      socket!.off('messaggio_risposta', onResponse);
      if (!completer.isCompleted) {
        if (data["success"]) {
          var decodedMessage = jsonDecode(message.metsMessage!);
          String messageType = "sconosciuta";
          if (decodedMessage is Map && decodedMessage.containsKey('QUERY')) {
            messageType = decodedMessage['QUERY'] == 'INSERT_FULL_ORDER' ? 'ordine' : 'pagamento';
          }

          // <<< MODIFICA CHIAVE >>>
          // Attiva il listener della UI anche per le risposte immediate.
          backgroundSyncResult.value = {
            'type': messageType,
            'success': true,
            'message': '${messageType == 'ordine' ? 'Ordine' : 'Pagamento'} inviato con successo.'
          };

          if (data["permanentIds"] != null) {
            final ids = data["permanentIds"];
            final String ocanAppId = ids["ocanAppId"];
            final int permanentOcanId = ids["permanentOcanId"];
            final Map<String, int> ocarIdMapping = Map<String, int>.from(ids["ocarIdMapping"]);
            debugPrint('Ricevuta conferma e mappatura ID per ordine $ocanAppId.');
            await DatabaseHelper().updateOrderAsSynced(ocanAppId, permanentOcanId, ocarIdMapping);
            completer.complete(permanentOcanId);
          } else {
            completer.complete(1); 
          }
        } else {
          debugPrint('Il server ha risposto con un errore: ${data["error"]}');
          completer.complete(-1);
        }
      }
    }

    socket!.on('messaggio_risposta', onResponse);
  } else {
    debugPrint('Connessione assente. Messaggio salvato in coda locale.');
    saveMessageLocally(message);
    // Notifica l'utente che l'operazione è stata salvata offline
    backgroundSyncResult.value = {
      'type': 'offline_save',
      'success': true, // L'azione di salvataggio è riuscita
      'message': 'Operazione salvata. Verrà inviata appena tornerai online.'
    };
    completer.complete(-1);
  }
  return completer.future;
}

  Future<void> saveMessageLocally(Messaggio message) async {
    try {
      await DatabaseHelper().saveMessage(message);
    } catch (e) {
      debugPrint('errore salvataggio messaggio locale: $e');
    }
  }

  Future<int> sendPendingMessages() async {
    messages = await DatabaseHelper().getMessages();
    if (messages.isEmpty) {
      debugPrint("Nessun messaggio in coda da inviare.");
      return 1;
    }
    debugPrint("Trovati ${messages.length} messaggi in coda. Inizio invio...");

    // Itera su una copia della lista per evitare problemi di concorrenza
    for (Messaggio message in List.of(messages)) {
      try {
        final messageContent = message.metsMessage;
        if (messageContent == null || messageContent.isEmpty) {
          debugPrint('Messaggio pendente con contenuto nullo o vuoto (METS_ID: ${message.metsId}). Lo salto.');
          continue;
        }

        // Invia il messaggio
        int result = await sendMessage(message);

        // Se l'invio ha successo (non è -1), rimuovi il messaggio dalla coda locale
        if (result != -1) {
          await DatabaseHelper().deleteMessage(message.metsId!);
          debugPrint("Messaggio in coda (METS_ID: ${message.metsId}) inviato con successo e rimosso dalla coda.");
          
          // Notifica l'utente tramite il listener
          var decodedMessage = jsonDecode(messageContent);
          String messageType = decodedMessage['QUERY'] == 'INSERT_FULL_ORDER' ? 'order' : 'payment';
          
          backgroundSyncResult.value = {
            'type': messageType,
            'success': true,
            'message': '${messageType == 'order' ? 'Ordine' : 'Pagamento'} in coda inviato con successo.'
          };
        } else {
          // L'invio è fallito (probabilmente siamo tornati offline),
          // lascia il messaggio in coda e interrompi il ciclo per questa sessione.
          debugPrint("Invio messaggio in coda (METS_ID: ${message.metsId}) fallito. Rimane in coda. Interrompo invio di massa.");
          break;
        }
      } catch (e) {
        debugPrint('Errore durante l\'elaborazione del messaggio in coda (METS_ID: ${message.metsId}): $e');
        continue;
      }
    }
    return 1;
  }

  Future<int> execMessage(Map<String, dynamic> oggetto) async {
    // ... (il corpo di execMessage rimane invariato)
    debugPrint(oggetto['TABLE']);
    String query = '';
    String tableName = oggetto['TABLE'];
    Map<String, dynamic> data = oggetto['DATA'];
    String whereClause = '';
    List<dynamic> values = [];
    switch (oggetto['QUERY']) {
      case 'UPDATE':
        String setClause = data.keys.map((key) => "$key = ?").join(", ");
        values = data.values.toList();
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

      case 'INSERT':
        data = data.map((key, value) => MapEntry(
            key, (key == "ZPTV_MBPC_ID" && value == "0") ? null : value));
        String columns = data.keys.join(", ");
        String valueHolders = data.keys.map((_) => "?").join(", ");
        values = data.values.toList();
        query =
            "INSERT OR IGNORE INTO $tableName ($columns) VALUES ($valueHolders)";
        int res = await DatabaseHelper().rawIns(query, values);
        try {
          return res;
        } catch (e) {
          debugPrint('Errore durante l\'inserimento nel database: $e');
          return res;
        }

      case 'DELETE':
        whereClause = '';
        values = [];
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
              whereClause = 'OCAR_Id=?';
              values.add(data['OCAR_Id']);
            } else {
              whereClause = 'OCAR_APP_ID=?';
              values.add(data['OCAR_APP_ID']);
            }
            break;
          case 'OC_Anag':
            if (data['OCAN_APP_ID'] == null || data['OCAN_APP_ID'].isEmpty) {
              whereClause = 'OCAN_ID=?';
              values.add(data['OCAN_ID']);
            } else {
              whereClause = 'OCAN_APP_ID=?';
              values.add(data['OCAN_APP_ID']);
            }
            await DatabaseHelper().rawDelete('DELETE FROM OC_ARTIC WHERE OCAR_OCAN_ID=?', [data['OCAN_ID']]);
            await DatabaseHelper().rawDelete('DELETE FROM OC_Pagam WHERE OCPG_OCAN_ID=?', [data['OCAN_ID']]);
            break;
          case 'FT_Anagr':
            whereClause = 'FTAN_ID=?';
            values.add(data['FTAN_ID']);
            await DatabaseHelper().rawDelete('DELETE FROM FT_Pagam WHERE FTPG_FTAN_ID=?', values);
            await DatabaseHelper().rawDelete('DELETE FROM FT_Artic WHERE FTAR_FTAN_ID=?', values);
            break;
          case 'BL_Anag':
            whereClause = 'BLAN_ID=?';
            values.add(data['BLAN_ID']);
            await DatabaseHelper().rawDelete('DELETE FROM BL_Pagam WHERE BLPG_BLAN_ID=?', values);
            await DatabaseHelper().rawDelete('DELETE FROM BL_Artic WHERE BLAR_BLAN_ID=?', values);
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

      case 'PROC':
        bool exists = false;
        switch (tableName) {
          case 'OC_Anag':
            whereClause = data['OCAN_APP_ID'] == 0 ? 'OCAN_APP_ID = ?' : 'OCAN_ID = ?';
            values.add(data[whereClause.contains('APP') ? 'OCAN_APP_ID' : 'OCAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            debugPrint('Esiste una riga con questa chiave: $exists');
            break;
          case 'OC_Artic':
            whereClause = data['OCAR_APP_ID']?.isNotEmpty == 0 ? 'OCAR_APP_ID = ?' : 'OCAR_Id = ?';
            values.add(data[whereClause.contains('APP') ? 'OCAR_APP_ID' : 'OCAR_Id']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'OC_Pagam':
            whereClause = 'OCPG_OCAN_ID = ?';
            values.add(data['OCPG_OCAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'FT_Anagr':
            whereClause = 'FTAN_ID = ?';
            values.add(data['FTAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'FT_Artic':
            whereClause = 'FTAR_ID = ?';
            values.add(data['FTAR_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'FT_Pagam':
            whereClause = 'FTPG_FTAN_ID = ?';
            values.add(data['FTPG_FTAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'BL_Anag':
            whereClause = 'BLAN_ID = ?';
            values.add(data['BLAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'BL_Artic':
            whereClause = 'BLAR_ID = ?';
            values.add(data['BLAR_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          case 'BL_Pagam':
            whereClause = 'BLPG_BLAN_ID = ?';
            values.add(data['BLPG_BLAN_ID']);
            exists = await DatabaseHelper().recordExists(tableName, whereClause, values);
            break;
          default:
            throw Exception('Tabella non supportata per PROC: $tableName');
        }

        if (exists) {
          String setClause = data.keys.map((key) => "$key = ?").join(", ");
          List<dynamic> updateValues = data.values.toList() + values;
          query = "UPDATE $tableName SET $setClause WHERE $whereClause";
          return await DatabaseHelper().rawUpd(query, updateValues);
        } else {
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

  @override
  void onClose() {
    socket?.disconnect();
    super.onClose();
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }
}

