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

class _SwipeActionCardState extends State<SwipeActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragOffset = 0; // 当前拖动的偏移量
  SwipeAction? _currentAction; // 当前触发的操作项
  Color _currentBackgroundColor = Colors.transparent; // 当前操作项的背景颜色
  double? _startDragOffset; // 记录开始回弹时的偏移量
  double _maxWidth = 0; // 卡片的最大宽度

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.slideAnimationDuration,
    );

    // 添加动画监听器
    _animationController.addListener(() {
      if (_startDragOffset != null) {
        setState(() {
          // 根据动画进度更新 dragOffset
          _dragOffset = _startDragOffset! * (1 - _animationController.value);
          
          // 使用现有的 _updateCurrentAction 逻辑更新状态
          final actions = _dragOffset > 0 ? widget.startActions : widget.endActions;
          if (actions != null) {
            final progress = _dragOffset.abs() / _maxWidth;
            _updateCurrentAction(actions, progress);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxWidth = constraints.maxWidth;

        return ClipRRect(
          borderRadius: widget.borderRadius, // 设置圆角
          child: Stack(
            children: [
              _buildActionBackground(_maxWidth), // 构建操作项背景
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (_animationController.isAnimating) return;
                      
                      setState(() {
                        final newOffset = _dragOffset + details.delta.dx;
                        
                        // 限制滑动范围
                        if (widget.startActions == null && newOffset > 0) return;
                        if (widget.endActions == null && newOffset < 0) return;
                        
                        _dragOffset = newOffset.clamp(-_maxWidth, _maxWidth);
                        
                        final actions = _dragOffset > 0 
                          ? widget.startActions 
                          : widget.endActions;
                        if (actions == null) return;
                        
                        final progress = _dragOffset.abs() / _maxWidth;
                        _updateCurrentAction(actions, progress);
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (_currentAction != null) {
                        _currentAction!.onTrigger(); // 触发当前操作项
                      }
                      
                      // 记录开始回弹时的偏移量
                      _startDragOffset = _dragOffset;
                      
                      // 开始回弹动画
                      _animationController.forward(from: 0).then((_) {
                        setState(() {
                          _dragOffset = 0;
                          _startDragOffset = null;
                          _currentAction = null;
                          _currentBackgroundColor = Colors.transparent;
                        });
                      });
                    },
                    child: Transform.translate(
                      offset: Offset(_dragOffset, 0),
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

    final totalFlex = actions.fold<int>(0, (sum, action) => sum + action.flex);
    final currentActionIndex = actions.indexOf(_currentAction!);
    double currentActionWidth = 0;
    
    for (int i = 0; i <= currentActionIndex; i++) {
      currentActionWidth += maxWidth * (actions[i].flex / totalFlex);
    }

    return Positioned.fill(
      child: Container(
        width: _dragOffset.abs() < currentActionWidth 
          ? _dragOffset.abs() 
          : currentActionWidth,
        color: _currentBackgroundColor,
        alignment: _dragOffset > 0 
          ? Alignment.centerLeft 
          : Alignment.centerRight,
        child: Container(
          padding: _currentAction!.padding,
          child: _currentAction!.buildActionContent(),  // 使用新的构建方法
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
          // HapticFeedback.heavyImpact(); // 触觉反馈振动，调用位置在状态更新后可能有效
          setState(() {
            _currentAction = action;
            _currentBackgroundColor = action.backgroundColor;
          });

          // // 获取操作项的文本内容
          // String actionName = '未知';
          // if (action.child is Row) {
          //   final row = action.child as Row;
          //   for (final child in row.children) {
          //     if (child is Text) {
          //       actionName = child.data ?? '未知';
          //       break;
          //     }
          //   }
          // }
          
          // 状态更新后触发反馈
          HapticFeedback.heavyImpact().then((_) {
            // debugPrint('触发触觉反馈: $actionName (${action.backgroundColor})'); // 添加调试日志
          });
        }
        break;
      }
      flexProgress += flexRatio; // 更新已处理的比例
    }
  }
}

class SwipeAction {
  final Widget? child;        // 保留原有的自定义 child，但设为可选
  final IconData? icon;       // 新增：图标
  final String? label;        // 新增：文本标签
  final Color backgroundColor;
  final Color? foregroundColor; // 新增：图标和文字颜色
  final VoidCallback onTrigger;
  final int flex;
  final double? spacing;      // 新增：图标和文字间距
  final EdgeInsets? padding;  // 新增：内边距
  final Axis direction;       // 新增：布局方向（水平或垂直）

  SwipeAction({
    this.child,
    this.icon,
    this.label,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,  // 默认白色，是图标和文字的颜色
    required this.onTrigger,
    this.flex = 1,
    this.spacing = 8.0,     // 默认间距
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),  // 默认内边距
    this.direction = Axis.vertical,  // 默认垂直布局
  }) : assert(
         child != null || (icon != null || label != null),
         '必须提供 child 或 icon/label 中的至少一个'
       );

  // 修改构建方法支持垂直布局
  Widget buildActionContent() {
    // 如果提供了自定义 child，直接使用
    if (child != null) return child!;

    return direction == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, color: foregroundColor),
              if (icon != null && label != null) SizedBox(width: spacing),
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(color: foregroundColor),
                ),
            ],
          )
        : Column(  // 垂直布局
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, color: foregroundColor),
              if (icon != null && label != null) SizedBox(height: spacing),
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(color: foregroundColor),
                ),
            ],
          );
  }
}