import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.controller.initialPage;
  }

  @override
  Widget build(BuildContext context) {
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