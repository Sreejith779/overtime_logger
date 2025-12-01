  // dart
  import 'dart:math' as math;
  import 'package:flutter/material.dart';

import '../controllers/overtime_controllers.dart';

  class HoursPieChart extends StatelessWidget {
    final OvertimeController controller;
    final double size;
    const HoursPieChart({super.key, required this.controller, this.size = 180});

    @override
    Widget build(BuildContext context) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final approved = controller.totalApprovedHours;
          final pending = controller.totalPendingHours;
          final total = approved + pending;
          if (total == 0.0) {
            return SizedBox(
              height: size,
              child: Center(child: Text('No hours logged')),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _PiePainter(approved: approved, pending: pending),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${total.toStringAsFixed(1)} h',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Approved ${approved.toStringAsFixed(1)} / Pending ${pending.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _LegendRow(approved: approved, pending: pending),
            ],
          );
        },
      );
    }
  }

  class _LegendRow extends StatelessWidget {
    final double approved;
    final double pending;
    const _LegendRow({required this.approved, required this.pending});

    @override
    Widget build(BuildContext context) {
      return Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        children: [
          _LegendItem(
            color: Colors.green,
            label: 'Approved ${approved.toStringAsFixed(1)} h',
          ),
          _LegendItem(
            color: Colors.orange,
            label: 'Pending ${pending.toStringAsFixed(1)} h',
          ),
        ],
      );
    }
  }

  class _LegendItem extends StatelessWidget {
    final Color color;
    final String label;
    const _LegendItem({required this.color, required this.label});

    @override
    Widget build(BuildContext context) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      );
    }
  }

  class _PiePainter extends CustomPainter {
    final double approved;
    final double pending;
    _PiePainter({required this.approved, required this.pending});

    @override
    void paint(Canvas canvas, Size size) {
      final total = approved + pending;
      final rect = Offset.zero & size;
      final center = rect.center;
      final radius = (size.shortestSide) / 2;

      final approvedSweep =
          total == 0.0 ? 0.0 : (approved / total) * 2.0 * math.pi;
      final pendingSweep =
          total == 0.0 ? 0.0 : (pending / total) * 2.0 * math.pi;

      final paintApproved =
          Paint()..color = Colors.green..style = PaintingStyle.fill;
      final paintPending =
          Paint()..color = Colors.orange..style = PaintingStyle.fill;

      double startAngle = -math.pi / 2.0; // start at top
      if (approved > 0.0) {
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle,
            approvedSweep,
            true,
            paintApproved);
        startAngle += approvedSweep;
      }
      if (pending > 0.0) {
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle,
            pendingSweep,
            true,
            paintPending);
      }

      final innerPaint =
          Paint()..color = Colors.white..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius * 0.5, innerPaint);
    }

    @override
    bool shouldRepaint(covariant _PiePainter old) =>
        old.approved != approved || old.pending != pending;
  }