import 'package:flutter/material.dart';

class SelectionSortPreview extends StatelessWidget {
  const SelectionSortPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final value in [3, 1, 4, 2])
          Container(
            width: 15,
            height: 18.0 + value * 11,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.teal[(value + 3) * 100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
      ],
    );
  }
}
