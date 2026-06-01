import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';

class BudgetBarChart extends StatelessWidget {
  /// Monthly spending amounts. Index 0 = oldest, last index = current month.
  final List<double> monthlyAmounts;

  /// Labels for each bar (e.g. ["Nov", "Dec", "Jan", "Feb"]).
  final List<String> monthLabels;

  /// Horizontal dashed goal line value.
  final double goal;

  const BudgetBarChart({
    super.key,
    required this.monthlyAmounts,
    required this.monthLabels,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final currentIdx = monthlyAmounts.length - 1;
    final maxY = ([...monthlyAmounts, goal].reduce((a, b) => a > b ? a : b) * 1.2)
        .ceilToDouble();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.neutral,
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${monthLabels[group.x]}\nRM ${rod.toY.toStringAsFixed(0)}',
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
                  if (idx < 0 || idx >= monthLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    monthLabels[idx],
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
          barGroups: List.generate(monthlyAmounts.length, (i) {
            final isCurrent = i == currentIdx;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: monthlyAmounts[i],
                  width: 28,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  color: isCurrent
                      ? AppColors.primary
                      : AppColors.secondaryLight,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
