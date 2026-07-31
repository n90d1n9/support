import 'dart:math';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class MiniBarChart extends StatelessWidget {
  final List<double> values;
  final List<String>? labels;
  final Color barColor;
  final double height;
  const MiniBarChart(
      {super.key,
      required this.values,
      this.labels,
      this.barColor = AppColors.accent,
      this.height = 120});
  @override
  Widget build(BuildContext ctx) => SizedBox(
      height: height,
      child: CustomPaint(
          painter: _BarPainter(values: values, labels: labels, color: barColor),
          size: Size.infinite));
}

class _BarPainter extends CustomPainter {
  final List<double> values;
  final List<String>? labels;
  final Color color;
  _BarPainter({required this.values, this.labels, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final mx = values.reduce(max);
    if (mx == 0) return;
    const lh = 16.0;
    final ch = labels != null ? size.height - lh : size.height;
    final bw = (size.width - (values.length - 1) * 4) / values.length;
    for (var i = 0; i < values.length; i++) {
      final x = i * (bw + 4);
      final bh = (values[i] / mx) * ch * 0.88;
      final top = ch - bh;
      canvas.drawRRect(
          RRect.fromRectAndCorners(Rect.fromLTWH(x, top, bw, bh),
              topLeft: const Radius.circular(4),
              topRight: const Radius.circular(4)),
          Paint()
            ..color = values[i] == mx ? color : color.withValues(alpha: 0.3));
      if (labels != null && i < labels!.length) {
        final tp = TextPainter(
            text: TextSpan(
                text: labels![i],
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600)),
            textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: 60);
        tp.paint(canvas, Offset(x + bw / 2 - tp.width / 2, ch + 3));
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.values != values;
}

class DualBarChart extends StatelessWidget {
  final List<double> primary, secondary;
  final List<String>? labels;
  final Color primaryColor, secondaryColor;
  final double height;
  const DualBarChart(
      {super.key,
      required this.primary,
      required this.secondary,
      this.labels,
      this.primaryColor = AppColors.accent,
      this.secondaryColor = const Color(0xFF7BD389),
      this.height = 140});
  @override
  Widget build(BuildContext ctx) => SizedBox(
      height: height,
      child: CustomPaint(
          painter: _DualBarPainter(
              primary: primary,
              secondary: secondary,
              labels: labels,
              pc: primaryColor,
              sc: secondaryColor),
          size: Size.infinite));
}

class _DualBarPainter extends CustomPainter {
  final List<double> primary, secondary;
  final List<String>? labels;
  final Color pc, sc;
  _DualBarPainter(
      {required this.primary,
      required this.secondary,
      this.labels,
      required this.pc,
      required this.sc});
  @override
  void paint(Canvas canvas, Size size) {
    final n = primary.length;
    if (n == 0) return;
    final mx = [...primary, ...secondary].reduce(max);
    if (mx == 0) return;
    const lh = 16.0, gap = 2.0, gg = 6.0;
    final ch = size.height - lh;
    final gw = (size.width - (n - 1) * gg) / n;
    final bw = (gw - gap) / 2;
    for (var i = 0; i < n; i++) {
      final gx = i * (gw + gg);
      void bar(double v, double x, Color c) {
        final h = (v / mx) * ch * 0.88;
        final top = ch - h;
        canvas.drawRRect(
            RRect.fromRectAndCorners(Rect.fromLTWH(x, top, bw, h),
                topLeft: const Radius.circular(3),
                topRight: const Radius.circular(3)),
            Paint()..color = c);
      }

      bar(primary[i], gx, pc.withValues(alpha: 0.85));
      bar(secondary[i], gx + bw + gap, sc.withValues(alpha: 0.85));
      if (labels != null && i < labels!.length) {
        final tp = TextPainter(
            text: TextSpan(
                text: labels![i],
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600)),
            textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: gw + gg);
        tp.paint(canvas, Offset(gx + gw / 2 - tp.width / 2, ch + 3));
      }
    }
  }

  @override
  bool shouldRepaint(_DualBarPainter old) => false;
}

class SparkLine extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height, width, strokeWidth;
  final bool filled;
  const SparkLine(
      {super.key,
      required this.values,
      this.color = AppColors.accent,
      this.height = 36,
      this.width = 80,
      this.strokeWidth = 2,
      this.filled = true});
  @override
  Widget build(BuildContext ctx) => SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
          painter: _SparkPainter(
              values: values,
              color: color,
              strokeWidth: strokeWidth,
              filled: filled),
          size: Size(width, height)));
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double strokeWidth;
  final bool filled;
  _SparkPainter(
      {required this.values,
      required this.color,
      required this.strokeWidth,
      required this.filled});
  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final mn = values.reduce(min);
    final mx = values.reduce(max);
    final rng = (mx - mn).abs();
    if (rng == 0) return;
    double toX(int i) => i * size.width / (values.length - 1);
    double toY(double v) =>
        size.height - ((v - mn) / rng) * size.height * 0.85 - 2;
    final path = Path()..moveTo(toX(0), toY(values[0]));
    for (var i = 1; i < values.length; i++) {
      final x = toX(i);
      final y = toY(values[i]);
      final px = toX(i - 1);
      final py = toY(values[i - 1]);
      final cx = (px + x) / 2;
      path.cubicTo(cx, py, cx, y, x, y);
    }
    if (filled) {
      final fp = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
          fp,
          Paint()
            ..color = color.withValues(alpha: 0.15)
            ..style = PaintingStyle.fill);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
    canvas.drawCircle(Offset(toX(values.length - 1), toY(values.last)),
        strokeWidth + 1, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.values != values;
}

class PriorityHeatBar extends StatelessWidget {
  final int critical, high, normal, low;
  final double height;
  const PriorityHeatBar(
      {super.key,
      required this.critical,
      required this.high,
      required this.normal,
      required this.low,
      this.height = 10});
  @override
  Widget build(BuildContext ctx) {
    final total = critical + high + normal + low;
    if (total == 0) return const SizedBox.shrink();
    final segs = [
      (critical / total, const Color(0xFFFF5C72)),
      (high / total, const Color(0xFFFFA94D)),
      (normal / total, const Color(0xFF54C7FC)),
      (low / total, const Color(0xFF7BD389))
    ];
    return LayoutBuilder(
        builder: (ctx, c) => ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Row(
                children: segs
                    .where((s) => s.$1 > 0)
                    .map((s) => Container(
                        width: c.maxWidth * s.$1, height: height, color: s.$2))
                    .toList())));
  }
}

class RadialGauge extends StatelessWidget {
  final double value;
  final Color color;
  final String label, centerText;
  final double size;
  const RadialGauge(
      {super.key,
      required this.value,
      required this.color,
      required this.label,
      required this.centerText,
      this.size = 80});
  @override
  Widget build(BuildContext ctx) => SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
          painter: _GaugePainter(value: value, color: color),
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(centerText,
                style: TextStyle(
                    color: color,
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                    fontWeight: FontWeight.w600))
          ]))));
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  _GaugePainter({required this.value, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    const sa = -pi * 0.75;
    const sw = pi * 1.5;
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        sa,
        sw,
        false,
        Paint()
          ..color = color.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round);
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        sa,
        sw * value.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}
