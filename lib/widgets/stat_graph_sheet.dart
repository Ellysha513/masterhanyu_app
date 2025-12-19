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

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 20),

          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(painter: _LineGraphPainter(values)),
          ),

          const SizedBox(height: 10),

          // Days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("F"),
              Text("S"),
              Text("S"),
              Text("M"),
              Text("T"),
              Text("W"),
              Text("T"),
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
    final paintLine =
        Paint()
          ..color = const Color(0xFF4CD4B0)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final paintDot = Paint()..color = const Color(0xFF22C38E);

    final path = Path();

    double spacing = size.width / (values.length - 1);
    double maxValue = 40; // fixed scale like screenshot

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
