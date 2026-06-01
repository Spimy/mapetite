import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SpendingAnalyticsScreen extends StatelessWidget {
  final String? categoryFilter;

  const SpendingAnalyticsScreen({super.key, this.categoryFilter});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Spending Analytics — coming soon')),
    );
  }
}
