class Category {
  final String id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory Category.fromJson(Map data) => Category(
        id: data['id'],
        name: data['name'],
      );
}