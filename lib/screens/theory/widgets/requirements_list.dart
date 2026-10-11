import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';

class RequirementsList extends StatelessWidget {
  final List<String> items;
  final AppPalette palette;

  const RequirementsList({
    super.key,
    required this.items,
    required this.palette,
  });

  String _withPeriod(String s) =>
      (s.endsWith('.') || s.endsWith('?') || s.endsWith('!')) ? s : '$s.';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  color: palette.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  _withPeriod(item),
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
