import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/expense_model.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;

  const ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.wallet, color: Colors.blue),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(expense.category, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(
            rupiah.format(expense.amount),
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
