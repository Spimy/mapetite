import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';

class BudgetAnalyticsScreen extends StatefulWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  State<BudgetAnalyticsScreen> createState() =>
      _BudgetAnalyticsScreenState();
}

class _BudgetAnalyticsScreenState extends State<BudgetAnalyticsScreen> {
  String _period = '30D';
  static const _periods = ['7D', '30D', '90D'];

  // Day-of-week index (Mon=0 … Sun=6) for today's highlight
  int get _todayIndex {
    final d = DateTime.now().weekday - 1; // Mon=0
    return d.clamp(0, 6);
  }

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Mock bar values per period
  List<double> get _barValues {
    switch (_period) {
      case '7D':
        return [45, 62, 28, 89, 55, 120, 21];
      case '90D':
        return [380, 420, 290, 510, 445, 360, 480];
      default: // 30D
        return [85, 110, 60, 145, 95, 120, 75];
    }
  }

  double get _weekTotal =>
      _barValues.fold(0.0, (s, v) => s + v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTypography.headline1.copyWith(color: AppColors.primary),
        title: const Text('Analytics'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(),
              const SizedBox(height: AppSpacing.lg),
              _buildBarChartCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildForecastCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildBottomGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Period Selector ──────────────────────────────────────────────────────

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: _periods.map((p) {
        final active = _period == p;
        return Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: GestureDetector(
            onTap: () => setState(() => _period = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                    color: active ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                p,
                style: AppTypography.label.copyWith(
                  color: active ? AppColors.white : AppColors.neutral,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Bar Chart Card ───────────────────────────────────────────────────────

  Widget _buildBarChartCard() {
    final values = _barValues;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final today = _todayIndex;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Spending', style: AppTypography.headline2),
          const SizedBox(height: 2),
          Text(
            'RM ${_weekTotal.toStringAsFixed(2)} this week',
            style: AppTypography.body2,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.4,
                barGroups: List.generate(values.length, (i) {
                  final isToday = i == today;
                  return BarChartGroupData(
                    x: i,
                    showingTooltipIndicators: isToday ? [0] : [],
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: isToday
                            ? AppColors.primary
                            : AppColors.secondary,
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSpacing.radiusMd)),
                      ),
                    ],
                  );
                }),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    tooltipRoundedRadius: AppSpacing.radiusMd,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'RM ${rod.toY.toStringAsFixed(0)}',
                        AppTypography.label
                            .copyWith(color: AppColors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= _dayLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          _dayLabels[i],
                          style: AppTypography.caption.copyWith(
                              color: AppColors.neutral600),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AI Forecast Card ─────────────────────────────────────────────────────

  Widget _buildForecastCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome,
                    size: AppSpacing.iconSm, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('AI Forecast', style: AppTypography.headline3),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          RichText(
            text: TextSpan(
              style: AppTypography.body1
                  .copyWith(color: AppColors.neutral700),
              children: [
                const TextSpan(
                    text:
                        'At this rate, you will spend approximately '),
                TextSpan(
                  text: 'RM 570',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                    text:
                        ' this week. Consider reducing dining out to stay under your RM 500 goal.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Grid (donut + top venues) ────────────────────────────────────

  Widget _buildBottomGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDonutCard()),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: _buildTopVenuesCard()),
            ],
          );
        }
        return Column(
          children: [
            _buildDonutCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildTopVenuesCard(),
          ],
        );
      },
    );
  }

  Widget _buildDonutCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories', style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 60,
                    color: AppColors.primary,
                    radius: 50,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 29,
                    color: AppColors.secondary,
                    radius: 50,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 11,
                    color: AppColors.warning,
                    radius: 50,
                    showTitle: false,
                  ),
                ],
                centerSpaceRadius: 50,
                sectionsSpace: 2,
                startDegreeOffset: -90,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final items = [
      (AppColors.primary, 'Dining', '60%'),
      (AppColors.secondary, 'Groceries', '29%'),
      (AppColors.warning, 'Delivery', '11%'),
    ];
    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.$1,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: Text(item.$2, style: AppTypography.body2)),
                    Text(item.$3, style: AppTypography.body2),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTopVenuesCard() {
    const venues = [
      (
        icon: Icons.restaurant_outlined,
        bg: AppColors.primaryLight,
        fg: AppColors.primary,
        name: 'Nasi Kandar Ali',
        detail: '6 visits · Dining',
        amount: 145.0,
      ),
      (
        icon: Icons.local_grocery_store_outlined,
        bg: AppColors.secondaryLight,
        fg: AppColors.secondary,
        name: 'Jaya Grocer',
        detail: '3 visits · Groceries',
        amount: 120.0,
      ),
      (
        icon: Icons.delivery_dining_outlined,
        bg: AppColors.warningLight,
        fg: Color(0xFF92400E),
        name: 'GrabFood',
        detail: '2 orders · Delivery',
        amount: 45.0,
      ),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Venues', style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.md),
          ...venues.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: v.bg,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child:
                          Icon(v.icon, size: AppSpacing.iconSm, color: v.fg),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.name, style: AppTypography.headline3),
                          Text(v.detail,
                              style: AppTypography.caption.copyWith(
                                  color: AppColors.neutral600)),
                        ],
                      ),
                    ),
                    Text(
                      'RM ${v.amount.toStringAsFixed(0)}',
                      style: AppTypography.headline3,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Card Container ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
