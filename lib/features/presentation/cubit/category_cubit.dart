import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/category_ds.dart';
import '../../data/models/category_model.dart';

class CategoryState {
  final List<Category> categories;

  CategoryState(this.categories);
}

class CategoryCubit extends Cubit<CategoryState> {
  final ds = CategoryLocalDataSource();

  CategoryCubit() : super(CategoryState([]));

  void loadCategories() {
    emit(CategoryState(ds.getCategories()));
  }

  void addCategory(String name) {
    final category = Category(
      id: DateTime.now().toString(),
      name: name,
    );

    ds.addCategory(category);
    loadCategories();
  }
}
