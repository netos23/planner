import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class CircleProgressBar extends StatefulWidget {
  final double radius;
  final double thickness;
  final Color? borderColor;
  final Color? progressColor;
  final int steps;
  final int currentStep;
  final double elevation;

  const CircleProgressBar({
    Key? key,
    this.radius = 100.0,
    this.thickness = 20.0,
    this.borderColor = Colors.grey,
    this.progressColor = Colors.green,
    required this.steps,
    this.currentStep = 0,
    this.elevation = 0,
  })  : assert(steps >= currentStep),
        assert(borderColor != null),
        assert(progressColor != null),
        super(key: key);

  @override
  _CircleProgressBarState createState() => _CircleProgressBarState();
}

class _CircleProgressBarState extends State<CircleProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: CustomPaint(
          painter: _CircleProgressBarPainter(
              widget.steps,
              widget.currentStep,
              widget.radius,
              widget.thickness,
              widget.borderColor!,
              widget.progressColor!,
              widget.elevation),
          child: Center(
            child: Text('${widget.currentStep} / ${widget.steps}'),
          ),
        ),
      ),
    );
  }
}

class _CircleProgressBarPainter extends CustomPainter {
  final double radius;
  final double thickness;
  final Color borderColor;
  final Color progressColor;
  final int steps;
  final int currentStep;
  final double elevation;

  _CircleProgressBarPainter(this.steps, this.currentStep, this.radius,
      this.thickness, this.borderColor, this.progressColor, this.elevation);

  @override
  void paint(Canvas canvas, Size size) {
    var drawOffset = thickness / 2;
    var externalRadius = radius - drawOffset;
    var center = size.center(Offset.zero);

    var borderPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..strokeWidth = thickness;

    var progressPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = progressColor
      ..strokeWidth = thickness;

    var pointPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = progressColor;

    var angle = (360 * currentStep / steps);
    var radAngle = angle * pi / 180;

    var rect = Rect.fromCircle(center: center, radius: externalRadius);
    var progressStart = Offset(center.dx, drawOffset);
    var progressFinish = Offset(
      center.dx + externalRadius * cos(radAngle - pi / 2),
      center.dy + externalRadius * sin(radAngle - pi / 2),
    );

    if (elevation > 1.0) {
      var shadow = Path();
      var exShadowBounds = Rect.fromCircle(center: center, radius: radius);
      shadow.addArc(exShadowBounds, 0, 2 * pi);
      canvas.drawShadow(shadow, Colors.black.withOpacity(0.35), 10.0, true);
    }

    canvas.drawCircle(center, externalRadius, borderPaint);
    canvas.drawArc(rect, -pi / 2, radAngle, false, progressPaint);
    canvas.drawCircle(progressStart, drawOffset, pointPaint);
    canvas.drawCircle(progressFinish, drawOffset, pointPaint);
  }

  @override
  bool shouldRepaint(covariant _CircleProgressBarPainter oldDelegate) =>
      this != oldDelegate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CircleProgressBarPainter &&
          runtimeType == other.runtimeType &&
          radius == other.radius &&
          thickness == other.thickness &&
          borderColor == other.borderColor &&
          progressColor == other.progressColor &&
          steps == other.steps &&
          currentStep == other.currentStep &&
          elevation == other.elevation;

  @override
  int get hashCode =>
      radius.hashCode ^
      thickness.hashCode ^
      borderColor.hashCode ^
      progressColor.hashCode ^
      steps.hashCode ^
      currentStep.hashCode ^
      elevation.hashCode;
}
