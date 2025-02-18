import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/blocs/event/event_state.dart';

class SortDialog extends StatelessWidget {
  const SortDialog({super.key});

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
                title: '剩余天数',
                selected: state.sortType == SortType.remainingDays,
                sortOrder: state.sortType == SortType.remainingDays ? state.sortOrder : null,
                onTap: () => _updateSortType(context, SortType.remainingDays),
                onSortOrderTap: () => _toggleSortOrder(context, state),
              ),
              _buildCategoryOption(context, state),
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

  Widget _buildCategoryOption(BuildContext context, EventState state) {
    return ListTile(
      leading: const Icon(Icons.category),
      title: Text(state.selectedCategory ?? '全部'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showCategoryDialog(context, state),
    );
  }

  void _showCategoryDialog(BuildContext context, EventState state) {
    // 获取所有不重复的分类
    final categories = state.events
        .map((e) => e.category)
        .where((c) => c != null)
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('全部'),
              selected: state.selectedCategory == null,
              trailing: state.selectedCategory == null
                  ? const Icon(Icons.check, size: 20)
                  : null,
              onTap: () {
                context.read<EventBloc>().add(
                  const UpdateSortConfig(
                    selectedCategory: null,
                  ),
                );
                // Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ...categories.map((category) => ListTile(
              title: Text(category!),
              selected: state.selectedCategory == category,
              trailing: state.selectedCategory == category
                  ? const Icon(Icons.check, size: 20)
                  : null,
              onTap: () {
                context.read<EventBloc>().add(
                  UpdateSortConfig(
                    selectedCategory: category,
                  ),
                );
                // Navigator.pop(context);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _updateSortType(BuildContext context, SortType sortType) {
    context.read<EventBloc>().add(UpdateSortConfig(sortType: sortType));
    // Navigator.pop(context);
  }

  void _toggleSortOrder(BuildContext context, EventState state) {
    final newOrder = state.sortOrder == SortOrder.ascending
        ? SortOrder.descending
        : SortOrder.ascending;
    context.read<EventBloc>().add(UpdateSortConfig(sortOrder: newOrder));
  }
} 