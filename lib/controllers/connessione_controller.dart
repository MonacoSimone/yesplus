import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:yesplus/models/destinatari.dart';
import '../models/zprezzitv.dart';
import '../models/sconto.dart';
import '../models/tipoArticolo.dart';
import '../models/tipoconto.dart';
import '../controllers/controller_soket.dart';
import '../models/agenti.dart';
import '../models/anagrafica.dart';
import '../models/catalogo.dart';
import '../models/iva.dart';
import '../models/pagamenti.dart';
import '../models/partita.dart';
import '../models/righeOrdine.dart';
import '../models/righebolla.dart';
import '../models/rigafattura.dart';
import '../models/testatabolle.dart';
import '../models/testatafattura.dart';
import '../models/testataordine.dart';
import '../models/tipobolla.dart';
import '../models/tipofattura.dart';
import '../models/tipoordine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/db_helper.dart';
import 'package:dio/dio.dart' as dio;

class ConnessioneController extends GetxController {
  //final TextEditingController indirizzoServer = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final tables = [
    'Clienti',
    'Partite',
    'Ordini',
    'Fatture',
    'Bolle 1',
    'Bolle 2',
    'Articoli',
    'PrezziTV',
    'Destinazioni',
    'Tipi Ordine',
    'Tipi Fattura',
    'Tipi Bolla',
    'Agenti' /*,
    'Tipi Iva',
    ' Tipi Pagamento',
    'Sol. Pagamento',
    'Tipi Conto'*/
  ].obs;
  final selectedTable = 'Clienti'.obs;
  Future<void> executeAction() async {
    // Perform actions with selectedTable.value
    print('Selected table: ${selectedTable.value}');
    int idAge = await DatabaseHelper().getIdAgente();
    int tipoConto = await DatabaseHelper().getIdTipoConto();
    switch (selectedTable.value) {
      case 'Clienti':
        // Code to execute for 'Clienti'
        stato.add('Cancello Anagrafiche Clienti: '.obs);
        await DatabaseHelper().clearMB_Anagr();
        stato.add('Recupero Anagrafiche Clienti: '.obs);
        await initMB_Anag(idAge, tipoConto);
        print('Performing action for Clienti');
        break;

      case 'Destinazioni':
        stato.add('Cancello Destinazioni Clienti: '.obs);
        await DatabaseHelper().clearMB_CliForDest();
        stato.add('Recupero Destinazioni clienti: '.obs);
        await initMBCliForDest(idAge, tipoConto);
        break;
      case 'Partite':
        // Code to execute for 'Partite'
        stato.add('Cancello Partite '.obs);
        await DatabaseHelper().clearCA_Partite();

        stato.add('Recupero Partite: '.obs);
        await initCA_Partite(idAge, tipoConto);
        print('Performing action for Partite');
        break;
      case 'Ordini':
        // Code to execute for 'Ordini'

        int ocTipo = await DatabaseHelper().getTipoOrdine();
        stato.add('Cancello Testate Ordini '.obs);
        await DatabaseHelper().clearOC_Anag();
        stato.add('Cancello Righe Ordini '.obs);
        await DatabaseHelper().clearOC_Artic();
        stato.add('Cancello Pagamenti Ordini '.obs);
        await DatabaseHelper().clearOC_Pagam();
        stato.add('Recupero Testate Ordini: '.obs);
        await initOC_Anagr(ocTipo, tipoConto);
        stato.add('Recupero Righe Ordini: '.obs);
        await initOC_Arti(ocTipo, tipoConto);
        stato.add('Recupero Pagamenti Ordini: '.obs);
        await initOCPagam(idAge, tipoConto);
        print('Performing action for Ordini');
        break;
      case 'Fatture':
        // Code to execute for 'Fatture'
        int ftTipo = await DatabaseHelper().getTipoFattura();
        stato.add('Cancello Testate Fatture '.obs);
        await DatabaseHelper().clearFT_Anagr();
        stato.add('Cancello Righe Fatture '.obs);
        await DatabaseHelper().clearFT_Artic();
        stato.add('Cancello Pagamenti Fatture '.obs);
        await DatabaseHelper().clearFT_Pagam();
        stato.add('Recupero Testate Fatture: '.obs);
        await initFT_Anagr(idAge, tipoConto);
        stato.add('Recupero Righe Fatture: '.obs);
        await initFT_Artic(idAge, tipoConto);
        stato.add('Recupero Pagamenti Fatture: '.obs);
        await initFTPagam(idAge, tipoConto);
        print('Performing action for Fatture');
        break;
      case 'Bolle':
        // Code to execute for 'Bolle 1'
        int blTipo1 = await DatabaseHelper().getTipoBolla1();
        stato.add('Cancello Testate Bolle '.obs);
        await DatabaseHelper().clearBL_Anag();
        stato.add('Cancello Righe Bolle '.obs);
        await DatabaseHelper().clearBL_Artic();
        stato.add('Cancello Pagamenti Bolle '.obs);
        await DatabaseHelper().clearBL_Pagam();
        stato.add('Recupero Testate Bolle Tipo 1: '.obs);
        await initBL_Anagr(blTipo1, tipoConto);
        stato.add('Recupero Righe Bolle Tipo 1: '.obs);
        await initBL_Artic(blTipo1, tipoConto);
        stato.add('Recupero Pagamenti Bolle Tipo 1: '.obs);
        await initBLPagam(idAge, tipoConto);
        print('Performing action for Bolle 1');
        // Code to execute for 'Bolle 2'
        int blTipo2 = await DatabaseHelper().getTipoBolla2();
        stato.add('Recupero Testate Bolle Tipo 2: '.obs);
        await initBL_Anagr(blTipo2, tipoConto);
        stato.add('Recupero Righe Bolle Tipo 2: '.obs);
        await initBL_Artic(blTipo2, tipoConto);
        stato.add('Recupero Pagamenti Bolle Tipo 2: '.obs);
        await initBLPagam(idAge, tipoConto);
        print('Performing action for Bolle 2');
        break;
      case 'Articoli':
        // Code to execute for 'Articoli'
        stato.add('Cancello Articoli '.obs);
        await DatabaseHelper().clearMG_Artic();
        stato.add('Recupero Anagrafiche Articoli: '.obs);
        await initMG_AnaArt();
        print('Performing action for Articoli');
        break;
      case 'PrezziTV':
        // Code to execute for 'PrezziTV'
        stato.add('Cancello PrezziTV '.obs);
        await DatabaseHelper().clearZprezziTv();
        stato.add('Recuperto Prezzi Articoli'.obs);
        await initZprezziTv();
        print('Performing action for PrezziTV');
        break;
      case 'Tipi Ordine':
        // Code to execute for 'Tipi Ordine'
        await DatabaseHelper().clearOC_Tipo();
        stato.add('Recupero Tipi Ordine: '.obs);
        await initOC_Tipo();
        print('Performing action for Tipi Ordine');
        break;
      case 'Tipi Fattura':
        // Code to execute for 'Tipi Fattura'
        await DatabaseHelper().clearFT_Tipo();
        stato.add('Recupero Tipi Fattura: '.obs);
        await initFT_Tipo();
        print('Performing action for Tipi Fattura');
        break;
      case 'Tipi Bolla':
        // Code to execute for 'Tipi Bolla'
        await DatabaseHelper().clearFT_Tipo();
        stato.add('Recupero Tipi Bolla: '.obs);
        await initBL_Tipo();
        print('Performing action for Tipi Bolla');
        break;
      case 'Agenti':
        // Code to execute for 'Agenti'
        await DatabaseHelper().clearAgenti();
        stato.add('Recupero Agenti: '.obs);
        await initMBage();
        print('Performing action for Agenti');
        break;
      case 'Tipi Iva':
        // Code to execute for 'Tipi Iva'
        stato.add('Recupero Tipi Iva'.obs);
        await initMBiva();
        print('Performing action for Tipi Iva');
        break;
      case 'Tipi Pagamento':
        // Code to execute for 'Tipi Pagamento'
        stato.add('Recupero Tipi Pagemnto'.obs);
        await initMBTipoPag();
        print('Performing action for Tipi Pagamento');
        break;
      case 'Sol. Pagamento':
        // Code to execute for 'Sol. Pagamento'
        stato.add('Recupero Soluzioni Pagamento'.obs);
        await initMBSolPag();
        print('Performing action for Sol. Pagamento');
        break;
      case 'Tipi Conto':
        stato.add('Recupero Tipi Conto'.obs);
        await initTipoConto();
        // Code to execute for 'Tipi Conto'
        print('Performing action for Tipi Conto');
        break;
      default:
        print('Invalid table name');
    }
  }

  var logger = Logger();
  RxString indirizzo = ''.obs;
  RxString status = ''.obs;
  RxString ipAddressApi = ''.obs;
  RxString ipAddressWsc = ''.obs;
  bool getPermission = false;
  String message = "Per piacere concedi i permessi.";
  RxList<RxString> stato = <RxString>[].obs;

  RxInt contMBAN = 1.obs;
  RxInt contMBAG = 1.obs;
  RxInt contCAPA = 1.obs;
  RxInt contBLTI = 1.obs;
  RxInt contFTTI = 1.obs;
  RxInt contOCTI = 1.obs;
  RxInt contFTAN = 1.obs;
  RxInt contFTAR = 1.obs;
  RxInt contOCAN = 1.obs;
  RxInt contOCAR = 1.obs;
  RxInt contBLAN = 1.obs;
  RxInt contBLAR = 1.obs;
  RxInt contMGAA = 1.obs;
  RxInt contMBIV = 1.obs;
  RxInt contMBTP = 1.obs;
  RxInt contMBSP = 1.obs;
  RxInt contBLPG = 1.obs;
  RxInt contOCPG = 1.obs;
  RxInt contFTPG = 1.obs;
  RxInt contMBTC = 1.obs;
  RxInt contMBTA = 1.obs;
  RxInt contCFDT = 1.obs;
  RxInt contSconti = 1.obs;
  RxInt contZprezzi = 1.obs;
  RxString connesione = 'Connetti'.obs;
  RxString controlloPermessi = 'Controllo dei permessi. '.obs;
  RxString statoConnessione = 'In attesa di conessione al server: '.obs;
  RxString statoDatabase = 'Inizzializzo il Database. '.obs;
  RxString statoMBAN = 'Inizzializzo Anagrafiche: '.obs;
  int batchSize = 100;
  int batchSize2 = 130;
  int batchSize3 = 150;
  int batchSize4 = 200;
  int OCTI_ID = 0;
  int FTTI_ID = 0;
  int BLTI_ID1 = 0;
  int BLTI_ID2 = 0;
  WebSocketController wsc = WebSocketController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    getServerAddressApi();
    getServerAddressWsk();
  }

  Future<void> getServerAddressApi() async {
    ipAddressApi.value = await DatabaseHelper().getServerAPI();
    //statoConnessione.value = '${statoConnessione.value}${ipAddressApi.value}';
  }

  Future<void> getServerAddressWsk() async {
    ipAddressWsc.value = await DatabaseHelper().getServerWSK();
    statoConnessione.value = '${statoConnessione.value}${ipAddressWsc.value}';
  }

  void scrollToEnd() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /*  getServerAddress() async {
    indirizzoServer.text = await wsc.getServerAddress();
  } */

  Future<void> connectToServer() async {
    //final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    //AndroidDeviceInfo _deviceData;
    stato.add(controlloPermessi);
    String imei;
    //var permission = await Permission.phone.status;

    /* socket = socket_io.io(indirizzoServer.value.text, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    }); */
    imei = await DatabaseHelper().getIMEI();
    stato.add('Imei: $imei'.obs);
    if (imei.isEmpty) {
      stato.add('Codice Univoco non trovato'.obs);
      /* debugPrint('Permesso per l\'accesso al telefono: $permission');
      if (permission.isGranted) {
        _deviceData = await deviceInfoPlugin.androidInfo;
        imei = _deviceData.id; //await DeviceInformation.deviceIMEINumber;;
        await DatabaseHelper().saveIMEI(imei.replaceAll(".", ""));
        getPermission = true;
      } else {
        debugPrint('Non ho i permessi per l\'accesso al telefono.');
        PermissionStatus status = await Permission.phone.request();
        if (status == PermissionStatus.granted) {
          getPermission = false;
          controlloPermessi.value = '${controlloPermessi.value} OK!';
          stato.add('Recupero imei del disositivo'.obs);
          _deviceData = await deviceInfoPlugin.androidInfo;
          imei = _deviceData.id; //await DeviceInformation.deviceIMEINumber;
          await DatabaseHelper().saveIMEI(imei.replaceAll(".", ""));
          stato.add('Imei salvato: $imei'.obs);
        } else {
          getPermission = false;
          controlloPermessi.value =
              "${controlloPermessi.value} Non ci sono i permessi necessari.";
        }
      } */
    } else {
      stato.add(statoConnessione);
      //socket.connect();
      try {
        await wsc.connectToWebSocket();
        stato.add('Connesso'.obs);
        update();
      } catch (e) {
        statoConnessione.value = '${statoConnessione.value}$e';
      }
    }

    /*  wsc.socket!.on('initDB', (_) async {
      stato.add(statoDatabase);
      await initDB1();
      statoDatabase.value = '${statoDatabase.value}Fatto!';
    }); */

    //wsc.socket!.emit('sendIMEI', await DatabaseHelper().getIMEI());
  }

  /*ANAGRAFICHE*/
  Future<void> initMB_Anag() async {
    contMBAN = 0.obs;
    List<Cliente> batch = [];
    var dioClient = dio.Dio();

    try {
      // Get IMEI and password
      final credentials = await DatabaseHelper().getIMEIAndPassword();
      final String imei = credentials['imei'] ?? '';
      final String password = credentials['password'] ?? '';

      if (imei.isEmpty) {
        debugPrint('Errore: Codice Univoco non impostato');
        stato.add('Errore: Codice Univoco non impostato'.obs);
        return;
      }

      // Get timestamp from the appropriate getMax function for MB_Anagr table
      final int timestamp = await DatabaseHelper().getMaxMBANLastEditDate();

      // Build the new API URL with IMEI, password, and timestamp
      var url =
          '${ipAddressApi.value}/initdbclient/mbanag/$imei/$password/$timestamp';

      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var cliente = Cliente.fromJson(jsonData);
            batch.add(cliente);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initDbAnagClientiBatch(batch);
              contMBAN.value = contMBAN.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
            // Fai qualcosa con l'oggetto Cliente
          } catch (e) {
            debugPrint('Errore di parsing JSON: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbAnagClientiBatch(batch);
        contMBAN.value = contMBAN.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata MBAN');
    } catch (e) {
      debugPrint('Errore durante la richiesta: $e');
    }
  }

  /*DESTINAZIONE ANAGRAFICHE */
  Future<void> initMBCliForDest() async {
    contCFDT = 0.obs;
    List<MbCliForDest> batch = [];
    var dioClient = dio.Dio();

    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp for MB_CliForDest table
    final timestamp = await DatabaseHelper().getMaxMBDTLastEditDate();

    var url =
        '${ipAddressApi.value}/initdbclient/mbclifordest/$imei/$password/$timestamp';
    print(url);

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var dest = MbCliForDest.fromJson(jsonData);
            batch.add(dest);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initDbMBCliForDestBatch(batch);
              contCFDT.value = contCFDT.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON: $e');
          }
        }
      }

      if (batch.isNotEmpty) {
        String controllo =
            await DatabaseHelper().initDbMBCliForDestBatch(batch);
        contCFDT.value = contCFDT.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }

      debugPrint('Elaborazione completata MBDT');
    } catch (e) {
      debugPrint('Errore durante la richiesta: $e');
    }
  }

  /*SCONTI ANAGRAFICHE */
  Future<void> initSconti() async {
    contSconti = 0.obs;

    // Get IMEI and password from database
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Check if IMEI is valid
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp from database
    final timestamp = await DatabaseHelper().getMaxMBANLastEditDate();

    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/mbanag/sconti/$imei/$password/$timestamp';
    debugPrint(url);

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      List<Sconto> batch = [];
      int batchSize = 100; // Set a batch size as needed

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var sconto = Sconto.fromJson(jsonData);
            batch.add(sconto);

            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().updateDbScontiBatch(batch);
              contSconti.value = contSconti.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
              batch.clear();
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON: $e');
          }
        }
      }

      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().updateDbScontiBatch(batch);
        contSconti.value = contSconti.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }

      debugPrint('Elaborazione completata Sconti');
    } catch (e) {
      debugPrint('Errore durante la richiesta Sconti: $e');
    }
  }

  /*Z_PrezziTv */
  Future<void> initZprezziTv() async {
    contZprezzi = 0.obs;
    var dioClient = dio.Dio();

    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final timestamp = await DatabaseHelper().getMaxZPTVLastEditDate();

    // Construct new URL
    var url =
        '${ipAddressApi.value}/initdbclient/zprezzitv/$imei/$password/$timestamp';
    debugPrint(url);

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      List<PrezziTV> batch = [];
      int batchSize = 100;

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);

            var prezzo = PrezziTV.fromJson(jsonData);
            batch.add(prezzo);

            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initDbPrezziTVBatch(batch);
              contZprezzi.value = contZprezzi.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
              batch.clear();
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON: $e');
          }
        }
      }

      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbPrezziTVBatch(batch);
        contZprezzi.value = contZprezzi.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }

      debugPrint('Elaborazione completata Z Prezzi');
    } catch (e) {
      debugPrint('Errore durante la richiesta Z Prezzi: $e');
    }
  }

  /*ARTICOLI*/
  Future<void> initMG_AnaArt() async {
    contMGAA = 0.obs;
    List<Prodotto> batch = [];
    var dioClient = dio.Dio();

    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Check if IMEI is valid
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final timestamp = await DatabaseHelper().getMaxMGAALastEditDate();

    // Build URL with new format
    var url =
        '${ipAddressApi.value}/initdbclient/mganaart/$imei/$password/$timestamp';
    debugPrint(url);

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var prodotto = Prodotto.fromJson(jsonData);
            batch.add(prodotto);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initDbArticoliBatch(batch);
              contMGAA.value = contMGAA.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbArticoliBatch(batch);
        contMGAA.value = contMGAA.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata MGAA');
    } catch (e) {
      debugPrint('Errore durante la richiesta MGAA: $e');
    }
  }

  /*PARTITE*/
  Future<void> initCA_Partite() async {
    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final timestamp = await DatabaseHelper().getMaxCAPALastEditDate();

    contCAPA = 0.obs;
    List<Partita> batch = [];
    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/capartite/$imei/$password/$timestamp';
    logger.i(url);
    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var partita = Partita.fromJson(jsonData);
            batch.add(partita);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initDbPartiteBatch(batch);
              contCAPA.value = contCAPA.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbPartiteBatch(batch);
        contCAPA.value = contCAPA.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata CAPA');
    } catch (e) {
      debugPrint('Errore durante la richiesta CAPA: $e');
    }
  }

  /*TIPI*/
  Future<void> initTipoConto() async {
    contMBTC = 0.obs;
    List<TipoConto> batch = [];
    var dioClient = dio.Dio();

    // Get IMEI and password from database
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Check if IMEI is valid
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp for this table
    final timestamp = await DatabaseHelper().getMaxMBTCLastEditDate();

    // Build the URL with the new format
    var url =
        '${ipAddressApi.value}/initdbclient/mbtipoconto/$imei/$password/$timestamp';
    logger.i(url);

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var tipoConto = TipoConto.fromJson(jsonData);
            batch.add(tipoConto);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initMBTipoContoBatch(batch);
              contMBTC.value = contMBTC.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initMBTipoContoBatch(batch);
        contMBTC.value = contMBTC.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata MBTC');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBTC: $e');
    }
  }

  Future<void> initMBTipoPag() async {
    contMBTP = 0.obs;
    List<TipoPagamento> batch = [];
    var dioClient = dio.Dio();

    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final timestamp = await DatabaseHelper().getMaxMBTPLastEditDate();

    var url =
        '${ipAddressApi.value}/initdbclient/tipopag/$imei/$password/$timestamp';

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var tipoPag = TipoPagamento.fromJson(jsonData);
            batch.add(tipoPag);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initDbTipoPagBatch(batch);
              contMBTP.value = contMBTP.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbTipoPagBatch(batch);
        contMBTP.value = contMBTP.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata MBTP');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBTP: $e');
    }
  }

  Future<void> initMBTipiArticolo() async {
    contMBTA = 0.obs;
    List<TipoArticolo> batch = [];
    var dioClient = dio.Dio();

    // Get IMEI and password
    Map<String, String?> credentials =
        await DatabaseHelper().getIMEIAndPassword();
    String imei = credentials['imei'] ?? '';
    String password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    int timestamp = await DatabaseHelper().getMaxMBTALastEditDate();

    // Construct new URL
    var url =
        '${ipAddressApi.value}/initdbclient/mbta/$imei/$password/$timestamp';

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var tipoArticolo = TipoArticolo.fromJson(jsonData);
            batch.add(tipoArticolo);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initDbTipoArticoliBatch(batch);
              contMBTA.value = contMBTA.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo =
            await DatabaseHelper().initDbTipoArticoliBatch(batch);
        contMBTA.value = contMBTA.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata MBTA');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBTA: $e');
    }
  }

  Future<void> initMBSolPag() async {
    contMBSP = 0.obs;
    List<SoluzionePagamento> batch = [];

    // Get IMEI and password using the helper function
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Check if IMEI is valid
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp for incremental sync
    final timestamp = await DatabaseHelper().getMaxMBSPLastEditDate();

    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/solpag/$imei/$password/$timestamp';

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var solPag = SoluzionePagamento.fromJson(jsonData);
            batch.add(solPag);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initDbSolPagBatch(batch);
              contMBSP.value = contMBSP.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON: $e');
          }
        }
      }

      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbSolPagBatch(batch);
        contMBSP.value = contMBSP.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }

      debugPrint('Elaborazione completata MBSP');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBSP: $e');
    }
  }

  Future<void> initMBage() async {
    contMBAG = 1.obs;

    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final timestamp = await DatabaseHelper().getMaxMBAGLastEditDate();

    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/mbage/$imei/$password/$timestamp';

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var ag = Agente.fromJson(jsonData);
            String controllo = await DatabaseHelper().initMBAge(ag);
            if (controllo == 'ok') {
              // Success handling if needed
            } else {
              stato[stato.length - 1] = controllo.obs;
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON MBAG: $e');
          }
        }
      }
      debugPrint('Elaborazione completata MBAG');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBAG: $e');
    }
  }

  Future<void> initMBiva() async {
    contMBIV = 1.obs;

    // Get IMEI and password using the existing method
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final String imei = credentials['imei'] ?? '';
    final String password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp from database
    final int timestamp = await DatabaseHelper().getMaxMBIVLastEditDate();

    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/mbiva/$imei/$password/$timestamp';

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var iva = Iva.fromJson(jsonData);
            String controllo = await DatabaseHelper().initMBIva(iva);
            if (controllo != 'ok') {
              stato[stato.length - 1] = controllo.obs;
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON MBIV: $e');
          }
        }
      }
      debugPrint('Elaborazione completata MBIV');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBIV: $e');
    }
  }

  Future<void> initBL_Tipo() async {
    contBLTI = 1.obs;

    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final timestamp = await DatabaseHelper().getMaxBLTILastEditDate();

    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/bltipo/$imei/$password/$timestamp';

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var tipoBolla = TipoBolla.fromJson(jsonData);
            String controllo = await DatabaseHelper().initBLTipo(tipoBolla);
            if (controllo != 'ok') {
              stato[stato.length - 1] = controllo.obs;
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON BLTI: $e');
          }
        }
      }
      debugPrint('Elaborazione completata BLTI');
    } catch (e) {
      debugPrint('Errore durante la richiesta BLTI: $e');
    }
  }

  Future<void> initFT_Tipo() async {
    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Check if IMEI is valid
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final timestamp = await DatabaseHelper().getMaxFTTILastEditDate();

    contFTTI = 1.obs;

    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/fttipo/$imei/$password/$timestamp';
    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var tipoFattura = TipoFattura.fromJson(jsonData);
            String controllo = await DatabaseHelper().initFTTipo(tipoFattura);
            if (controllo == 'ok') {
            } else {
              stato[stato.length - 1] = controllo.obs;
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON FTTI: $e');
          }
        }
      }
      debugPrint('Elaborazione completata FTTI');
    } catch (e) {
      debugPrint('Errore durante la richiesta FTTI: $e');
    }
  }

  Future<void> initOC_Tipo() async {
    contOCTI = 1.obs;

    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final timestamp = await DatabaseHelper().getMaxOCTILastEditDate();

    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/octipo/$imei/$password/$timestamp';

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var tipoOrdine = TipoOrdine.fromJson(jsonData);
            String controllo = await DatabaseHelper().initOCTipo(tipoOrdine);
            if (controllo != 'ok') {
              stato[stato.length - 1] = controllo.obs;
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON OCTI: $e');
          }
        }
      }
      debugPrint('Elaborazione completata OCTI');
    } catch (e) {
      debugPrint('Errore durante la richiesta OCTI: $e');
    }
  }

  /*ORDINI*/
  Future<void> initOCPagam() async {
    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final timestamp = await DatabaseHelper().getMaxOCPGLastEditDate();

    List<PagamentoOrdine> batch = [];
    contOCPG = 0.obs;
    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/ocpagam/$imei/$password/$timestamp';
    logger.i(url);
    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var pagamentoOrdine = PagamentoOrdine.fromJson(jsonData);
            batch.add(pagamentoOrdine);
            if (batch.length >= batchSize2) {
              String controllo =
                  await DatabaseHelper().initDbOCPagametiBatch(batch);
              contOCPG.value = contOCPG.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON OCPG: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbOCPagametiBatch(batch);
        contOCPG.value = contOCPG.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata OCPG');
    } catch (e) {
      debugPrint('Errore durante la richiesta OCPG: $e');
    }
  }

  Future<void> initOC_Anagr() async {
    /*RICHIESTA TESTATE ORDINI */
    List<TestataOrdine> batch = [];
    contOCAN = 0.obs;

    // Get IMEI and password from database
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp for incremental sync
    final timestamp = await DatabaseHelper().getMaxOCANLastEditDate();

    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/ocanag/$imei/$password/$timestamp';
    logger.i(url);

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var testataOrdine = TestataOrdine.fromJson(jsonData);
            batch.add(testataOrdine);
            if (batch.length >= batchSize2) {
              String controllo =
                  await DatabaseHelper().initTestataOrdiniBatch(batch);
              contOCAN.value = contOCAN.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON OCAN: $e');
          }
        }
      }

      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initTestataOrdiniBatch(batch);
        contOCAN.value = contOCAN.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }

      debugPrint('Elaborazione completata OCAN');
    } catch (e) {
      debugPrint('Errore durante la richiesta OCAN: $e');
    }
  }

  Future<void> initOC_Arti() async {
    List<RigaOrdine> batch = [];
    contOCAR = 0.obs;

    // Get IMEI and password from database
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final String imei = credentials['imei'] ?? '';
    final String password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp for incremental sync
    final int timestamp = await DatabaseHelper().getMaxOCARLastEditDate();

    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/ocartic/$imei/$password/$timestamp';
    logger.i(url);

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var rigaOrdine = RigaOrdine.fromJson(jsonData);
            batch.add(rigaOrdine);
            if (batch.length >= batchSize3) {
              String controllo =
                  await DatabaseHelper().initRigheOrdineBatch(batch);
              contOCAR.value = contOCAR.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON OCAR: $e');
          }
        }
      }

      // Insert any remaining items in the batch
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initRigheOrdineBatch(batch);
        contOCAR.value = contOCAR.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }

      debugPrint('Elaborazione completata OCAR');
    } catch (e) {
      debugPrint('Errore durante la richiesta OCAR: $e');
    }
  }

  /*FATTURE*/
  Future<void> initFTPagam() async {
    /*RICHIESTA TESTATE FATTURE */

    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final timestamp = await DatabaseHelper().getMaxFTPGLastEditDate();

    List<PagamentoFattura> batch = [];
    contFTPG = 0.obs;
    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/ftpagam/$imei/$password/$timestamp';
    logger.i(url);
    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var pagamentoFattura = PagamentoFattura.fromJson(jsonData);
            batch.add(pagamentoFattura);
            if (batch.length >= batchSize4) {
              String controllo =
                  await DatabaseHelper().initDbFTPagametiBatch(batch);
              contFTPG.value = contFTPG.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON FTPG: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbFTPagametiBatch(batch);
        contFTPG.value = contFTPG.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata FTPG');
    } catch (e) {
      debugPrint('Errore durante la richiesta FTPG: $e');
    }
  }

  Future<void> initFT_Anagr() async {
    List<TestataFattura> batch = [];
    contFTAN = 0.obs;
    var dioClient = dio.Dio();

    // Get IMEI and password
    Map<String, String?> credentials =
        await DatabaseHelper().getIMEIAndPassword();
    String imei = credentials['imei'] ?? '';
    String password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    int timestamp = await DatabaseHelper().getMaxFTANLastEditDate();

    var url =
        '${ipAddressApi.value}/initdbclient/ftanagr/$imei/$password/$timestamp';
    logger.i(url);

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var testataFattura = TestataFattura.fromJson(jsonData);
            batch.add(testataFattura);
            if (batch.length >= batchSize4) {
              String controllo =
                  await DatabaseHelper().initTestataFatturaBatch(batch);
              contFTAN.value = contFTAN.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON FTAN: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo =
            await DatabaseHelper().initTestataFatturaBatch(batch);
        contFTAN.value = contFTAN.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata FTAN');
    } catch (e) {
      debugPrint('Errore durante la richiesta FTAN: $e');
    }
  }

  Future<void> initFT_Artic() async {
    /*RICHIESTA RIGHE FATTURE */

    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final String imei = credentials['imei'] ?? '';
    final String password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final int timestamp = await DatabaseHelper().getMaxFTARLastEditDate();

    List<RigaFattura> batch = [];
    contFTAR = 0.obs;
    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/ftartic/$imei/$password/$timestamp';
    logger.i(url);
    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var rigaFattura = RigaFattura.fromJson(jsonData);
            batch.add(rigaFattura);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initRigaFatturaBatch(batch);
              contFTAR.value = contFTAR.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON FTAR: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initRigaFatturaBatch(batch);
        contFTAR.value = contFTAR.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata FTAR');
    } catch (e) {
      debugPrint('Errore durante la richiesta FTAR: $e');
    }
  }

  /*BOLLE*/
  Future<void> initBLPagam() async {
    contBLPG = 0.obs;
    List<PagamentoBolla> batch = [];

    // Get IMEI and password from database
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Check if IMEI is valid
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp for BL_Pagam table
    final timestamp = await DatabaseHelper().getMaxBLPGLastEditDate();

    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/blpagam/$imei/$password/$timestamp';
    logger.i(url);

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var pagamentoBolla = PagamentoBolla.fromJson(jsonData);
            batch.add(pagamentoBolla);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initDbBlPagamentiBatch(batch);
              contBLPG.value = contBLPG.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON BLPG: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbBlPagamentiBatch(batch);
        contBLPG.value = contBLPG.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata BLPG');
    } catch (e) {
      debugPrint('Errore durante la richiesta BLPG: $e');
    }
  }

  Future<void> initBL_Anagr() async {
    // Get IMEI and password
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final imei = credentials['imei'] ?? '';
    final password = credentials['password'] ?? '';

    // Validate IMEI
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp
    final timestamp = await DatabaseHelper().getMaxBLANLastEditDate();

    contBLAN = 0.obs;
    List<TestataBolla> batch = [];

    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/blanag/$imei/$password/$timestamp';
    logger.i(url);

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var testataBolla = TestataBolla.fromJson(jsonData);
            batch.add(testataBolla);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initTestataBolleBatch(batch);
              contBLAN.value = contBLAN.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON BLAN: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initTestataBolleBatch(batch);
        contBLAN.value = contBLAN.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata BLAN');
    } catch (e) {
      debugPrint('Errore durante la richiesta BLAN: $e');
    }
  }

  Future<void> initBL_Artic() async {
    /*RICHIESTA RIGHE BOLLE */
    contBLAR = 0.obs;
    List<RigaBolla> batch = [];
    var dioClient = dio.Dio();

    // Get IMEI and password using the helper method
    final credentials = await DatabaseHelper().getIMEIAndPassword();
    final String imei = credentials['imei'] ?? '';
    final String password = credentials['password'] ?? '';

    // Check if IMEI is valid
    if (imei.isEmpty) {
      debugPrint('Errore: Codice Univoco non impostato');
      stato.add('Errore: Codice Univoco non impostato'.obs);
      return;
    }

    // Get timestamp from the corresponding getMax function
    final int timestamp = await DatabaseHelper().getMaxBLARLastEditDate();

    var url =
        '${ipAddressApi.value}/initdbclient/blartic/$imei/$password/$timestamp';
    logger.i(url);
    debugPrint(url);

    try {
      dio.Response<dio.ResponseBody> response =
          await dioClient.get<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
        ),
      );

      Stream<String> stream = response.data!.stream
          .transform(StreamTransformer<Uint8List, String>.fromBind((stream) =>
              stream.map((list) => utf8.decode(list, allowMalformed: true))))
          .transform(const LineSplitter());

      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var rigaBolla = RigaBolla.fromJson(jsonData);
            batch.add(rigaBolla);
            if (batch.length >= batchSize) {
              String controllo =
                  await DatabaseHelper().initRigheBolleBatch(batch);
              contBLAR.value = contBLAR.value + batch.length;
              batch.clear();
              if (controllo != 'ok') {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON BLAR: $e');
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initRigheBolleBatch(batch);
        contBLAR.value = contBLAR.value + batch.length;
        batch.clear();
        if (controllo != 'ok') {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata BLAR');
    } catch (e) {
      debugPrint('Errore durante la richiesta BLAR: $e');
    }
  }

  Future<bool> getMBSoc() async {
    try {
      // Get IMEI and password from database
      final credentials = await DatabaseHelper().getIMEIAndPassword();
      final imei = credentials['imei'];
      final password = credentials['password'];

      // Check if IMEI is valid
      if (imei == null || imei.isEmpty) {
        debugPrint('Errore: Codice Univoco non impostato');
        stato.add('Errore: Codice Univoco non impostato'.obs);
        return false;
      }

      var dioClient = dio.Dio();
      final apiUrl = '${ipAddressApi.value}/infoInitDb/mbsoc/$imei/$password';
      final response = await dioClient.get(apiUrl);
      logger.i(apiUrl);

      // Check if response contains valid data
      if (response.data == null) {
        debugPrint('Errore: Codice Univoco o Password non validi');
        stato.add('Errore: Codice Univoco o Password non validi'.obs);
        return false;
      }

      final responseData = jsonDecode(response.toString());
      if (responseData == null || !responseData.containsKey('MBSC_ID')) {
        debugPrint('Errore: Risposta API non valida per MBSOC');
        stato.add('Errore: Risposta API non valida per MBSOC'.obs);
        return false;
      }

      int mbsoc_id = responseData['MBSC_ID'];
      stato.add('MBSOC: $mbsoc_id'.obs);

      try {
        await DatabaseHelper()
            .rawUpd('UPDATE SP_Param SET SPPA_MBSC_ID=?', [mbsoc_id]);
        return true;
      } catch (e) {
        logger.e('Errore durante l\'aggiornamento MBSOC: $e');
        return false;
      }
    } catch (e) {
      logger.e('Errore durante la chiamata API per MBSOC: $e');
      stato.add('Errore durante la chiamata API per MBSOC: $e'.obs);
      return false;
    }
  }

  Future<bool> getMBDiv() async {
    try {
      // Get IMEI and password from database
      final credentials = await DatabaseHelper().getIMEIAndPassword();
      final imei = credentials['imei'];
      final password = credentials['password'];

      // Check if IMEI is valid
      if (imei == null || imei.isEmpty) {
        debugPrint('Errore: Codice Univoco non impostato');
        stato.add('Errore: Codice Univoco non impostato'.obs);
        return false;
      }

      var dioClient = dio.Dio();
      final apiUrl = '${ipAddressApi.value}/infoInitDb/mbdiv/$imei/$password';
      final response = await dioClient.get(apiUrl);
      logger.i(apiUrl);

      // Check if response contains valid data
      if (response.data == null) {
        debugPrint('Errore: Codice Univoco o Password non validi');
        stato.add('Errore: Codice Univoco o Password non validi'.obs);
        return false;
      }

      final responseData = jsonDecode(response.toString());
      if (responseData == null || !responseData.containsKey('MBDV_Id')) {
        debugPrint('Errore: Risposta API non valida per MBDIV');
        stato.add('Errore: Risposta API non valida per MBDIV'.obs);
        return false;
      }

      int mbdiv_id = responseData['MBDV_Id'];
      stato.add('MBDIV: $mbdiv_id'.obs);

      try {
        await DatabaseHelper()
            .rawUpd('UPDATE SP_Param SET SPPA_MBDV_ID=?', [mbdiv_id]);
        return true;
      } catch (e) {
        logger.e('Errore durante l\'aggiornamento MBDIV: $e');
        return false;
      }
    } catch (e) {
      logger.e('Errore durante la chiamata API per MBDIV: $e');
      stato.add('Errore durante la chiamata API per MBDIV: $e'.obs);
      return false;
    }
  }

  void showImei() async {
    var imei = await DatabaseHelper().getIMEI();
    stato.add('IMEI: $imei'.obs);
  }

  Future<int> step1() async {
    var dioClient = dio.Dio();
    try {
      var imei = await DatabaseHelper().getIMEI();
      debugPrint('${ipAddressApi.value}/deviceInitStatus/$imei');
      final response =
          await dioClient.get('${ipAddressApi.value}/deviceInitStatus/$imei');

      int deviceInitStatus =
          jsonDecode(response.toString())['ZAPPD_Init_Status'];
      debugPrint('DeviceInitStatus: $deviceInitStatus');
      return deviceInitStatus;
    } catch (e) {
      debugPrint('Errore durante la richiesta deviceInitStatus: $e');
      return -1;
    }
  }

  Future<int> step2() async {
    var dioClient = dio.Dio();
    try {
      var imei = await DatabaseHelper().getIMEI();
      final response =
          await dioClient.get('${ipAddressApi.value}/deviceInitStatus/$imei');
      int deviceInitStatus =
          jsonDecode(response.toString())['ZAPPD_Init_Status'];
      debugPrint('DeviceInitStatus: $deviceInitStatus');
      return deviceInitStatus;
    } catch (e) {
      debugPrint('Errore durante la richiesta deviceInitStatus: $e');
      return -1;
    }
  }

  Future<void> updateDeviceInitStatus(int deviceInitStatus) async {
    var dioClient = dio.Dio();
    try {
      var imei = await DatabaseHelper().getIMEI();
      final response = await dioClient.get(
          '${ipAddressApi.value}/deviceInitStatus/$imei/$deviceInitStatus');
      ;
      debugPrint('Update DeviceInitStatus: $response');
    } catch (e) {
      debugPrint('Errore durante la richiesta deviceInitStatus: $e');
    }
  }

  Future<void> initDB1() async {
    try {
      stato.add('Recupero Anagrafiche Articoli'.obs);
      await initMG_AnaArt();

      stato.add('Recuperto Prezzi Articoli'.obs);
      await initZprezziTv();

      stato.add('Recupero Tipi Ordine: '.obs);
      await initOC_Tipo();

      stato.add('Recupero Tipi Fattura: '.obs);
      await initFT_Tipo();

      stato.add('Recupero Tipi Bolla: '.obs);
      await initBL_Tipo();

      stato.add('Recupero Agenti: '.obs);
      await initMBage();

      stato.add('Recupero Tipi Iva'.obs);
      await initMBiva();

      stato.add('Recupero Tipi Pagemnto'.obs);
      await initMBTipoPag();

      stato.add('Recupero Soluzioni Pagamento'.obs);
      await initMBSolPag();

      stato.add('Recupero Tipi Conto'.obs);
      await initTipoConto();

      stato.add('Recupero Id Soc: '.obs);
      await getMBSoc();

      stato.add('Recupero Id Div: '.obs);
      await getMBDiv();

      stato.add(
          'Prima sincronizzazione effettuata, andare nel menu impostazioni e poi tornare in questa serchermata per eseguire il lo Step 2'
              .obs);
      await updateDeviceInitStatus(1);
    } catch (e) {
      // Gestisci eccezioni di rete o errore generale
      debugPrint('Si è verificato un errore: $e');
    }
  }

  Future<void> initDB2(int idAge, int idOCTipo, int idFTTipo, int idBLTipo1,
      int idBLTipo2, int tipoConto) async {
    try {
      stato.add('Recupero Anagrafiche Clienti: '.obs);
      await initMB_Anag(idAge, tipoConto);

      stato.add('Recupero Destinazioni Clienti'.obs);
      await initMBCliForDest(idAge, tipoConto);

      stato.add('Recupero Sconti Clienti'.obs);
      await initSconti(idAge, tipoConto);

      stato.add('Recupero Partite: '.obs);
      await initCA_Partite(idAge, tipoConto);

      stato.add('Recupero Testate Bolle Tipo1: '.obs);
      await initBL_Anagr(idBLTipo1, tipoConto);

      stato.add('Recupero Righe Bolle Tipo1: '.obs);
      await initBL_Artic(idBLTipo1, tipoConto);

      stato.add('Recupero Pagamenti Bolla Tipo1'.obs);
      await initBLPagam(idBLTipo1, tipoConto);

      stato.add('Recupero Testate Bolle Tipo2: '.obs);
      await initBL_Anagr(idBLTipo2, tipoConto);

      stato.add('Recupero Righe Bolle Tipo2: '.obs);
      await initBL_Artic(idBLTipo2, tipoConto);

      stato.add('Recupero Pagamenti Bolla Tipo2'.obs);
      await initBLPagam(idBLTipo2, tipoConto);

      stato.add('Recupero Testate Fatture: '.obs);
      await initFT_Anagr(idAge, tipoConto);

      stato.add('Recupero Righe Fatture: '.obs);
      await initFT_Artic(idAge, tipoConto);

      stato.add('Recupero Pagamenti Fatture: '.obs);
      await initFTPagam(idAge, tipoConto);

      stato.add('Recupero Testate Ordini: '.obs);
      await initOC_Anagr(idOCTipo, tipoConto);

      stato.add('Recupero Righe Ordini: '.obs);
      await initOC_Arti(idOCTipo, tipoConto);

      stato.add('Recupero Pagamenti Ordini: '.obs);
      await initOCPagam(idAge, tipoConto);

      stato.add(
          'Inzizalizzazione Completata, premi il pulsante Carica Clienti'.obs);

      await updateDeviceInitStatus(2);
    } catch (e) {
      debugPrint('Si è verificato un errore: $e');
    }
  }
}
