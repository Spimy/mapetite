import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget_state.dart';
import '../models/budget_transaction.dart';
import '../models/mocks/budget_mocks.dart';
import '../../profile/controllers/profile_setup_controller.dart';

class BudgetNotifier extends StateNotifier<BudgetState> {
  BudgetNotifier(super.initial);

  void addTransaction(BudgetTransaction t) =>
      state = state.copyWith(transactions: [t, ...state.transactions]);

  void deleteTransaction(String id) => state = state.copyWith(
        transactions: state.transactions.where((t) => t.id != id).toList(),
      );

  void adjustBudget({double? monthly, double? groceries, double? dining}) =>
      state = state.copyWith(
        monthlyBudget: monthly,
        groceriesBudget: groceries,
        diningBudget: dining,
      );
}

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  final profile = ref.read(profileSetupControllerProvider);
  return BudgetNotifier(BudgetState(
    transactions: BudgetMocks.transactions,
    monthlyBudget: profile.monthlyBudget,
    groceriesBudget: profile.groceriesBudget,
    diningBudget: profile.diningBudget,
  ));
});
