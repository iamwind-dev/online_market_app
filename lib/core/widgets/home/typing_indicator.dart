import 'package:flutter/material.dart';

/// Widget hiển thị indicator khi bot đang typing
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFD503),
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: Color(0xFF008EDB), width: 1),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFDEDEDE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('...', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
