import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/blocs/event/event_state.dart';
import 'package:remind_me/views/pages/date/components/category/category_select_page.dart';
import 'package:remind_me/models/category.dart';

class SortDialog extends StatelessWidget {
  const SortDialog({super.key});

  IconData _getCategoryIcon(List<Category> categories, String? categoryName) {
    try {
      final category = categories.firstWhere((c) => c.name == categoryName);
      if (category.iconName != null) {
        return IconData(int.parse(category.iconName!), fontFamily: 'MaterialIcons');
      }
    } catch (_) {}
    return Icons.folder_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Theme.of(context).colorScheme.surface,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          buttonPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption(
                context: context,
                icon: Icons.access_time,
                title: '创建时间',
                selected: state.sortType == SortType.createTime,
                sortOrder: state.sortType == SortType.createTime ? state.sortOrder : null,
                onTap: () => _updateSortType(context, SortType.createTime),
                onSortOrderTap: () => _toggleSortOrder(context, state),
              ),
              _buildSortOption(
                context: context,
                icon: Icons.calendar_today,
                title: '天数跨度',
                selected: state.sortType == SortType.dayCount,
                sortOrder: state.sortType == SortType.dayCount ? state.sortOrder : null,
                onTap: () => _updateSortType(context, SortType.dayCount),
                onSortOrderTap: () => _toggleSortOrder(context, state),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('分类'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.selectedCategory != null) Icon(
                      _getCategoryIcon(state.categories, state.selectedCategory),
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    if (state.selectedCategory != null) const SizedBox(width: 4),
                    Text(
                      state.selectedCategory ?? '全部',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
                onTap: () => _showCategoryPicker(context, state.selectedCategory),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
    required VoidCallback? onSortOrderTap,
    SortOrder? sortOrder,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (selected) {
            onSortOrderTap?.call();
          } else {
            onTap();
          }
        },
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          selected: selected,
          trailing: selected ? Icon(
            sortOrder == SortOrder.ascending
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            size: 20,
          ) : null,
          minLeadingWidth: 0,
          horizontalTitleGap: 12,
        ),
      ),
    );
  }

  void _updateSortType(BuildContext context, SortType sortType) {
    context.read<EventBloc>().add(UpdateSortConfig(sortType: sortType));
  }

  void _toggleSortOrder(BuildContext context, EventState state) {
    final newOrder = state.sortOrder == SortOrder.ascending
        ? SortOrder.descending
        : SortOrder.ascending;
    context.read<EventBloc>().add(UpdateSortConfig(sortOrder: newOrder));
  }

  Future<void> _showCategoryPicker(BuildContext context, String? selectedCategory) async {
    final result = await Navigator.push<Category>(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectPage(
          selectedCategory: selectedCategory,
        ),
      ),
    );
    
    if (context.mounted) {
      context.read<EventBloc>().add(
        UpdateSortConfig(selectedCategory: result?.name),
      );
    }
  }
} 