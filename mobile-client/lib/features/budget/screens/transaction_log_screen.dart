import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../models/budget_transaction.dart';
import '../widgets/add_transaction_sheet.dart';

class _TxData {
  final String id;
  final String merchant;
  final BudgetCategory category;
  final String dateLabel;
  final double amount;

  const _TxData({
    required this.id,
    required this.merchant,
    required this.category,
    required this.dateLabel,
    required this.amount,
  });
}

class TransactionLogScreen extends StatefulWidget {
  const TransactionLogScreen({super.key});

  @override
  State<TransactionLogScreen> createState() => _TransactionLogScreenState();
}

class _TransactionLogScreenState extends State<TransactionLogScreen> {
  final _searchCtrl = TextEditingController();
  String _activeFilter = 'All';

  final List<_TxData> _allTransactions = [
    const _TxData(
      id: 'tl1',
      merchant: 'Nasi Kandar Ali',
      category: BudgetCategory.dining,
      dateLabel: 'Today 12:30pm',
      amount: 24.50,
    ),
    const _TxData(
      id: 'tl2',
      merchant: 'Jaya Grocer',
      category: BudgetCategory.groceries,
      dateLabel: 'Yesterday',
      amount: 112.90,
    ),
    const _TxData(
      id: 'tl3',
      merchant: 'GrabFood',
      category: BudgetCategory.delivery,
      dateLabel: 'May 24',
      amount: 45.00,
    ),
    const _TxData(
      id: 'tl4',
      merchant: 'Kopitiam Old Town',
      category: BudgetCategory.dining,
      dateLabel: 'May 22',
      amount: 18.00,
    ),
    const _TxData(
      id: 'tl5',
      merchant: '99 Speedmart',
      category: BudgetCategory.groceries,
      dateLabel: 'May 20',
      amount: 34.00,
    ),
  ];

  late List<_TxData> _transactions;
  late List<_TxData> _undoBuffer;

  static const _filters = ['All', 'Dining', 'Groceries', 'Delivery'];

  @override
  void initState() {
    super.initState();
    _transactions = List.from(_allTransactions);
    _undoBuffer = [];
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_TxData> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _transactions.where((tx) {
      if (_activeFilter != 'All') {
        final catName = tx.category.label
            .toLowerCase()
            .replaceAll(' out', '');
        final filter = _activeFilter.toLowerCase();
        if (!catName.contains(filter)) return false;
      }
      if (q.isNotEmpty && !tx.merchant.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  void _delete(_TxData tx) {
    _undoBuffer = [tx];
    setState(() => _transactions.remove(tx));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction deleted',
            style: AppTypography.body1.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.neutral700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primaryLight,
          onPressed: () {
            if (_undoBuffer.isNotEmpty) {
              final restored = _undoBuffer.removeAt(0);
              final origIdx = _allTransactions.indexOf(restored);
              setState(() {
                final insertAt =
                    origIdx.clamp(0, _transactions.length);
                _transactions.insert(insertAt, restored);
              });
            }
          },
        ),
      ),
    );
  }

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
        title: const Text('Transactions'),
        leading: BackButton(
          color: AppColors.primary,
          onPressed: () =>
              context.mounted ? Navigator.of(context).pop() : null,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share,
                size: AppSpacing.iconMd, color: AppColors.neutral),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilters(),
            _buildSectionHeader(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTransactionSheet(context),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.search,
                    size: AppSpacing.iconSm, color: AppColors.neutral400),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: AppTypography.body1,
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: AppTypography.body1
                          .copyWith(color: AppColors.neutral400),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final active = _activeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(
                          color: active ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        f,
                        style: AppTypography.label.copyWith(
                          color: active ? AppColors.white : AppColors.neutral,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    final total =
        _filtered.fold(0.0, (sum, tx) => sum + tx.amount);
    return Container(
      height: 40,
      color: AppColors.neutral100,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Text('May 2026',
              style: AppTypography.headline3
                  .copyWith(color: AppColors.neutral)),
          const Spacer(),
          Text('RM ${total.toStringAsFixed(2)}',
              style: AppTypography.headline3
                  .copyWith(color: AppColors.neutral)),
        ],
      ),
    );
  }

  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Text('No transactions found', style: AppTypography.body2),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final tx = items[i];
        return Dismissible(
          key: ValueKey(tx.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Delete',
                    style: AppTypography.label
                        .copyWith(color: AppColors.white)),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.delete_outline,
                    color: AppColors.white, size: AppSpacing.iconMd),
              ],
            ),
          ),
          onDismissed: (_) => _delete(tx),
          child: _buildTxRow(tx),
        );
      },
    );
  }

  Widget _buildTxRow(_TxData tx) {
    final colors = _categoryColors(tx.category);
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.$1,
              shape: BoxShape.circle,
            ),
            child: Icon(_categoryIcon(tx.category),
                size: AppSpacing.iconSm, color: colors.$2),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(tx.merchant,
                    style: AppTypography.body1
                        .copyWith(fontWeight: FontWeight.w500)),
                Text('${tx.dateLabel} · ${tx.category.label}',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.neutral600)),
              ],
            ),
          ),
          Text(
            '-RM ${tx.amount.toStringAsFixed(2)}',
            style: AppTypography.body1
                .copyWith(fontWeight: FontWeight.w600, color: AppColors.neutral),
          ),
        ],
      ),
    );
  }

  (Color, Color) _categoryColors(BudgetCategory cat) {
    switch (cat) {
      case BudgetCategory.dining:
        return (AppColors.primaryLight, AppColors.primary);
      case BudgetCategory.groceries:
        return (AppColors.secondaryLight, AppColors.secondary);
      case BudgetCategory.delivery:
        return (AppColors.warningLight, const Color(0xFF92400E));
    }
  }

  IconData _categoryIcon(BudgetCategory cat) {
    switch (cat) {
      case BudgetCategory.dining:
        return Icons.restaurant_outlined;
      case BudgetCategory.groceries:
        return Icons.local_grocery_store_outlined;
      case BudgetCategory.delivery:
        return Icons.delivery_dining_outlined;
    }
  }
}
