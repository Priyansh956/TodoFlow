import 'package:flutter/material.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/task_detail_screen.dart';
import '../presentation/screens/task_form_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String taskNew = '/task/new';
  static const String taskDetail = '/task/detail';
  static const String taskEdit = '/task/edit';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _slide(const SplashScreen());
      case login:
        return _slide(const LoginScreen());
      case register:
        return _slide(const RegisterScreen());
      case home:
        return _slide(const HomeScreen());
      case taskNew:
        return _slide(const TaskFormScreen());
      case taskDetail:
        return _slide(TaskDetailScreen(taskId: settings.arguments as String));
      case taskEdit:
        return _slide(TaskFormScreen(taskId: settings.arguments as String));
      default:
        return _slide(const LoginScreen());
    }
  }

  static PageRouteBuilder _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
            position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}