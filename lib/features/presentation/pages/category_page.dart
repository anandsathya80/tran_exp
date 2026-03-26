import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/category_cubit.dart';

class CategoryPage extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        title: Text("Kategori"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 INPUT MODERN
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Icon(Icons.category, color: Colors.blue),

                  SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Tambah kategori...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  /// ➕ BUTTON ADD
                  GestureDetector(
                    onTap: () {
                      final text = controller.text.trim();

                      /// ❌ VALIDASI KOSONG
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Nama kategori tidak boleh kosong"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      /// ❌ OPTIONAL: DUPLIKAT (RECOMMENDED)
                      final categories =
                          context.read<CategoryCubit>().state.categories;
                      final isExist = categories.any(
                        (c) => c.name.toLowerCase() == text.toLowerCase(),
                      );

                      if (isExist) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Kategori sudah ada"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      /// ✅ SIMPAN DATA
                      context.read<CategoryCubit>().addCategory(text);

                      controller.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Kategori berhasil ditambahkan"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 20),

            /// 📋 LIST CATEGORY
            Expanded(
              child: BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state.categories.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada kategori",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: state.categories.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final category = state.categories[i];

                      return Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Color(0xFFF1F5F9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            /// 🎯 ICON
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.label, color: Colors.blue),
                            ),

                            SizedBox(width: 12),

                            /// 📌 NAME
                            Expanded(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            /// 🔥 OPTIONAL ACTION (NEXT UPGRADE)
                            Icon(Icons.more_vert, color: Colors.grey)
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
