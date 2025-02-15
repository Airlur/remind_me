import 'package:flutter/material.dart';

class CustomPageView extends StatefulWidget {
  final List<Widget> children;
  final PageController controller;
  final ValueChanged<int>? onPageChanged;
  final ScrollPhysics? physics;

  const CustomPageView({
    Key? key,
    required this.children,
    required this.controller,
    this.onPageChanged,
    this.physics,
  }) : super(key: key);

  @override
  CustomPageViewState createState() => CustomPageViewState();
}

class CustomPageViewState extends State<CustomPageView> {
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
      child: PageView(
        controller: widget.controller,
        physics: widget.physics,
        children: widget.children,
      ),
    );
  }
} 