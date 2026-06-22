import 'package:get/get.dart';
import 'package:edu_presence/modules/auth/bindings/auth_binding.dart';
import 'package:edu_presence/modules/auth/views/login_view.dart';
import 'package:edu_presence/modules/auth/views/register_view.dart';
import 'package:edu_presence/modules/admin/bindings/admin_binding.dart';
import 'package:edu_presence/modules/admin/views/admin_dashboard_view.dart';
import 'package:edu_presence/modules/admin/views/manage_coordinate_view.dart';
import 'package:edu_presence/modules/admin/views/manage_attendance_view.dart';
import 'package:edu_presence/modules/user/bindings/user_binding.dart';
import 'package:edu_presence/modules/user/views/user_dashboard_view.dart';
import 'package:edu_presence/modules/user/views/user_profile_view.dart';
import 'package:edu_presence/modules/splash/views/splash_view.dart';
import 'package:edu_presence/modules/splash/controllers/splash_controller.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put<SplashController>(SplashController());
      }),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_COORDINATE,
      page: () => const ManageCoordinateView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_ATTENDANCE,
      page: () => const ManageAttendanceView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: _Paths.USER_DASHBOARD,
      page: () => const UserDashboardView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: _Paths.USER_PROFILE,
      page: () => const UserProfileView(),
      binding: UserBinding(),
    ),
  ];
}
