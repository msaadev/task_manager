import 'package:flutter/material.dart';
import 'package:task_manager/core/routes/navigation_methods.dart';


class NavigationService implements NavigationMethods {
  NavigationService._init();
  static final NavigationService _instance = NavigationService._init();
  static NavigationService get instance => _instance;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  final removeAllOldRoutes = (Route<dynamic> route) => false;

  @override
  Future<dynamic> navigateToPage({String? path, Object? data}) async {
    return await navigatorKey.currentState!.pushNamed(path!, arguments: data);
  }

  @override
  Future<void> navigateToPageClear({String? path, Object? data}) async {
    await navigatorKey.currentState!
        .pushNamedAndRemoveUntil(path!, removeAllOldRoutes, arguments: data);
  }

  @override
  Future<T?> navigateToPageWidget<T>({required Widget page}) async {
    var navigate = await navigatorKey.currentState!
        .push<T>(MaterialPageRoute(builder: (_) => page));
    return navigate;
  }

  @override
  void pop() {
    navigatorKey.currentState!.pop();
  }
}
