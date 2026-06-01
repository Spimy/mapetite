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
  String _periodFilter = 'This Month';
  final Set<BudgetCategory> _categoryFilters = {};

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
      if (_periodFilter == 'This Month') {
        if (t.dateTime.year != now.year || t.dateTime.month != now.month) {
          return false;
        }
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

  /// Groups a sorted list of transactions by date label.
  Map<String, List<BudgetTransaction>> _grouped(
      List<BudgetTransaction> sorted) {
    final map = <String, List<BudgetTransaction>>{};
    for (final t in sorted) {
      final label = _dateLabel(t.dateTime);
      map.putIfAbsent(label, () => []).add(t);
    }
    return map;
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(txDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.neutral),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search + filters (sticky above the list)
            _buildSearchAndFilters(),
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

  Widget _buildSearchAndFilters() {
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
              hintStyle: AppTypography.body1
                  .copyWith(color: AppColors.neutral400),
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.neutral400, size: AppSpacing.iconSm),
              filled: true,
              fillColor: AppColors.neutral100,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'This Month',
                  selected: _periodFilter == 'This Month',
                  onTap: () => setState(() => _periodFilter =
                      _periodFilter == 'This Month' ? 'All' : 'This Month'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Groceries',
                  selected:
                      _categoryFilters.contains(BudgetCategory.groceries),
                  onTap: () =>
                      _toggleCategory(BudgetCategory.groceries),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Dining Out',
                  selected:
                      _categoryFilters.contains(BudgetCategory.dining),
                  onTap: () =>
                      _toggleCategory(BudgetCategory.dining),
                ),
              ],
            ),
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
          padding: const EdgeInsets.only(
              top: AppSpacing.lg, bottom: AppSpacing.sm),
          child: Text(label,
              style:
                  AppTypography.label.copyWith(color: AppColors.neutral600)),
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
                    onTap: () =>
                        showTransactionDetailSheet(context, txs[i]),
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
              style: AppTypography.body1
                  .copyWith(color: AppColors.neutral600)),
          const SizedBox(height: AppSpacing.xs),
          Text('Try adjusting your filters',
              style: AppTypography.body2),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
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
