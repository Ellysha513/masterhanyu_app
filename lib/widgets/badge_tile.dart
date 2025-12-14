import 'package:flutter/material.dart';

class BadgeTile extends StatelessWidget {
  final int index;
  const BadgeTile({super.key, required this.index});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 30),
          Text('Badge ${index + 1}'),
        ],
      ),
    );
  }
}
