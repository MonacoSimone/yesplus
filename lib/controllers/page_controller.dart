import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class PagineController extends GetxController {
  var pageController = PageController().obs;
  var page = 0.obs;
  late socket_io.Socket socket;
  bool getPermission = false;
  String message = "Please allow permission request!";

  onPageChanged(input) {
    page.value = input;
  }

  animateTo(int page) {
    if (pageController.value.hasClients) {
      pageController.value.jumpToPage(
              page) /*  .animateToPage(page,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn) */
          ;
    }
  }

  @override
  void onClose() {
    pageController.value.dispose();
  }
}
