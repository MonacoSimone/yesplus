import 'package:get/get.dart';
import '../pages/home.dart';
import '../pages/splash_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomePage(),
      //binding: HomeBinding(),
    ),
    /* GetPage(name: _Paths.MAP, page: () => Mappa(), binding: MappaBinding()),
    GetPage(name: _Paths.POI, page: () => PoiList(), binding: PoiBinding()),*/
    GetPage(name: _Paths.SPLASH, page: () => SplashScreen())
  ];
}
