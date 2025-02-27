import 'package:flutter/material.dart';
import 'dart:async';

class CustomPageView extends StatefulWidget {
  final PageController controller;
  final ScrollPhysics physics; // 滚动物理效果
  final ValueChanged<int>? onPageChanged; // 页面改变回调
  final List<Widget> children; // 子组件列表
  final bool enableAutoScroll; // 是否启用自动滚动

  const CustomPageView({
    required this.controller,
    required this.children,
    this.physics = const BouncingScrollPhysics(),
    this.onPageChanged,
    this.enableAutoScroll = false,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomPageView> createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> {
  int _lastReportedPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.controller.initialPage;
    _setupAutoScroll();
  }

  @override
  void didUpdateWidget(CustomPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 enableAutoScroll 状态改变时，更新自动滚动
    if (oldWidget.enableAutoScroll != widget.enableAutoScroll) {
      if (widget.enableAutoScroll) {
        _setupAutoScroll();
      } else {
        _stopAutoScroll();
        // 确保在禁用自动滚动时回到第一页
        if (widget.controller.hasClients) {
          widget.controller.jumpToPage(0);
        }
      }
    }
  }

  void _setupAutoScroll() {
    _stopAutoScroll();
    if (widget.enableAutoScroll && widget.children.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (mounted && widget.controller.hasClients) {
          final nextPage = (_lastReportedPage + 1) % widget.children.length;
          widget.controller.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 非轮播模式下只显示第一个子组件
    if (!widget.enableAutoScroll) {
      return widget.children.first;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.depth == 0 && 
            widget.onPageChanged != null && 
            notification is ScrollEndNotification) {
          final PageMetrics metrics = notification.metrics as PageMetrics;
          final int currentPage = metrics.page!.round();
          if (currentPage != _lastReportedPage) {
            _lastReportedPage = currentPage;
            widget.onPageChanged!(currentPage);
          }
        }
        return false;
      },
      child: PageView.builder(
        controller: widget.controller,
        physics: widget.physics,
        onPageChanged: widget.onPageChanged,
        itemCount: widget.children.length,
        itemBuilder: (context, index) => widget.children[index],
      ),
    );
  }
} 