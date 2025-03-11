import 'package:flutter/material.dart';
import '../../widgets/common/swipe_action_card.dart';
import 'package:remind_me/utils/common/logger_utils.dart';
import 'package:remind_me/services/notification_service.dart';
import 'package:remind_me/utils/common/route_utils.dart';
import 'package:remind_me/views/pages/date/add_event_page.dart';

class TimePage extends StatefulWidget {
  const TimePage({super.key});

  @override
  State<TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  @override
  Widget build(BuildContext context) {
    // 模拟一些测试数据
    final items = List.generate(
      5,
      (index) => TimeItem(title: '测试项目 ${index + 1}'),
    );

    // 定义圆角值
    final borderRadius = BorderRadius.circular(10);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SwipeActionCard(
                    startActions: [
                      SwipeAction(
                        flex: 3,
                        icon: Icons.cancel,
                        label: '取消',
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        spacing: 4,
                        onTrigger: () {
                          LoggerUtils.i('取消 ${items[index].title}', 'TimePage');
                        },
                      ),
                      SwipeAction(
                        flex: 2,
                        icon: Icons.info,
                        label: '详情',
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        spacing: 4,
                        onTrigger: () {
                          Navigator.push(
                            context,
                            RouteUtils.buildPageRoute(page: const AddEventPage()),
                          );
                        },
                      ),
                      SwipeAction(
                        flex: 2,
                        icon: Icons.push_pin,
                        label: '置顶',
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        spacing: 4,
                        onTrigger: () {
                          LoggerUtils.i('置顶 ${items[index].title}', 'TimePage');
                        },
                      ),
                      SwipeAction(
                        flex: 4,
                        icon: Icons.timeline,
                        label: '时间线',
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        spacing: 4,
                        onTrigger: () {
                          LoggerUtils.i('时间线 ${items[index].title}', 'TimePage');
                        },
                      ),
                      // // 添加取消操作
                      // SwipeAction(
                      //   flex: 3,
                      //   child: const Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(Icons.cancel, color: Colors.white),
                      //       SizedBox(width: 8),
                      //       Text('取消', style: TextStyle(color: Colors.white)),
                      //     ],
                      //   ),
                      //   backgroundColor: Colors.grey,
                      //   onTrigger: () {
                      //     // 取消操作，恢复到原位
                      //     LoggerUtils.i('取消 ${items[index].title}', 'TimePage');
                      //   },
                      // ),
                      // SwipeAction(
                      //   flex: 2,
                      //   child: const Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(Icons.info, color: Colors.white),
                      //       SizedBox(width: 8),
                      //       Text('详情', style: TextStyle(color: Colors.white)),
                      //     ],
                      //   ),
                      //   backgroundColor: Colors.blue,
                      //   onTrigger: () => Navigator.push(
                      //     context,
                      //     RouteUtils.buildPageRoute(page: const AddEventPage()),
                      //   ), 
                      // ),
                      // SwipeAction(
                      //   flex: 2,
                      //   child: const Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(Icons.push_pin, color: Colors.white),
                      //       SizedBox(width: 8),
                      //       Text('置顶', style: TextStyle(color: Colors.white)),
                      //     ],
                      //   ),
                      //   backgroundColor: Colors.orange,
                      //   onTrigger: () => LoggerUtils.i(
                      //       '置顶 ${items[index].title}', 'TimePage'),
                      // ),
                      // SwipeAction(
                      //   flex: 4,
                      //   child: const Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(Icons.timeline, color: Colors.white),
                      //       SizedBox(width: 8),
                      //       Text('时间线', style: TextStyle(color: Colors.white)),
                      //     ],
                      //   ),
                      //   backgroundColor: Colors.green,
                      //   onTrigger: () => LoggerUtils.i(
                      //       '时间线 ${items[index].title}', 'TimePage'),
                      // ),
                    ],
                    endActions: [
                      SwipeAction(
                        flex: 3,
                        icon: Icons.cancel,
                        label: '取消',
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        spacing: 4,
                        onTrigger: () {
                          LoggerUtils.i('取消 ${items[index].title}', 'TimePage');
                        },
                      ),
                      SwipeAction(
                        flex: 2,
                        icon: Icons.edit,
                        label: '编辑',
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        spacing: 4,
                        onTrigger: () {
                          LoggerUtils.i('编辑 ${items[index].title}', 'TimePage');
                        },
                      ),
                      SwipeAction(
                        flex: 2,
                        icon: Icons.delete,
                        label: '删除',
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        spacing: 4,
                        onTrigger: () {
                          LoggerUtils.i('删除 ${items[index].title}', 'TimePage');
                        },
                      ),
                      SwipeAction(
                        flex: 4,
                        icon: Icons.share,
                        label: '分享',
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        spacing: 4,
                        onTrigger: () {
                          LoggerUtils.i('分享 ${items[index].title}', 'TimePage');
                        },
                      ),
                      // // 添加取消操作
                      // SwipeAction(
                      //   flex: 3,
                      //   child: const Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(Icons.cancel, color: Colors.white),
                      //       SizedBox(width: 8),
                      //       Text('取消', style: TextStyle(color: Colors.white)),
                      //     ],
                      //   ),
                      //   backgroundColor: Colors.grey,
                      //   onTrigger: () {
                      //     // 取消操作，恢复到原位
                      //     LoggerUtils.i('取消 ${items[index].title}', 'TimePage');
                      //   },
                      // ),
                      // SwipeAction(
                      //   flex: 1,
                      //   child: const Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(Icons.edit, color: Colors.white),
                      //       SizedBox(width: 8),
                      //       Text('编辑', style: TextStyle(color: Colors.white)),
                      //     ],
                      //   ),
                      //   backgroundColor: Colors.amber,
                      //   onTrigger: () => LoggerUtils.i(
                      //       '编辑 ${items[index].title}', 'TimePage'),
                      // ),
                      // SwipeAction(
                      //   flex: 1,
                      //   child: const Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(Icons.delete, color: Colors.white),
                      //       SizedBox(width: 8),
                      //       Text('删除', style: TextStyle(color: Colors.white)),
                      //     ],
                      //   ),
                      //   backgroundColor: Colors.red,
                      //   onTrigger: () => LoggerUtils.i(
                      //       '删除 ${items[index].title}', 'TimePage'),
                      // ),
                      // SwipeAction(
                      //   flex: 4,
                      //   child: const Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(Icons.share, color: Colors.white),
                      //       SizedBox(width: 8),
                      //       Text('分享', style: TextStyle(color: Colors.white)),
                      //     ],
                      //   ),
                      //   backgroundColor: Colors.purple,
                      //   onTrigger: () => LoggerUtils.i(
                      //       '分享 ${items[index].title}', 'TimePage'),
                      // ),
                    ],
                    borderRadius: borderRadius,
                    child: TimeItemCard(item: items[index]), // 传入圆角值
                  ),
                ),
              );
            },
          ),
        ),

        // 添加测试通知部分
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '通知测试',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _testInstantNotification,
                          child: const Text('测试即时通知'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _testDelayedNotification,
                          child: const Text('测试定时通知'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 测试即时通知
  Future<void> _testInstantNotification() async {
    try {
      await NotificationService().testInstantNotification();
      if (!mounted) return;
      _showMessage('即时通知已发送');
    } catch (e) {
      LoggerUtils.e('【时间页面】即时通知测试失败: $e', 'TimePage');
      if (!mounted) return;
      _showMessage('发送失败: $e', isError: true);
    }
  }

  /// 测试定时通知（10秒后）
  Future<void> _testDelayedNotification() async {
    try {
      await NotificationService().testDelayedNotification(
        const Duration(seconds: 10),
      );
      if (!mounted) return;
      _showMessage('定时通知已设置（10秒后触发）');
    } catch (e) {
      LoggerUtils.e('【时间页面】定时通知测试失败: $e', 'TimePage');
      if (!mounted) return;
      _showMessage('设置失败: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
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
            const Icon(Icons.access_time),
            const SizedBox(width: 16),
            Text(
              item.title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
