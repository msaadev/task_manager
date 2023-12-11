import 'package:flutter/material.dart';

abstract class NavigationMethods {
  Future<void> navigateToPage({String? path, Object? data});
  Future<T?> navigateToPageWidget<T>({required Widget page});
  void pop();
  Future<void> navigateToPageClear({String? path, Object? data});
}
