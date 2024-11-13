import 'package:get/get.dart';

class SidebarController extends GetxController {
  List<RxBool> pulsantiPagine = [true.obs, false.obs, false.obs, false.obs];

  RxBool ricercaClienti = false.obs;
  RxBool ordine = false.obs;
  RxBool incasso = false.obs;
  RxBool documenti = false.obs;
  RxInt selectedIcon = 0.obs;

  onPageChanged(input) {
    pulsantiPagine[input].value = true;
    pulsantiPagine[selectedIcon.value].value = false;
    selectedIcon.value = input;
  }
}
