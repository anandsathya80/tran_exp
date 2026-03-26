import 'package:hive/hive.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  final box = Hive.box('categories');

  List<Category> getCategories() {
    return box.values
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  void addCategory(Category category) {
    box.put(category.id, category.toJson());
  }
}
