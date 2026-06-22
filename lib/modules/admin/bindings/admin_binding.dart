import 'package:get/get.dart';
import 'package:edu_presence/modules/admin/controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController());
  }
}
