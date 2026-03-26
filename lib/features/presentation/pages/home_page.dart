import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../cubit/expense_cubit.dart';
import '../cubit/category_cubit.dart';
import '../widgets/expense_card.dart';
import '../../data/models/expense_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'category_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedCategoryFilter;
  String selectedDateFilter = "All"; // All, Today, 7 Days, 30 Days, Custom

  /// 🎨 WARNA KATEGORI
  final List<Color> categoryColors = const [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
  ];

  Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  /// 📊 DATA PIE CHART
  Map<String, double> getCategoryData(List<Expense> expenses) {
    final Map<String, double> data = {};

    for (var e in expenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }

    return data;
  }

  List<Expense> getFilteredExpenses(List<Expense> expenses) {
    DateTime now = DateTime.now();

    DateTime? start;
    DateTime? end;

    if (selectedDateFilter == "Today") {
      start = DateTime(now.year, now.month, now.day);
      end = start.add(Duration(days: 1));
    } else if (selectedDateFilter == "7 Days") {
      start = now.subtract(Duration(days: 7));
    } else if (selectedDateFilter == "30 Days") {
      start = now.subtract(Duration(days: 30));
    } else if (selectedDateFilter == "Custom") {
      start = startDate;
      end = endDate;
    }

    return expenses.where((e) {
      final matchCategory = selectedCategoryFilter == null ||
          e.category == selectedCategoryFilter;

      final matchStart = start == null || e.date.isAfter(start);
      final matchEnd = end == null || e.date.isBefore(end);

      return matchCategory && matchStart && matchEnd;
    }).toList();
  }

  /// 🧩 INPUT COMPONENT
  Widget buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          icon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  /// 🔥 BOTTOM SHEET TAMBAH EXPENSE
  void showAddExpenseSheet(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// HANDLE
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Tambah Pengeluaran",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  buildInput(
                    controller: titleController,
                    hint: "Judul",
                    icon: Icons.edit,
                  ),

                  const SizedBox(height: 12),

                  buildInput(
                    controller: amountController,
                    hint: "Jumlah",
                    icon: Icons.attach_money,
                    isNumber: true,
                  ),

                  const SizedBox(height: 12),

                  /// DROPDOWN
                  BlocBuilder<CategoryCubit, CategoryState>(
                    builder: (context, state) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FB),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          hint: const Text("Pilih kategori"),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(Icons.category),
                          ),
                          items: state.categories
                              .map((e) => DropdownMenuItem(
                                    value: e.name,
                                    child: Text(e.name),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() => selectedCategory = val);
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON SIMPAN + VALIDASI
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        final amountText = amountController.text.trim();

                        /// VALIDASI
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Judul tidak boleh kosong"),
                          ));
                          return;
                        }

                        if (amountText.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Jumlah tidak boleh kosong"),
                          ));
                          return;
                        }

                        final amount = double.tryParse(amountText);

                        if (amount == null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Jumlah harus angka"),
                          ));
                          return;
                        }

                        if (amount <= 0) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Jumlah harus lebih dari 0"),
                          ));
                          return;
                        }

                        if (selectedCategory == null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Pilih kategori"),
                          ));
                          return;
                        }

                        final expense = Expense(
                          id: DateTime.now().toString(),
                          title: title,
                          amount: amount,
                          category: selectedCategory!,
                          date: DateTime.now(),
                        );

                        context.read<ExpenseCubit>().addExpense(expense);

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Berhasil tambah pengeluaran"),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Simpan"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ExpenseCubit>();

    final filteredExpenses = getFilteredExpenses(cubit.state.expenses);

    final data = getCategoryData(filteredExpenses);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Expense Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoryPage()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF6FCF97)],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Text("Total Pengeluaran",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    rupiah.format(cubit.total),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 📅 DATE FILTER CHIP
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ["All", "Today", "7 Days", "30 Days", "Custom"]
                        .map((label) {
                      final isSelected = selectedDateFilter == label;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (_) async {
                            if (label == "Custom") {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );

                              if (picked != null) {
                                setState(() {
                                  startDate = picked.start;
                                  endDate = picked.end;
                                  selectedDateFilter = "Custom";
                                });
                              }
                            } else {
                              setState(() {
                                selectedDateFilter = label;
                              });
                            }
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 10),

                /// 📂 CATEGORY CHIP
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    return SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          /// ALL CHIP
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text("Semua"),
                              selected: selectedCategoryFilter == null,
                              onSelected: (_) {
                                setState(() => selectedCategoryFilter = null);
                              },
                            ),
                          ),

                          ...state.categories.map((cat) {
                            final isSelected =
                                selectedCategoryFilter == cat.name;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat.name),
                                selected: isSelected,
                                selectedColor: Colors.green,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    selectedCategoryFilter =
                                        isSelected ? null : cat.name;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 10),

                /// 🔄 RESET
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        selectedCategoryFilter = null;
                        selectedDateFilter = "All";
                        startDate = null;
                        endDate = null;
                      });
                    },
                    child: Text("Reset Filter"),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  /// 📅 DATE FILTER
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setState(() => startDate = picked);
                            }
                          },
                          child: Text(startDate == null
                              ? "Start Date"
                              : startDate.toString().split(" ")[0]),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setState(() => endDate = picked);
                            }
                          },
                          child: Text(endDate == null
                              ? "End Date"
                              : endDate.toString().split(" ")[0]),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  /// 📂 CATEGORY FILTER
                  BlocBuilder<CategoryCubit, CategoryState>(
                    builder: (context, state) {
                      return DropdownButtonFormField<String>(
                        value: selectedCategoryFilter,
                        hint: Text("Filter kategori"),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text("Semua"),
                          ),
                          ...state.categories.map(
                            (e) => DropdownMenuItem(
                              value: e.name,
                              child: Text(e.name),
                            ),
                          )
                        ],
                        onChanged: (val) {
                          setState(() => selectedCategoryFilter = val);
                        },
                      );
                    },
                  ),

                  SizedBox(height: 10),

                  /// 🔄 RESET FILTER
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          startDate = null;
                          endDate = null;
                          selectedCategoryFilter = null;
                        });
                      },
                      child: Text("Reset Filter"),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// PIE CHART + LEGEND
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  const Text("Pengeluaran per Kategori",
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  /// PIE
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections:
                            data.entries.toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          final value = item.value;
                          final total = cubit.total == 0 ? 1 : cubit.total;

                          return PieChartSectionData(
                            value: value,
                            color: getCategoryColor(index),
                            title:
                                "${((value / total) * 100).toStringAsFixed(0)}%",
                            radius: 60,
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// LEGEND
                  Column(
                    children:
                        data.entries.toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: getCategoryColor(index),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item.key)),
                            Text(rupiah.format(item.value)),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredExpenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                return ExpenseCard(
                  expense: filteredExpenses[i],
                );
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddExpenseSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
