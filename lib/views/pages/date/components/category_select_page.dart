import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/event/event_state.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/models/category.dart';
import 'package:remind_me/views/pages/date/components/add_category_dialog.dart';
import 'package:remind_me/views/pages/date/components/edit_category_dialog.dart';

class CategorySelectPage extends StatelessWidget {
  final String? selectedCategory;

  const CategorySelectPage({
    super.key,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('选择分类')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            final categories = state.categories;
            
            return Card(
              margin: EdgeInsets.zero,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: Text(
                      '全部',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedCategory == null 
                            ? theme.colorScheme.primary 
                            : null,
                      ),
                    ),
                    selected: selectedCategory == null,
                    trailing: selectedCategory == null 
                        ? Icon(Icons.check, size: 20, color: theme.colorScheme.primary) 
                        : null,
                    onTap: () => Navigator.pop(context, null),
                  ),
                  ...categories.map((category) => Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) {
                            _showEditCategoryDialog(context, category);
                          },
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: '编辑',
                        ),
                        SlidableAction(
                          onPressed: (_) {
                            context.read<EventBloc>().add(
                              DeleteCategory(category.name),
                            );
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: '删除',
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(
                        category.iconName != null 
                            ? IconData(int.parse(category.iconName!), fontFamily: 'MaterialIcons')
                            : Icons.folder_outlined,
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedCategory == category.name 
                              ? theme.colorScheme.primary 
                              : null,
                        ),
                      ),
                      selected: selectedCategory == category.name,
                      trailing: selectedCategory == category.name 
                          ? Icon(Icons.check, size: 20, color: theme.colorScheme.primary) 
                          : null,
                      onTap: () => Navigator.pop(context, category),
                    ),
                  )),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
          shape: const CircleBorder(),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final result = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddCategoryDialog(),
    );
    
    if (result != null && context.mounted) {
      context.read<EventBloc>().add(AddCategory(result));
    }
  }

  // 编辑分类对话框
  Future<void> _showEditCategoryDialog(BuildContext context, Category category) async {
    final oldName = category.name;
    
    final result = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditCategoryDialog(category: category),
    );

    if (result != null && context.mounted) {
      context.read<EventBloc>().add(
        UpdateCategory(
          category: result,
          oldName: oldName,
        ),
      );
    }
  }
} 