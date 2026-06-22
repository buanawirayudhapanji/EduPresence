import 'package:get/get.dart';
import 'package:edu_presence/modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Put permanent AuthController so that the logged-in user state can be accessed globally
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
