import 'package:flutter/material.dart';

class CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircleRevealClipper({
    required this.center,
    required this.radius,
  });

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
  }
}

class CircleRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Offset center;
  final double startRadius;
  final double endRadius;
  final Color? backgroundColor;

  CircleRevealRoute({
    required this.page,
    required this.center,
    this.startRadius = 0.0,
    required this.endRadius,
    this.backgroundColor,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          opaque: false,
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0),
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Stack(
      children: [
        // 背景层
        if (backgroundColor != null)
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return ClipPath(
                clipper: CircleRevealClipper(
                  center: center,
                  radius: Tween<double>(
                    begin: startRadius,
                    end: endRadius,
                  )
                      .animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOutCubic,
                        ),
                      )
                      .value,
                ),
                child: Container(
                  color: backgroundColor,
                ),
              );
            },
          ),
        
        // 内容层
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: child,
            );
          },
          child: child,
        ),
      ],
    );
  }
} 