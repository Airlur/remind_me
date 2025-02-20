import 'package:flutter/material.dart';
import 'package:remind_me/models/category.dart';
class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _controller = TextEditingController();
  String? _selectedIcon;

  // 常用图标列表
  final _icons = [
    Icons.home_outlined,
    Icons.work_outline,
    Icons.school_outlined,
    Icons.favorite_outline,
    Icons.shopping_cart_outlined,
    Icons.sports_esports_outlined,
    Icons.restaurant_outlined,
    Icons.local_hospital_outlined,
    Icons.flight_outlined,
    Icons.fitness_center_outlined,
    Icons.pets_outlined,
    Icons.family_restroom_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '新增分类',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '请输入分类名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('选择图标（可选）'),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final iconData = _icons[index];
                  final isSelected = _selectedIcon == iconData.codePoint.toString();
                  
                  return InkWell(
                    onTap: () => setState(() {
                      _selectedIcon = isSelected ? null : iconData.codePoint.toString();
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Icon(
                        iconData,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      final category = Category(
                        name: _controller.text,
                        iconName: _selectedIcon,
                      );
                      Navigator.pop(context, category);
                    }
                  },
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 