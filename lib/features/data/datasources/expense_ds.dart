import 'package:hive/hive.dart';
import '../models/expense_model.dart';

class ExpenseLocalDataSource {
  final box = Hive.box('expenses');

  List<Expense> getExpenses() {
    return box.values
        .map((e) => Expense.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  void addExpense(Expense expense) {
    box.put(expense.id, expense.toJson());
  }
}
