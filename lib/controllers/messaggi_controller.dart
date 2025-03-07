import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/messaggio_da_inviare.dart';
import '../database/db_helper.dart';

class MessaggiController extends GetxController {
  var messaggiList = <Messaggio>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMessaggi();
  }

  // Funzione per chiamare il database e caricare i messaggi
  Future<void> fetchMessaggi() async {
    try {
      isLoading(true);
      var messaggiMap = await DatabaseHelper().getMessaggiDaInviare();
      debugPrint('MEssaggi ${messaggiMap.toString()}');
      if (messaggiMap != null) {
        // Converti la lista di mappe in una lista di oggetti Messaggio
        var messaggi =
            messaggiMap.map((map) => Messaggio.fromMap(map)).toList();
        if (messaggi.isNotEmpty) {
          messaggiList.value = messaggi;
        }
      } else {
        debugPrint('messaggiMap is null');
      }
    } finally {
      isLoading(false);
    }
  }
}
