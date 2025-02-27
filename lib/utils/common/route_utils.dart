import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:remind_me/models/event.dart';
import 'package:remind_me/views/pages/date/event_detail_page.dart';
import 'package:remind_me/utils/ui/circle_reveal_clipper.dart';

class RouteUtils {
  static PageRouteBuilder buildPageRoute({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: duration,
    );
  }

  /// 构建事件详情页路由
  static Route<dynamic> buildEventDetailRoute(
    BuildContext context,
    Event event,
    RenderBox box,
  ) {
    // 计算卡片中心点在全局坐标系中的位置
    final center = box.localToGlobal(box.size.center(Offset.zero));
    
    // 计算屏幕对角线长度作为最终半径
    final screenSize = MediaQuery.of(context).size;
    final endRadius = math.sqrt(
      math.pow(screenSize.width, 2) + math.pow(screenSize.height, 2)
    );

    // 根据背景类型选择不同的路由动画
    if (event.backgroundType == BackgroundType.color || 
        event.backgroundType == BackgroundType.gradient) {
      final backgroundColor = event.backgroundType == BackgroundType.color
          ? event.backgroundColor
          : event.gradientColors?.first;
          
      return CircleRevealRoute(
        page: EventDetailPage(event: event),
        center: center,
        endRadius: endRadius,
        backgroundColor: backgroundColor,
      );
    }

    return buildPageRoute(page: EventDetailPage(event: event));
  }
} 