import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/messaggi_controller.dart';

class MessagesPage extends StatelessWidget {
  final MessaggiController messaggiController = Get.put(MessaggiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messaggi da Inviare'),
      ),
      body: Obx(() {
        if (messaggiController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (messaggiController.messaggiList.isEmpty) {
          return Center(child: Text('Nessun messaggio disponibile'));
        } else {
          return ListView.builder(
            itemCount: messaggiController.messaggiList.length,
            itemBuilder: (context, index) {
              final messaggio = messaggiController.messaggiList[index];
              return ListTile(
                title: Text('Table: ${messaggio.table}'),
                subtitle: Text('Query: ${messaggio.query}'),
                trailing: Text('ID: ${messaggio.id}'),
              );
            },
          );
        }
      }),
    );
  }
}
