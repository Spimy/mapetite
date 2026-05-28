import 'package:flutter/material.dart';

abstract class AppRoutes {
  static const String discovery = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String restaurants = '/restaurants';
  static const String groceries = '/groceries';
  static const String recipes = '/recipes';
  static const String groceryList = '/grocery-list';
  static const String budget = '/budget';
  static const String routing = '/routing';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
