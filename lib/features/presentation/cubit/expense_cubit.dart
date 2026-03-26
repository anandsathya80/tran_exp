import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/expense_ds.dart';
import '../../data/models/expense_model.dart';

class ExpenseState {
  final List<Expense> expenses;

  ExpenseState(this.expenses);
}

class ExpenseCubit extends Cubit<ExpenseState> {
  final ds = ExpenseLocalDataSource();

  ExpenseCubit() : super(ExpenseState([]));

  void loadExpenses() {
    emit(ExpenseState(ds.getExpenses()));
  }

  void addExpense(Expense expense) {
    ds.addExpense(expense);
    loadExpenses();
  }

  double get total => state.expenses.fold(0, (sum, e) => sum + e.amount);
}
