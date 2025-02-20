import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 3)
class Category extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? iconName;  // 可选的图标名称

  Category({
    required this.name,
    this.iconName,
  });

  // 复制对象并修改部分属性
  Category copyWith({
    String? name,
    String? iconName,
  }) {
    return Category(
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
    );
  }
} 