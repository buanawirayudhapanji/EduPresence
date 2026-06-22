part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const ADMIN_DASHBOARD = _Paths.ADMIN_DASHBOARD;
  static const MANAGE_COORDINATE = _Paths.MANAGE_COORDINATE;
  static const MANAGE_ATTENDANCE = _Paths.MANAGE_ATTENDANCE;
  static const USER_DASHBOARD = _Paths.USER_DASHBOARD;
  static const USER_PROFILE = _Paths.USER_PROFILE;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const ADMIN_DASHBOARD = '/admin-dashboard';
  static const MANAGE_COORDINATE = '/manage-coordinate';
  static const MANAGE_ATTENDANCE = '/manage-attendance';
  static const USER_DASHBOARD = '/user-dashboard';
  static const USER_PROFILE = '/user-profile';
}
