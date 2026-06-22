import 'package:get/get.dart';
import 'package:edu_presence/routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Simulate a splash screen delay of 3 seconds, then navigate to login screen
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.LOGIN);
    });
  }
}
