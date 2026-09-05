import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final bool showText;

  const RatingWidget({
    super.key,
    required this.rating,
    this.size = 16,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, size: size, color: Colors.amber);
          } else if (index < rating) {
            return Icon(Icons.star_half, size: size, color: Colors.amber);
          }
          return Icon(Icons.star_border, size: size, color: Colors.amber);
        }),
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF495057),
            ),
          ),
        ],
      ],
    );
  }
}
