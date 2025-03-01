import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 滑动操作卡片组件，支持左右滑动显示操作项
class SwipeActionCard extends StatefulWidget {
  final Widget child;
  final List<SwipeAction>? startActions;
  final List<SwipeAction>? endActions;
  final BorderRadius borderRadius;
  // 卡片滑动过渡动画的持续时间，可定制
  final Duration slideAnimationDuration;
  // 卡片回弹动画的持续时间，可定制
  final Duration bounceAnimationDuration;
  // 操作项颜色渐变动画的持续时间，可定制
  final Duration colorAnimationDuration;
  // 卡片滑动过渡动画的曲线，可定制
  final Curve slideAnimationCurve;
  // 卡片回弹动画的曲线，可定制
  final Curve bounceAnimationCurve;
  // 操作项颜色渐变动画的曲线，可定制
  final Curve colorAnimationCurve;

  const SwipeActionCard({
    required this.child,
    this.startActions,
    this.endActions,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)), // 默认圆角值
    this.slideAnimationDuration = const Duration(milliseconds: 300),
    this.bounceAnimationDuration = const Duration(milliseconds: 200),
    this.colorAnimationDuration = const Duration(milliseconds: 200),
    this.slideAnimationCurve = Curves.easeOut,
    this.bounceAnimationCurve = Curves.easeOutBack,
    this.colorAnimationCurve = Curves.easeOut,
    super.key,
  });

  @override
  State<SwipeActionCard> createState() => _SwipeActionCardState();
}

class _SwipeActionCardState extends State<SwipeActionCard> {
  double _dragOffset = 0; // 当前拖动的偏移量
  SwipeAction? _currentAction; // 当前触发的操作项
  Color _currentBackgroundColor = Colors.transparent; // 当前操作项的背景颜色

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth; // 获取最大宽度

        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: Stack(
            children: [
              _buildActionBackground(maxWidth), // 构建操作背景
              TweenAnimationBuilder<double>(
                // 控制卡片滑动过渡动画
                tween: Tween<double>(begin: 0, end: _dragOffset),
                duration: widget.slideAnimationDuration,
                curve: widget.slideAnimationCurve,
                builder: (context, value, child) {
                  return GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        final newOffset = _dragOffset + details.delta.dx; // 更新偏移量

                        // 限制滑动范围
                        if (widget.startActions == null && newOffset > 0) return;
                        if (widget.endActions == null && newOffset < 0) return;

                        _dragOffset = newOffset.clamp(-maxWidth, maxWidth); // 限制偏移量在最大宽度范围内

                        final actions = _dragOffset > 0 ? widget.startActions : widget.endActions;
                        if (actions == null) return;

                        final progress = _dragOffset.abs() / maxWidth; // 计算滑动进度
                        _updateCurrentAction(actions, progress); // 更新当前操作项
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (_currentAction != null) {
                        _currentAction!.onTrigger(); // 触发当前操作项
                      }
                      setState(() {
                        // 回弹动画
                        Future.delayed(Duration.zero, () {
                          setState(() {
                            _dragOffset = 0;
                          });
                        });
                        _currentAction = null; // 清空当前操作项
                      });
                    },
                    child: Transform.translate(
                      offset: Offset(value, 0), // 根据偏移量移动子组件
                      child: widget.child,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionBackground(double maxWidth) {
    final actions = _dragOffset > 0 ? widget.startActions : widget.endActions;
    if (actions == null || _currentAction == null) return const SizedBox();

    final totalFlex = actions.fold<int>(0, (sum, action) => sum + action.flex); // 计算总的 flex 值

    // 计算当前操作项的宽度
    final currentActionIndex = actions.indexOf(_currentAction!);
    double currentActionWidth = 0;
    for (int i = 0; i <= currentActionIndex; i++) {
      currentActionWidth += maxWidth * (actions[i].flex / totalFlex);
    }

    return Positioned.fill(
      child: AnimatedContainer(
        // 操作项颜色渐变动画
        duration: widget.colorAnimationDuration,
        curve: widget.colorAnimationCurve,
        width: _dragOffset.abs() < currentActionWidth ? _dragOffset.abs() : currentActionWidth,
        color: _currentBackgroundColor, // 背景颜色为当前操作项的颜色
        alignment: _dragOffset > 0 ? Alignment.centerLeft : Alignment.centerRight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _currentAction!.child, // 显示当前操作项的内容
          ),
        ),
      ),
    );
  }

  void _updateCurrentAction(List<SwipeAction> actions, double progress) {
    double flexProgress = 0.0;
    final totalFlex = actions.fold<int>(0, (sum, action) => sum + action.flex);

    for (final action in actions) {
      final flexRatio = action.flex / totalFlex; // 计算每个操作项的比例
      if (progress <= flexProgress + flexRatio) {
        if (_currentAction != action) {
          HapticFeedback.mediumImpact(); // 触觉反馈
          _currentAction = action; // 更新当前操作项
          setState(() {
            // 更新当前操作项的背景颜色，触发颜色渐变动画
            _currentBackgroundColor = action.backgroundColor;
          });
        }
        break;
      }
      flexProgress += flexRatio; // 更新已处理的比例
    }
  }
}

class SwipeAction {
  final Widget child;
  final Color backgroundColor;
  final VoidCallback onTrigger;
  final int flex;

  SwipeAction({
    required this.child,
    required this.backgroundColor,
    required this.onTrigger,
    int flex = 1,
  }) : flex = flex >= 0
      ? flex
      : (throw ArgumentError('flex 值必须为非负整数')); // 验证 flex 值
}