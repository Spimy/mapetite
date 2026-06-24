import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';

class BudgetBarChart extends StatelessWidget {
  /// Groceries spending per period. Index 0 = oldest, last = current.
  final List<double> groceriesAmounts;

  /// Dining spending per period. Same ordering as groceriesAmounts.
  final List<double> diningAmounts;

  /// Labels for each bar group (e.g. ["Mar", "Apr", "May", "Jun"]).
  final List<String> periodLabels;

  /// Horizontal dashed goal line value.
  final double goal;

  const BudgetBarChart({
    super.key,
    required this.groceriesAmounts,
    required this.diningAmounts,
    required this.periodLabels,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final currentIdx = groceriesAmounts.length - 1;
    final allValues = [...groceriesAmounts, ...diningAmounts, goal];
    final maxY =
        (allValues.reduce((a, b) => a > b ? a : b) * 1.25).ceilToDouble();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              groupsSpace: 12,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.neutral,
                  getTooltipItem: (group, _, rod, rodIdx) => BarTooltipItem(
                    '${rodIdx == 0 ? "Groceries" : "Dining"}\nRM ${rod.toY.toStringAsFixed(0)}',
                    AppTypography.label.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, _) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= periodLabels.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        periodLabels[idx],
                        style: AppTypography.caption.copyWith(
                          fontWeight: idx == currentIdx
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: idx == currentIdx
                              ? AppColors.primary
                              : AppColors.neutral600,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: goal,
                    color: AppColors.neutral400,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 4, bottom: 2),
                      style: AppTypography.caption
                          .copyWith(color: AppColors.neutral600),
                      labelResolver: (line) =>
                          'Goal: RM ${line.y.toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
              barGroups: List.generate(groceriesAmounts.length, (i) {
                final isCurrent = i == currentIdx;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: groceriesAmounts[i],
                      width: 14,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      color: isCurrent
                          ? AppColors.primary
                          : AppColors.primaryLight,
                    ),
                    BarChartRodData(
                      toY: diningAmounts[i],
                      width: 14,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      color: isCurrent
                          ? AppColors.warning
                          : AppColors.warningLight,
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: AppColors.primary, label: 'Groceries'),
            SizedBox(width: AppSpacing.lg),
            _LegendDot(color: AppColors.warning, label: 'Dining Out'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label,
            style: AppTypography.caption
                .copyWith(color: AppColors.neutral600)),
      ],
    );
  }
}
