import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';
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
  var logger = Logger();
  RxString indirizzo = ''.obs;
  RxString status = ''.obs;
  RxString ipAddressApi = ''.obs;
  RxString ipAddressWsc = ''.obs;
  bool getPermission = false;
  String message = "Per piacere concedi i permessi.";
  RxList<RxString> stato = <RxString>[].obs;
  RxString numMBAN = ''.obs;
  RxString numCAPA = ''.obs;
  RxString numBLTI = ''.obs;
  RxString numMBAG = ''.obs;
  RxString numFTTI = ''.obs;
  RxString numOCTI = ''.obs;
  RxString numOCAN = ''.obs;
  RxString numOCAR = ''.obs;
  RxString numFTAN = ''.obs;
  RxString numFTAR = ''.obs;
  RxString numBLAN = ''.obs;
  RxString numBLAR = ''.obs;
  RxString numMGAA = ''.obs;
  RxString numMBIV = ''.obs;
  RxString numMBTP = ''.obs;
  RxString numMBSP = ''.obs;
  RxString numBLPG = ''.obs;
  RxString numOCPG = ''.obs;
  RxString numFTPG = ''.obs;
  RxString numMBTC = ''.obs;
  RxString numMBTA = ''.obs;
  RxString numSconti = ''.obs;
  RxString numprezzi = ''.obs;

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
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo _deviceData;
    stato.add(controlloPermessi);
    String imei;
    var permission = await Permission.phone.status;

    /* socket = socket_io.io(indirizzoServer.value.text, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    }); */
    imei = await DatabaseHelper().getIMEI();
    stato.add('Imei: $imei'.obs);
    if (imei.isEmpty) {
      debugPrint('Permesso per l\'accesso al telefono: $permission');
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
      }
    }
    stato.add(statoConnessione);
    //socket.connect();
    try {
      await wsc.connectToWebSocket();
      stato.add('Connesso'.obs);
      update();
    } catch (e) {
      statoConnessione.value = '${statoConnessione.value}$e';
    }

    /*  wsc.socket!.on('initDB', (_) async {
      stato.add(statoDatabase);
      await initDB1();
      statoDatabase.value = '${statoDatabase.value}Fatto!';
    }); */

    //wsc.socket!.emit('sendIMEI', await DatabaseHelper().getIMEI());
  }

  /*ANAGRAFICHE*/

  Future<void> getNumMbAnag(int mbagid, int tipoConto) async {
    numMBAN = '0'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numMBAnag/$tipoConto/$mbagid');
    numMBAN = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initMB_Anag(int mbagid, int tipoConto) async {
    contMBAN = 0.obs;
    List<Cliente> batch = [];
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/mbanag/$tipoConto/$mbagid';
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

      await getNumMbAnag(mbagid, tipoConto);

      stato.add('${contMBAN.value} di ${numMBAN.value}'.obs);

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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contMBAN.value} di ${numMBAN.value}'.obs;
              } else {
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
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contMBAN.value} di ${numMBAN.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata MBAN');
    } catch (e) {
      debugPrint('Errore durante la richiesta: $e');
    }
  }

  /*SCONTI ANAGRAFICHE */
  Future<void> getNumSconti(int mbagid, int tipoConto) async {
    var dioClient = dio.Dio();
    final response = await dioClient.get(
        '${ipAddressApi.value}/infoInitDb/numMBAnag/sconti/$tipoConto/$mbagid');
    debugPrint(response.toString());
    numSconti.value = jsonDecode(response.toString())['tot'].toString();
  }

  Future<void> initSconti(int mbagid, int tipoConto) async {
    contSconti = 0.obs;
    var dioClient = dio.Dio();
    var url =
        '${ipAddressApi.value}/initdbclient/mbanag/sconti/$tipoConto/$mbagid';
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

      await getNumSconti(mbagid, tipoConto);

      stato.add('${contSconti.value} di ${numSconti.value}'.obs);

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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contSconti.value} di ${numSconti.value}'.obs;
              } else {
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
        if (controllo == 'ok') {
          stato[stato.length - 1] =
              '${contSconti.value} di ${numSconti.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }

      debugPrint('Elaborazione completata Sconti');
    } catch (e) {
      debugPrint('Errore durante la richiesta Sconti: $e');
    }
  }

  /*Z_PrezziTv */

  Future<void> getNumZPrezziTv() async {
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numMBAnag/zprezzitv');
    debugPrint(response.toString());
    numprezzi.value = jsonDecode(response.toString())['tot'].toString();
  }

  Future<void> initZprezziTv() async {
    contZprezzi = 0.obs;
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/zprezzitv';
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

      await getNumZPrezziTv();

      stato.add('${contZprezzi.value} di ${numprezzi.value}'.obs);

      List<PrezziTV> batch = [];
      int batchSize = 100; // Set a batch size as needed

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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contZprezzi.value} di ${numprezzi.value}'.obs;
              } else {
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
        if (controllo == 'ok') {
          stato[stato.length - 1] =
              '${contZprezzi.value} di ${numprezzi.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }

      debugPrint('Elaborazione completata Z Prezzi');
    } catch (e) {
      debugPrint('Errore durante la richiesta Z Prezzi: $e');
    }
  }
  /*ARTICOLI*/

  Future<void> getNumArticoli() async {
    numMGAA = '0'.obs;
    var dioClient = dio.Dio();
    final response =
        await dioClient.get('${ipAddressApi.value}/infoInitDb/numMGAnaArt');

    numMGAA = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initMG_AnaArt() async {
    contMGAA = 0.obs;
    List<Prodotto> batch = [];
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/mganaart/';
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

      await getNumArticoli();

      stato.add('${contMGAA.value} di ${numMGAA.value}'.obs);
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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contMGAA.value} di ${numMGAA.value}'.obs;
              } else {
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
        String controllo = await DatabaseHelper().initDbArticoliBatch(batch);
        contMGAA.value = contMGAA.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contMGAA.value} di ${numMGAA.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata MGAA');
    } catch (e) {
      debugPrint('Errore durante la richiesta MGAA: $e');
    }
  }

  /*PARTITE*/

  Future<void> getNumCAPartite(int mbagid, int tipoConto) async {
    numCAPA = '0'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient.get(
        '${ipAddressApi.value}/infoInitDb/numCAPartite/$tipoConto/$mbagid');
    logger
        .i('${ipAddressApi.value}/infoInitDb/numCAPartite/$tipoConto/$mbagid');
    numCAPA = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initCA_Partite(int mbagid, int tipoConto) async {
    contCAPA = 0.obs;
    List<Partita> batch = [];
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/capartite/$tipoConto/$mbagid';
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

      await getNumCAPartite(mbagid, tipoConto);

      stato.add('${contCAPA.value} di ${numCAPA.value}'.obs);
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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contCAPA.value} di ${numCAPA.value}'.obs;
              } else {
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
        String controllo = await DatabaseHelper().initDbPartiteBatch(batch);
        contCAPA.value = contCAPA.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contCAPA.value} di ${numCAPA.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata CAPA');
    } catch (e) {
      debugPrint('Errore durante la richiesta CAPA: $e');
    }
  }

  /*TIPI*/

  Future<void> getNumTipoConto() async {
    numMBTC = '0'.obs;
    var dioClient = dio.Dio();
    final response =
        await dioClient.get('${ipAddressApi.value}/infoInitDb/numMBTipoConto');
    logger.i('${ipAddressApi.value}/infoInitDb/numMBTipoConto');
    numMBTC = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initTipoConto() async {
    contMBTC = 0.obs;
    List<TipoConto> batch = [];
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/mbtipoconto/';
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

      await getNumTipoConto();

      stato.add('${contMBTC.value} di ${numMBTC.value}'.obs);
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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contMBTC.value} di ${numMBTC.value}'.obs;
              } else {
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
        String controllo = await DatabaseHelper().initMBTipoContoBatch(batch);
        contMBTC.value = contMBTC.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contMBTC.value} di ${numMBTC.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata MBTC');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBTC: $e');
    }
  }

  Future<void> getNumTipoPag() async {
    numMBTP = '0'.obs;
    var dioClient = dio.Dio();
    final response =
        await dioClient.get('${ipAddressApi.value}/infoInitDb/numMBTipoPag');
    numMBTP = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initMBTipoPag() async {
    contMBTP = 0.obs;
    List<TipoPagamento> batch = [];
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/tipopapg/';
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

      await getNumTipoPag();

      stato.add('${contMBTP.value} di ${numMBTP.value}'.obs);
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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contMBTP.value} di ${numMBTP.value}'.obs;
              } else {
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
        String controllo = await DatabaseHelper().initDbTipoPagBatch(batch);
        contMBTP.value = contMBTP.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contMBTP.value} di ${numMBTP.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata MBTP');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBTP: $e');
    }
  }

  Future<void> getNumTipiArticolo() async {
    numMBTA = '0'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numMBTipiArticolo');
    numMBTA = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initMBTipiArticolo() async {
    contMBTA = 0.obs;
    List<TipoArticolo> batch = [];
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/mbta/';
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

      await getNumTipiArticolo();

      stato.add('${contMBTA.value} di ${numMBTA.value}'.obs);
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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contMBTA.value} di ${numMBTA.value}'.obs;
              } else {
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
        String controllo =
            await DatabaseHelper().initDbTipoArticoliBatch(batch);
        contMBTA.value = contMBTA.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contMBTA.value} di ${numMBTA.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata MBTA');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBTA: $e');
    }
  } //----

  Future<void> getNumSolPag() async {
    numMBSP = '0'.obs;
    var dioClient = dio.Dio();
    final response =
        await dioClient.get('${ipAddressApi.value}/infoInitDb/numMBSolPag');
    numMBSP = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initMBSolPag() async {
    contMBSP = 0.obs;
    List<SoluzionePagamento> batch = [];
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/solpag/';
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

      await getNumSolPag();

      stato.add('${contMBSP.value} di ${numMBSP.value}'.obs);
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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contMBSP.value} di ${numMBSP.value}'.obs;
              } else {
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
        String controllo = await DatabaseHelper().initDbSolPagBatch(batch);
        contMBSP.value = contMBSP.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contMBSP.value} di ${numMBSP.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata MBSP');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBSP: $e');
    }
  }

  Future<void> getNumMbAge() async {
    numMBAG = '0'.obs;
    var dioClient = dio.Dio();
    final response =
        await dioClient.get('${ipAddressApi.value}/infoInitDb/numMBAge');
    numMBAG = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initMBage() async {
    contMBAG = 1.obs;
    /*RICHIESTA TIPO BOLLE */
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/mbage';
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

      await getNumMbAge();
      stato.add('${contMBAG.value} di ${numMBAG.value}'.obs);
      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var ag = Agente.fromJson(jsonData);
            String controllo = await DatabaseHelper().initMBAge(ag);
            if (controllo == 'ok') {
              stato[stato.length - 1] =
                  '${contMBAG.value++} di ${numMBAG.value}'.obs;
            } else {
              stato[stato.length - 1] = controllo.obs;
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON MBAG: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      debugPrint('Elaborazione completata MBAG');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBAG: $e');
    }
  }

  Future<void> getNumMBIva() async {
    numMBIV = '0'.obs;
    var dioClient = dio.Dio();
    final response =
        await dioClient.get('${ipAddressApi.value}/infoInitDb/numMBIva');
    numMBIV = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initMBiva() async {
    contMBIV = 1.obs;

    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/mbiva';
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

      await getNumMBIva();
      stato.add('${contMBIV.value} di ${numMBIV.value}'.obs);
      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var iva = Iva.fromJson(jsonData);
            String controllo = await DatabaseHelper().initMBIva(iva);
            if (controllo == 'ok') {
              stato[stato.length - 1] =
                  '${contMBIV.value++} di ${numMBIV.value}'.obs;
            } else {
              stato[stato.length - 1] = controllo.obs;
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON MBIV: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      debugPrint('Elaborazione completata MBIV');
    } catch (e) {
      debugPrint('Errore durante la richiesta MBIV: $e');
    }
  }

  Future<void> getNumBlTipo() async {
    numBLTI = '0'.obs;
    var dioClient = dio.Dio();
    final response =
        await dioClient.get('${ipAddressApi.value}/infoInitDb/numBLTipo');
    numBLTI = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initBL_Tipo() async {
    contBLTI = 1.obs;
    /*RICHIESTA TIPO BOLLE */
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/bltipo';
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

      await getNumBlTipo();
      stato.add('${contBLTI.value} di ${numBLTI.value}'.obs);
      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var tipoBolla = TipoBolla.fromJson(jsonData);
            String controllo = await DatabaseHelper().initBLTipo(tipoBolla);
            if (controllo == 'ok') {
              stato[stato.length - 1] =
                  '${contBLTI.value++} di ${numBLTI.value}'.obs;
            } else {
              stato[stato.length - 1] = controllo.obs;
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON BLTI: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      debugPrint('Elaborazione completata BLTI');
    } catch (e) {
      debugPrint('Errore durante la richiesta BLTI: $e');
    }
  }

  Future<void> getNumFtTipo() async {
    numFTTI = '0'.obs;
    var dioClient = dio.Dio();
    final response =
        await dioClient.get('${ipAddressApi.value}/infoInitDb/numFTTipo');
    numFTTI = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initFT_Tipo() async {
    contFTTI = 1.obs;
    /*RICHIESTA TIPO FATTURE */
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/fttipo';
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

      await getNumFtTipo();
      stato.add('${contFTTI.value} di ${numFTTI.value}'.obs);
      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var tipoFattura = TipoFattura.fromJson(jsonData);
            String controllo = await DatabaseHelper().initFTTipo(tipoFattura);
            if (controllo == 'ok') {
              stato[stato.length - 1] =
                  '${contFTTI.value++} di ${numFTTI.value}'.obs;
            } else {
              stato[stato.length - 1] = controllo.obs;
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON FTTI: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      debugPrint('Elaborazione completata FTTI');
    } catch (e) {
      debugPrint('Errore durante la richiesta FTTI: $e');
    }
  }

  Future<void> getNumOcTipo() async {
    numOCTI = '0'.obs;
    var dioClient = dio.Dio();
    final response =
        await dioClient.get('${ipAddressApi.value}/infoInitDb/numOCTipo');
    numOCTI = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initOC_Tipo() async {
    /*RICHIESTA TIPO ORDINE */
    contOCTI = 1.obs;
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/octipo';
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

      await getNumOcTipo();
      stato.add('${contOCTI.value} di ${numOCTI.value}'.obs);
      await for (String line in stream) {
        if (line.isNotEmpty) {
          try {
            var jsonData = json.decode(line);
            var tipoOrdine = TipoOrdine.fromJson(jsonData);
            String controllo = await DatabaseHelper().initOCTipo(tipoOrdine);
            if (controllo == 'ok') {
              stato[stato.length - 1] =
                  '${contOCTI.value++} di ${numOCTI.value}'.obs;
            } else {
              stato[stato.length - 1] = controllo.obs;
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON OCTI: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      debugPrint('Elaborazione completata OCTI');
    } catch (e) {
      debugPrint('Errore durante la richiesta OCTI: $e');
    }
  }

  /*ORDINI*/

  Future<void> getNumOCPagam(int mbagid, int tipoConto) async {
    numOCPG = '0'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numOCPagam/$tipoConto/$mbagid');
    logger.i('${ipAddressApi.value}/infoInitDb/numOCPagam/$tipoConto/$mbagid');
    numOCPG = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initOCPagam(int mbagid, int tipoConto) async {
    /*RICHIESTA TESTATE ORDINI */
    List<PagamentoOrdine> batch = [];
    contOCPG = 0.obs;
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/ocpagam/$tipoConto/$mbagid';
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

      await getNumOCPagam(mbagid, tipoConto);
      stato.add('${contOCPG.value} di ${numOCPG.value}'.obs);

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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contOCPG.value} di ${numOCPG.value}'.obs;
              } else {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON OCPG: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbOCPagametiBatch(batch);
        contOCPG.value = contOCPG.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contOCPG.value} di ${numOCPG.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata OCPG');
    } catch (e) {
      debugPrint('Errore durante la richiesta OCPG: $e');
    }
  }

  Future<void> getNumOcAnag(int mbagid, int tipoConto) async {
    numOCAN = '0'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numOCAnag/$tipoConto/$mbagid');
    logger.i('${ipAddressApi.value}/infoInitDb/numOCAnag/$tipoConto/$mbagid');
    numOCAN = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initOC_Anagr(int ocTipo, int tipoConto) async {
    /*RICHIESTA TESTATE ORDINI */
    List<TestataOrdine> batch = [];
    contOCAN = 0.obs;
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/ocanag/$tipoConto/$ocTipo';
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

      await getNumOcAnag(ocTipo, tipoConto);
      stato.add('${contOCAN.value} di ${numOCAN.value}'.obs);

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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contOCAN.value} di ${numOCAN.value}'.obs;
              } else {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON OCAN: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initTestataOrdiniBatch(batch);
        contOCAN.value = contOCAN.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contOCAN.value} di ${numOCAN.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata OCAN');
    } catch (e) {
      debugPrint('Errore durante la richiesta OCAN: $e');
    }
  }

  Future<void> getNumOcArtic(int mbagid, tipoConto) async {
    numOCAR = '0'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numOCArtic/$tipoConto/$mbagid');
    logger.i('${ipAddressApi.value}/infoInitDb/numOCArtic/$tipoConto/$mbagid');
    numOCAR = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initOC_Arti(int ocTipo, int tipoConto) async {
    /*RICHIESTA RIGHE ORDINI */
    List<RigaOrdine> batch = [];
    contOCAR = 0.obs;
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/ocartic/$tipoConto/$ocTipo';
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

      await getNumOcArtic(ocTipo, tipoConto);
      stato.add('${contOCAR.value} di ${numOCAR.value}'.obs);

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
              batch.clear(); // Svuota il batch dopo l'inserimento
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contOCAR.value} di ${numOCAR.value}'.obs;
              } else {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON OCAR: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      // Assicurati di inserire qualsiasi riga rimasta nel batch
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initRigheOrdineBatch(batch);
        contOCAR.value = contOCAR.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contOCAR.value} di ${numOCAR.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata OCAR');
    } catch (e) {
      debugPrint('Errore durante la richiesta OCAR: $e');
    }
  }

  /*FATTURE*/

  Future<void> getNumFTPagam(int mbagid, int tipoConto) async {
    numFTPG = '0'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numFTPagam/$tipoConto/$mbagid');
    logger.i('${ipAddressApi.value}/infoInitDb/numFTPagam/$tipoConto/$mbagid');
    numFTPG = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initFTPagam(int mbagid, int tipoConto) async {
    /*RICHIESTA TESTATE FATTURE */
    List<PagamentoFattura> batch = [];
    contFTPG = 0.obs;
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/ftpagam/$tipoConto/$mbagid';
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

      await getNumFTPagam(mbagid, tipoConto);
      stato.add('${contFTPG.value} di ${numFTPG.value}'.obs);

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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contFTPG.value} di ${numFTPG.value}'.obs;
              } else {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON FTPG: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbFTPagametiBatch(batch);
        contFTPG.value = contFTPG.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contFTPG.value} di ${numFTPG.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata FTPG');
    } catch (e) {
      debugPrint('Errore durante la richiesta FTPG: $e');
    }
  }

  Future<void> getNumFtAanagr(int mbagid, int tipoConto) async {
    numFTAN = '0'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numFTAnag/$tipoConto/$mbagid');
    logger.i('${ipAddressApi.value}/infoInitDb/numFTAnag/$tipoConto/$mbagid');
    numFTAN = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initFT_Anagr(int mbagid, int tipoConto) async {
    /*RICHIESTA TESTATE FATTURE */
    List<TestataFattura> batch = [];
    contFTAN = 0.obs;
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/ftanagr/$tipoConto/$mbagid';
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

      await getNumFtAanagr(mbagid, tipoConto);
      stato.add('${contFTAN.value} di ${numFTAN.value}'.obs);

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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contFTAN.value} di ${numFTAN.value}'.obs;
              } else {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON FTAN: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo =
            await DatabaseHelper().initTestataFatturaBatch(batch);
        contFTAN.value = contFTAN.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contFTAN.value} di ${numFTAN.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata FTAN');
    } catch (e) {
      debugPrint('Errore durante la richiesta FTAN: $e');
    }
  }

  Future<void> getNumFTAR(int mbagid, int tipoConto) async {
    numFTAR = '1'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numFTArtic/$tipoConto/$mbagid');
    logger.i('${ipAddressApi.value}/infoInitDb/numFTArtic/$tipoConto/$mbagid');
    numFTAR = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initFT_Artic(int mbagid, int tipoConto) async {
    /*RICHIESTA RIGHE FATTURE */
    List<RigaFattura> batch = [];
    contFTAR = 0.obs;
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/ftartic/$tipoConto/$mbagid';
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

      await getNumFTAR(mbagid, tipoConto);

      stato.add('${contFTAR.value} di ${numFTAR.value}'.obs);
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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contFTAR.value} di ${numFTAR.value}'.obs;
              } else {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON FTAR: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initRigaFatturaBatch(batch);
        contFTAR.value = contFTAR.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contFTAR.value} di ${numFTAR.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata FTAR');
    } catch (e) {
      debugPrint('Errore durante la richiesta FTAR: $e');
    }
  }

  /*BOLLE*/

  Future<void> getNumBlPagam(int mbagid, int tipoConto) async {
    numBLPG = '0'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numBLPagam/$tipoConto/$mbagid');
    logger.i('${ipAddressApi.value}/infoInitDb/numBLPagam/$tipoConto/$mbagid');
    numBLPG = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initBLPagam(int mbagid, int tipoConto) async {
    contBLPG = 0.obs;
    List<PagamentoBolla> batch = [];
    /*RICHIESTA TESTATE BOLLE */
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/blpagam/$tipoConto/$mbagid';
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

      await getNumBlPagam(mbagid, tipoConto);
      stato.add('${contBLPG.value} di ${numBLPG.value}'.obs);

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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contBLPG.value} di ${numBLPG.value}'.obs;
              } else {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON BLPG: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initDbBlPagamentiBatch(batch);
        contBLPG.value = contBLPG.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contBLPG.value} di ${numBLPG.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata BLPG');
    } catch (e) {
      debugPrint('Errore durante la richiesta BLPG: $e');
    }
  }

  Future<void> getNumBlAanagr(int mbagid, int tipoConto) async {
    numBLAN = '0'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numBLAnag/$tipoConto/$mbagid');
    logger.i('${ipAddressApi.value}/infoInitDb/numBLAnag/$tipoConto/$mbagid');
    numBLAN = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initBL_Anagr(int mbagid, int tipoConto) async {
    contBLAN = 0.obs;
    List<TestataBolla> batch = [];
    /*RICHIESTA TESTATE BOLLE */
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/blanag/$tipoConto/$mbagid';
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

      await getNumBlAanagr(mbagid, tipoConto);
      stato.add('${contBLAN.value} di ${numBLAN.value}'.obs);

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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contBLAN.value} di ${numBLAN.value}'.obs;
              } else {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON BLAN: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initTestataBolleBatch(batch);
        contBLAN.value = contBLAN.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contBLAN.value} di ${numBLAN.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata BLAN');
    } catch (e) {
      debugPrint('Errore durante la richiesta BLAN: $e');
    }
  }

  Future<void> getNumBlAartic(int mbagid, int tipoConto) async {
    numBLAR = '0'.obs;
    var dioClient = dio.Dio();
    final response = await dioClient
        .get('${ipAddressApi.value}/infoInitDb/numBLArtic/$tipoConto/$mbagid');
    logger.i('${ipAddressApi.value}/infoInitDb/numBLArtic/$tipoConto/$mbagid');
    debugPrint(
        '${ipAddressApi.value}/infoInitDb/numBLArtic/$tipoConto/$mbagid');
    numBLAR = jsonDecode(response.toString())['tot'].toString().obs;
  }

  Future<void> initBL_Artic(int mbagid, int tipoConto) async {
    /*RICHIESTA RIGHE BOLLE */
    contBLAR = 0.obs;
    List<RigaBolla> batch = [];
    var dioClient = dio.Dio();
    var url = '${ipAddressApi.value}/initdbclient/blartic/$tipoConto/$mbagid';
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

      await getNumBlAartic(mbagid, tipoConto);
      stato.add('${contBLAR.value} di ${numBLAR.value}'.obs);

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
              if (controllo == 'ok') {
                stato[stato.length - 1] =
                    '${contBLAR.value} di ${numBLAR.value}'.obs;
              } else {
                stato[stato.length - 1] = controllo.obs;
              }
            }
          } catch (e) {
            debugPrint('Errore di parsing JSON BLAR: $e');
            // Gestisci l'errore di parsing
          }
        }
      }
      if (batch.isNotEmpty) {
        String controllo = await DatabaseHelper().initRigheBolleBatch(batch);
        contBLAR.value = contBLAR.value + batch.length;
        batch.clear(); // Svuota il batch dopo l'inserimento
        if (controllo == 'ok') {
          stato[stato.length - 1] = '${contBLAR.value} di ${numBLAR.value}'.obs;
        } else {
          stato[stato.length - 1] = controllo.obs;
        }
      }
      debugPrint('Elaborazione completata BLAR');
    } catch (e) {
      debugPrint('Errore durante la richiesta BLAR: $e');
    }
  }

  Future<void> getMBSoc() async {
    var dioClient = dio.Dio();
    final response =
        await dioClient.get('${ipAddressApi.value}/infoInitDb/mbsoc');
    logger.i('${ipAddressApi.value}/infoInitDb/mbsoc');
    int mbsoc_id = jsonDecode(response.toString())['MBSC_ID'];
    stato.add('MBSOC: $mbsoc_id'.obs);
    try {
      await DatabaseHelper()
          .rawUpd('UPDATE SP_Param SET SPPA_MBSC_ID=?', [mbsoc_id]);
    } catch (e) {
      logger.e('Errore durante l\'aggiornamento MBSOC: $e');
    }
  }

  Future<void> getMBDiv() async {
    var dioClient = dio.Dio();
    final response =
        await dioClient.get('${ipAddressApi.value}/infoInitDb/mbdiv');
    logger.i('${ipAddressApi.value}/infoInitDb/mbdiv');
    int mbdiv_id = jsonDecode(response.toString())['MBDV_Id'];
    stato.add('MBDIV: $mbdiv_id'.obs);
    try {
      await DatabaseHelper()
          .rawUpd('UPDATE SP_Param SET SPPA_MBDV_ID=?', [mbdiv_id]);
    } catch (e) {
      logger.e('Errore durante l\'aggiornamento MBSOC: $e');
    }
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
