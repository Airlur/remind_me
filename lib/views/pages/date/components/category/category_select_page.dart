import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/event/event_state.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/models/category.dart';
import 'package:remind_me/views/pages/date/components/category/add_category_dialog.dart';
import 'package:remind_me/views/pages/date/components/category/edit_category_dialog.dart';
import 'package:remind_me/utils/common/logger_utils.dart';

class CategorySelectPage extends StatefulWidget {
  final String? selectedCategory;

  const CategorySelectPage({
    super.key,
    this.selectedCategory,
  });

  @override
  State<CategorySelectPage> createState() => _CategorySelectPageState();
}

class _CategorySelectPageState extends State<CategorySelectPage> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    // 在页面构建时加载分类数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventBloc>().add(const LoadCategories());
    });

    final theme = Theme.of(context);
    
    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state.status == EventStatus.success && 
            state.lastEvent is DeleteCategory) {
          setState(() {
            _selectedCategory = null;  // 选中"全部"分类
          });
        }
      },
      child: Scaffold(
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
                          color: _selectedCategory == null 
                              ? theme.colorScheme.primary 
                              : null,
                        ),
                      ),
                      selected: _selectedCategory == null,
                      trailing: _selectedCategory == null 
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
                              LoggerUtils.i('点击删除分类: ${category.name}', 'CategorySelectPage');
                              context.read<EventBloc>().add(DeleteCategory(category.name));
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
                            color: _selectedCategory == category.name 
                                ? theme.colorScheme.primary 
                                : null,
                          ),
                        ),
                        selected: _selectedCategory == category.name,
                        trailing: _selectedCategory == category.name 
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