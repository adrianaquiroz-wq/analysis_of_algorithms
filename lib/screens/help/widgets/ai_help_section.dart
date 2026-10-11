import 'package:flutter/material.dart';
import 'package:graph_app/services/ai_help_launcher.dart';
import 'package:graph_app/theme/app_palette.dart';

import '../help_content.dart';
import 'help_section_view.dart';

class AiHelpSection extends StatelessWidget {
  final AppPalette palette;

  const AiHelpSection({super.key, required this.palette});

  Future<void> _ask(BuildContext context) async {
    final ok = await openAiHelp(aiHelpTopic);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HelpSectionTitle(title: '6. Help profesional :)', palette: palette),
        HelpCard(
          palette: palette,
          child: Text(
            '• Usa una IA para entender mucho mejor el tema.',
            style: TextStyle(
              color: palette.subtleText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton.icon(
          onPressed: () => _ask(context),
          icon: const Icon(Icons.smart_toy),
          label: const Text('Consultar duda a la IA sobre este tema'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 18, 45, 118),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
