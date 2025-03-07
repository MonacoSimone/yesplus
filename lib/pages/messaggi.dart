import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yesplus/controllers/controller_soket.dart';
import 'package:yesplus/controllers/ordine_controller.dart';
import 'package:yesplus/database/db_helper.dart';
import '../controllers/messaggi_controller.dart';

class MessagesPage extends StatelessWidget {
  final MessaggiController messaggiController = Get.put(MessaggiController());
  final OrdineController ordineController = Get.find<OrdineController>();
  final WebSocketController wc = Get.find<WebSocketController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messaggi da Inviare'), actions: [
        IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.redAccent,
          ),
          onPressed: () async {
            int val = await DatabaseHelper().deleteAllMessages();
            if (val != -1) {
              messaggiController.messaggiList.clear();
              Get.snackbar('Messaggi eliminati',
                  'Tutti i messaggi sono stati eliminati con successo');
            }
          },
        ),
        /*  ElevatedButton(
          onPressed: () async {
            await wc.sendPendingMessages();
          },
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green // Set the button color to blue
              ),
          child: Text('Invia'),
        ), */
      ]),
      body: Container(
        color: Colors.white,
        child: Obx(() {
          if (messaggiController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else if (messaggiController.messaggiList.isEmpty) {
            return Center(child: Text('Nessun messaggio disponibile'));
          } else {
            //debugPrint(
            //  'messaggiList: ${messaggiController.messaggiList[0].table}');
            return ListView.builder(
              itemCount: messaggiController.messaggiList.length,
              itemBuilder: (context, index) {
                final messaggio = messaggiController.messaggiList[index];
                return ListTile(
                  title: Text('Table: ${messaggio.table}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Query: ${messaggio.query}'),
                      Text('Data: ${messaggio.data}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ID: ${messaggio.id}'),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
                          int val = await DatabaseHelper()
                              .deleteMessage(messaggio.id!);
                          if (val != -1) {
                            messaggiController.messaggiList.removeAt(index);
                            Get.snackbar('Messaggio eliminato',
                                'Il messaggio è stato eliminato con successo');
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }),
      ),
    );
  }
}
