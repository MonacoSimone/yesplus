import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../database/db_helper.dart';

class ParametriController extends GetxController {
  final idAgenteCT = TextEditingController();
  final passwordCT = TextEditingController();
  final serverAPI = TextEditingController(text: 'Server API');
  final serverWSK = TextEditingController(text: 'Server WSK');
  final imeiTxtCT = TextEditingController(text: 'Codice Univoco');
  FocusNode serverAPINode = FocusNode();
  FocusNode serverWSKNode = FocusNode();
  FocusNode imeiTxtCTNode = FocusNode();
  RxString agenteValue = ''.obs;
  RxString password = ''.obs;
  RxInt selectedItemIdOC = 0.obs;
  RxInt selectedItemIdFT = 0.obs;
  RxInt selectedItemIdBL1 = 0.obs;
  RxInt selectedItemIdBL2 = 0.obs;
  RxInt selectedItemAgente = 0.obs;
  RxInt selectedItemConto = 0.obs;
  RxList<Map<String, dynamic>> tipiConto = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> agenti = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> octipi = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> fttipi = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> bltipi1 = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> bltipi2 = <Map<String, dynamic>>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await init();
    serverAPINode.addListener(() {
      // Controlla se il TextField ha ottenuto il focus
      if (serverAPINode.hasFocus) {
        // Se sì, cancella il testo
        if (serverAPI.text == 'Server API') {
          serverAPI.clear();
        }
      } else {
        if (serverAPI.text.isEmpty) {
          serverAPI.text = 'Server API';
        }
      }
    });

    serverWSKNode.addListener(() {
      // Controlla se il TextField ha ottenuto il focus
      if (serverWSKNode.hasFocus) {
        // Se sì, cancella il testo
        if (serverWSK.text == 'Server WSK') {
          serverWSK.clear();
        }
      } else {
        if (serverWSK.text.isEmpty) {
          serverWSK.text = 'Server WSK';
        }
      }
    });

    imeiTxtCTNode.addListener(() {
      // Controlla se il TextField ha ottenuto il focus
      if (imeiTxtCTNode.hasFocus) {
        // Se sì, cancella il testo
        if (imeiTxtCT.text == 'Codice Univoco') {
          imeiTxtCT.clear();
        }
      } else {
        if (imeiTxtCT.text.isEmpty) {
          imeiTxtCT.text = 'Codice Univoco';
        }
      }
    });
  }

  void selectItem(int id) {
    selectedItemIdOC.value = id;
  }

  Future<void> init() async {
    await getTipoOrdine();
    await getTipoFattura();
    await getTipoBolla1();
    await getTipoBolla2();
    await getIdAgente();
    await getTipoConto();
    await getOCTipi();
    await getFTTipi();
    await getBLTipi1();
    await getBLTipi2();
    await getAgenti();
    await getPassword();
    await getTipiconto();
    serverWSK.text = await DatabaseHelper().getServerWSK();
    serverAPI.text = await DatabaseHelper().getServerAPI();
    imeiTxtCT.text = await DatabaseHelper().getIMEI();
  }

  Future<void> getTipiconto() async {
    List<Map<String, dynamic>> result = await DatabaseHelper().getConti();

    if (result.isNotEmpty) {
      selectedItemConto.value = selectedItemConto.value == 0
          ? result[0]['MBTC_TipoConto']
          : selectedItemConto.value;

      for (var res in result) {
        debugPrint(jsonEncode(res));
        tipiConto.add(res);
      }
    }
  }

  Future<void> getAgenti() async {
    List<Map<String, dynamic>> result = await DatabaseHelper().getAgenti();

    if (result.isNotEmpty) {
      selectedItemAgente.value = selectedItemAgente.value == 0
          ? result[0]['MBAG_ID']
          : selectedItemAgente.value;

      for (var res in result) {
        agenti.add(res);
      }
    }
  }

  Future<void> getOCTipi() async {
    List<Map<String, dynamic>> result = await DatabaseHelper().getOCTipo();
    if (result.isNotEmpty) {
      selectedItemIdOC.value = selectedItemIdOC.value == 0
          ? result[0]['OCTI_ID']
          : selectedItemIdOC.value;

      for (var res in result) {
        octipi.add(res);
      }
    }
  }

  Future<void> getFTTipi() async {
    List<Map<String, dynamic>> result = await DatabaseHelper().getFTTipo();
    if (result.isNotEmpty) {
      selectedItemIdFT.value = selectedItemIdFT.value == 0
          ? result[0]['FTTI_ID']
          : selectedItemIdFT.value;

      for (var res in result) {
        fttipi.add(res);
      }
    }
  }

  Future<void> getBLTipi1() async {
    List<Map<String, dynamic>> result = await DatabaseHelper().getBLTipo();
    if (result.isNotEmpty) {
      selectedItemIdBL1.value = selectedItemIdBL1.value == 0
          ? result[0]['BLTI_ID']
          : selectedItemIdBL1.value;

      for (var res in result) {
        bltipi1.add(res);
      }
    }
  }

  Future<void> getBLTipi2() async {
    List<Map<String, dynamic>> result = await DatabaseHelper().getBLTipo();
    if (result.isNotEmpty) {
      selectedItemIdBL2.value = selectedItemIdBL2.value == 0
          ? result[0]['BLTI_ID']
          : selectedItemIdBL2.value;

      for (var res in result) {
        bltipi2.add(res);
      }
    }
  }

  Future<void> getIdAgente() async {
    int result = await DatabaseHelper().getMBAGID();
    selectedItemAgente.value = result;
  }

  Future<void> getPassword() async {
    String? result = await DatabaseHelper().getPassword();
    result == null ? password.value = '' : password.value = result;
  }

  Future<void> getTipoOrdine() async {
    int result = await DatabaseHelper().getTipoOrdine();
    selectedItemIdOC.value = result;
  }

  Future<void> getTipoFattura() async {
    int result = await DatabaseHelper().getTipoFattura();
    selectedItemIdFT.value = result;
  }

  Future<void> getTipoBolla1() async {
    int result = await DatabaseHelper().getTipoBolla1();
    selectedItemIdBL1.value = result;
  }

  Future<void> getTipoBolla2() async {
    int result = await DatabaseHelper().getTipoBolla2();
    selectedItemIdBL2.value = result;
  }

  Future<void> getTipoConto() async {
    int result = await DatabaseHelper().getIdTipoConto();
    selectedItemConto.value = result;
  }

  //final titoliController = TextEditingController();
}
