import 'package:flutter/material.dart';

class StatGraphSheet extends StatelessWidget {
  final String title;
  final String dateRange;
  final List<double> values;

  const StatGraphSheet({
    super.key,
    required this.title,
    required this.dateRange,
    required this.values,
  });

  /// Generate day labels for the last 7 days (T, F, S, etc.)
  List<String> _getDayLabels() {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S']; // Sunday = 0
    final labels = <String>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      labels.add(days[date.weekday % 7]); // weekday: 1=Mon, 7=Sun
    }

    return labels;
  }

  /// Generate dynamic Y-axis labels based on max value in data
  List<String> _getYAxisLabels() {
    if (values.isEmpty) return ['0', '10', '20', '30', '40'];

    double maxValue =
        values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 40;
    if (maxValue == 0) maxValue = 40;

    // Round up to nearest 50 for clean intervals
    maxValue = (maxValue * 1.2).ceilToDouble();
    final step = (maxValue / 4).ceilToDouble();

    return [
      (maxValue).toInt().toString(),
      (maxValue - step).toInt().toString(),
      (maxValue - step * 2).toInt().toString(),
      (maxValue - step * 3).toInt().toString(),
      '0',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dayLabels = _getDayLabels();
    final yAxisLabels = _getYAxisLabels();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(dateRange, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // Graph container with proper spacing
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels - right aligned to match grid
                SizedBox(
                  width: 35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:
                        yAxisLabels
                            .map(
                              (label) => Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(width: 12),
                // Graph area
                Expanded(
                  child: CustomPaint(
                    painter: _LineGraphPainter(values),
                    size: Size.infinite,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 35), // Match Y-axis width
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      dayLabels
                          .map(
                            (day) =>
                                Text(day, style: const TextStyle(fontSize: 12)),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineGraphPainter extends CustomPainter {
  final List<double> values;

  _LineGraphPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    // Deep purple colors to match the app theme
    final paintLine =
        Paint()
          ..color = const Color(0xFF5C56D6) // Deep purple
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final paintDot = Paint()..color = const Color(0xFF5C56D6); // Deep purple

    // Grid line paint
    final paintGrid =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.2)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    double spacing = size.width / (values.length - 1);

    // Dynamically calculate maxValue from data, with a minimum scale
    double maxValue =
        values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 40;
    if (maxValue == 0) maxValue = 40; // Default if all values are 0

    // Add 20% padding to the top so the highest value doesn't touch the ceiling
    maxValue = maxValue * 1.2;

    // Draw horizontal grid lines (for every 10 units)
    for (int i = 0; i <= 4; i++) {
      double y = size.height - (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      double x = spacing * i;
      double y = size.height - (values[i] / maxValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 5, paintDot);
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
