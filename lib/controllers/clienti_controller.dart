import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../models/anagrafica.dart';

class ClientiController extends GetxController {
  Anagrafica anagrafica = Anagrafica(clienti: <Cliente>[].obs);
  Anagrafica anagraficaOriginale = Anagrafica(clienti: <Cliente>[].obs);
  List<Cliente> clientiTemp = <Cliente>[];
  RxString nome = ''.obs;
  RxString comune = ''.obs;
  final nomeController = TextEditingController(text: 'Nome Cliente');
  final comuneController = TextEditingController(text: 'Comune');
  FocusNode nomeNode = FocusNode();
  FocusNode comuneNode = FocusNode();

  Rx<Cliente> clienteSelezionato = Cliente(
          mbpcId: 0,
          mbanId: 0,
          mbanRagSoc: 'mbanRagSoc',
          mbanIndirizzo: 'mbanIndirizzo',
          mbanCodFiscale: 'mbanCodFiscale',
          mbanPartitaIva: 'mbanPartitaIva',
          mbanComune: 'mbanComune',
          mbpcConto: '',
          mbpcSottoConto: '',
          mbanTelefono: 'null',
          mbanEmail: '',
          mbanEmail2: 'null',
          mbanGpse: 'null',
          mbanGpsn: 'null',
          mbanDataFineVal: 'null',
          sconto1: 0.0,
          sconto2: 0.0,
          sconto3: 0.0)
      .obs;

  @override
  void onInit() {
    super.onInit();
    // Qui puoi inizializzare i tuoi dati o impostare listener
    // Ad esempio, potresti voler chiamare un API per ottenere dati quando il controller viene inizializzato

    // Impostiamo un semplice listener sul contatore

    nomeNode.addListener(() {
      // Controlla se il TextField ha ottenuto il focus
      if (nomeNode.hasFocus) {
        // Se sì, cancella il testo
        if (nomeController.text == 'Nome Cliente') {
          nomeController.clear();
        }
      } else {
        if (nomeController.text.isEmpty) {
          nomeController.text = 'Nome Cliente';
        }
      }
    });

    comuneNode.addListener(() {
      // Controlla se il TextField ha ottenuto il focus
      if (comuneNode.hasFocus) {
        // Se sì, cancella il testo
        if (comuneController.text == 'Comune') {
          comuneController.clear();
        }
      } else {
        if (comuneController.text.isEmpty) {
          comuneController.text = 'Comune';
        }
      }
    });
  }

  Future<List<Cliente>> caricaClienti() async {
    List<Cliente> cli = await DatabaseHelper().getAnagraficheClienti();
    return cli;
  }

  void resetClienti() {
    anagrafica.clienti.clear();
    clientiTemp.clear();
    for (var cliente in anagraficaOriginale.clienti) {
      anagrafica.clienti.add(cliente);
    }
  }

  filtraClienti() {
    anagrafica.clienti.clear();
    clientiTemp.clear();

    if (nome.isNotEmpty && comune.isNotEmpty) {
      clientiTemp = anagraficaOriginale.clienti
          .where((p0) =>
              p0.mbanRagSoc.toLowerCase().contains(nome.toLowerCase()) &&
              p0.mbanComune.toLowerCase().contains(comune.toLowerCase()))
          .toList();
    } else if (nome.isEmpty && comune.isNotEmpty) {
      clientiTemp = anagraficaOriginale.clienti
          .where((p0) =>
              p0.mbanComune.toLowerCase().contains(comune.toLowerCase()))
          .toList();
    } else if (comune.isEmpty && nome.isNotEmpty) {
      clientiTemp = anagraficaOriginale.clienti.where((p0) {
        return p0.mbanRagSoc.toLowerCase().contains(nome.toLowerCase());
      }).toList();
    }
    if (clientiTemp.isEmpty) {
      for (var cliente in anagraficaOriginale.clienti) {
        anagrafica.clienti.add(cliente);
      }
    } else {}
    for (var cliente in clientiTemp) {
      anagrafica.clienti.add(cliente);
    }
  }
}
