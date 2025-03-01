import 'package:flutter/material.dart';
import '../../widgets/common/swipe_action_card.dart';

class TimePage extends StatelessWidget {
  const TimePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟一些测试数据
    final items = List.generate(
      5,
      (index) => TimeItem(title: '测试项目 ${index + 1}'),
    );

    // 定义圆角值
    final borderRadius = BorderRadius.circular(10);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 64),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SwipeActionCard(
              startActions: [
                SwipeAction(
                  flex: 1,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info, color: Colors.white),
                      SizedBox(width: 8),
                      Text('详情', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  backgroundColor: Colors.blue,
                  onTrigger: () => print('详情 ${items[index].title}'),
                ),
                SwipeAction(
                  flex: 1,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin, color: Colors.white),
                      SizedBox(width: 8),
                      Text('置顶', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  onTrigger: () => print('置顶 ${items[index].title}'),
                ),
                SwipeAction(
                  flex: 1,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timeline, color: Colors.white),
                      SizedBox(width: 8),
                      Text('时间线', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  onTrigger: () => print('时间线 ${items[index].title}'),
                ),
              ],
              endActions: [
                // 添加取消操作
                SwipeAction(
                  flex: 1,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cancel, color: Colors.white),
                      SizedBox(width: 8),
                      Text('取消', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  backgroundColor: Colors.grey,
                  onTrigger: () {
                    // 取消操作，恢复到原位
                    print('取消 ${items[index].title}');
                  },
                ),
                SwipeAction(
                  flex: 1,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 8),
                      Text('编辑', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  backgroundColor: Colors.amber,
                  onTrigger: () => print('编辑 ${items[index].title}'),
                ),
                SwipeAction(
                  flex: 1,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  onTrigger: () => print('删除 ${items[index].title}'),
                ),
                SwipeAction(
                  flex: 1,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share, color: Colors.white),
                      SizedBox(width: 8),
                      Text('分享', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  backgroundColor: Colors.purple,
                  onTrigger: () => print('分享 ${items[index].title}'),
                ),
              ],
              borderRadius: borderRadius,
              child: TimeItemCard(item: items[index]),  // 传入圆角值
            ),
          ),
        );
      },
    );
  }
}

// 时间项数据模型
class TimeItem {
  final String title;

  TimeItem({required this.title});
}

// 时间项卡片
class TimeItemCard extends StatelessWidget {
  final TimeItem item;

  const TimeItemCard({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.access_time),
            SizedBox(width: 16),
            Text(
              item.title,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}