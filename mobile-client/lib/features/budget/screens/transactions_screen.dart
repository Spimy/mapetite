import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../models/budget_transaction.dart';
import '../providers/budget_provider.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transaction_detail_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchCtrl = TextEditingController();

  // Mutually exclusive period filters
  String _periodFilter = 'This Month';

  // Multi-select category filters
  final Set<BudgetCategory> _categoryFilters = {};

  static const List<String> _periods = ['All', 'This Month', 'This Week'];

  static const List<String> _monthAbbrs = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BudgetTransaction> _filtered(List<BudgetTransaction> all) {
    final now = DateTime.now();
    return all.where((t) {
      // Period filter
      switch (_periodFilter) {
        case 'This Month':
          if (t.dateTime.year != now.year || t.dateTime.month != now.month) {
            return false;
          }
        case 'This Week':
          final weekStart = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1));
          if (t.dateTime.isBefore(weekStart)) return false;
        default:
          break; // All — no date restriction
      }

      // Category filter
      if (_categoryFilters.isNotEmpty &&
          !_categoryFilters.contains(t.category)) {
        return false;
      }

      // Search
      final q = _searchCtrl.text.trim().toLowerCase();
      if (q.isNotEmpty &&
          !t.name.toLowerCase().contains(q) &&
          !t.category.label.toLowerCase().contains(q)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Maybank-style progressive date grouping.
  String _groupLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(txDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) {
      return '${_weekdays[dt.weekday - 1]}, ${_monthAbbrs[dt.month - 1]} ${dt.day}';
    }
    if (diff < 14) return 'Last Week';
    if (dt.year == now.year && dt.month == now.month) {
      return 'Earlier this Month';
    }
    return '${_monthAbbrs[dt.month - 1]} ${dt.year}';
  }

  Map<String, List<BudgetTransaction>> _grouped(
      List<BudgetTransaction> sorted) {
    final map = <String, List<BudgetTransaction>>{};
    for (final t in sorted) {
      map.putIfAbsent(_groupLabel(t.dateTime), () => []).add(t);
    }
    return map;
  }

  void _toggleCategory(BudgetCategory cat) {
    setState(() {
      if (_categoryFilters.contains(cat)) {
        _categoryFilters.remove(cat);
      } else {
        _categoryFilters.add(cat);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);
    final sorted = budget.allSortedDesc;
    final filtered = _filtered(sorted);
    final grouped = _grouped(filtered);
    final dateKeys = grouped.keys.toList();

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
        title: const Text('Transactions'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontalPadding,
                        vertical: AppSpacing.lg,
                      ),
                      itemCount: dateKeys.length,
                      itemBuilder: (context, i) {
                        final label = dateKeys[i];
                        final txs = grouped[label]!;
                        return _buildGroup(label, txs);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchCtrl,
            style: AppTypography.body1,
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              hintStyle:
                  AppTypography.body1.copyWith(color: AppColors.neutral400),
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.neutral400, size: AppSpacing.iconSm),
              filled: true,
              fillColor: AppColors.neutral100,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.md),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Period — mutually exclusive
          _FilterRow(
            label: 'Period',
            children: _periods.map((p) {
              return _Chip(
                label: p,
                selected: _periodFilter == p,
                onTap: () => setState(() => _periodFilter = p),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Category — multi-select
          _FilterRow(
            label: 'Category',
            children: [
              _Chip(
                label: 'Groceries',
                selected:
                    _categoryFilters.contains(BudgetCategory.groceries),
                onTap: () => _toggleCategory(BudgetCategory.groceries),
                activeColor: AppColors.primary,
              ),
              _Chip(
                label: 'Dining Out',
                selected:
                    _categoryFilters.contains(BudgetCategory.dining),
                onTap: () => _toggleCategory(BudgetCategory.dining),
                activeColor: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(String label, List<BudgetTransaction> txs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
          child: Text(label,
              style: AppTypography.label.copyWith(color: AppColors.neutral600)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Column(
              children: [
                for (int i = 0; i < txs.length; i++)
                  TransactionTile(
                    transaction: txs[i],
                    showDivider: i < txs.length - 1,
                    onTap: () => showTransactionDetailSheet(context, txs[i]),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 48, color: AppColors.neutral400),
          const SizedBox(height: AppSpacing.md),
          Text('No transactions found',
              style:
                  AppTypography.body1.copyWith(color: AppColors.neutral600)),
          const SizedBox(height: AppSpacing.xs),
          Text('Try adjusting your filters', style: AppTypography.body2),
        ],
      ),
    );
  }
}

// ─── Filter row with a small label ───────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _FilterRow({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label,
              style: AppTypography.caption.copyWith(color: AppColors.neutral600)),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Individual filter chip ───────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? activeColor : AppColors.white,
          border: Border.all(
            color: selected ? activeColor : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: selected ? AppColors.white : AppColors.neutral,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
