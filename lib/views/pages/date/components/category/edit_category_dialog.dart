import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/models/category.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/blocs/event/event_state.dart';
import 'package:remind_me/theme/app_colors.dart';

class EditCategoryDialog extends StatefulWidget {
  final Category category;

  const EditCategoryDialog({
    super.key,
    required this.category,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late TextEditingController _controller;
  String? _selectedIcon;
  String? _errorText;

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
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.iconName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listenWhen: (previous, current) {
        // 监听所有状态变化
        return true;
      },
      listener: (context, state) {
        if (state.status == EventStatus.failure && state.error != null) {
          setState(() {
            _errorText = state.error;
          });
        } else if (state.status == EventStatus.success) {
          // 成功时清除错误并关闭对话框
          setState(() {
            _errorText = null;
          });
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '编辑分类',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '请输入分类名称',
                  border: const OutlineInputBorder(),
                  errorText: _errorText,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        final category = Category(
                          name: _controller.text,
                          iconName: _selectedIcon,
                        );
                        context.read<EventBloc>().add(
                          UpdateCategory(
                            category: category,
                            oldName: widget.category.name,
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '确定',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 