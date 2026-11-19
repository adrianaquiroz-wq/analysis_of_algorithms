import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/fuzzy/fuzzy_model_screen.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';

class FuzzyTheoryScreen extends StatelessWidget {
  const FuzzyTheoryScreen({super.key});

  static const _steps = [
    (
      'Fuzzificación',
      'Cada entrada se convierte en grados de pertenencia entre 0 y 1.',
    ),
    (
      'Evaluación de reglas',
      'SI Interés es alto Y Calidad es buena ENTONCES rendimiento es excelente. El AND usa el mínimo.',
    ),
    (
      'Implicación',
      'Se recorta la salida de cada regla con su grado de activación.',
    ),
    ('Agregación', 'Se unen todas las salidas recortadas (máximo).'),
    (
      'Defuzzificación',
      'Se obtiene un número final, normalmente con el centroide.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) => _screen(context, AppPalette(isDark)),
    );
  }

  Widget _card(AppPalette p, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: p.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: p.cardBorder),
    ),
    child: child,
  );

  Widget _title(AppPalette p, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        color: p.text,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  );

  Widget _screen(BuildContext context, AppPalette p) {
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.card,
        title: Text('Lógica Difusa · Mamdani', style: TextStyle(color: p.text)),
        iconTheme: IconThemeData(color: p.text),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            p,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(p, '¿Qué es la lógica difusa?'),
                Text(
                  'A diferencia de la lógica clásica (verdadero o falso), permite '
                  'grados de pertenencia entre 0 y 1. Por ejemplo, una calidad '
                  'docente de 65 puede ser "regular" con grado 0.6 y "excelente" '
                  'con grado 0.2.',
                  style: TextStyle(color: p.subtleText, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            p,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(p, 'Pasos del método Mamdani'),
                for (var i = 0; i < _steps.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p.accent.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: p.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _steps[i].$1,
                                style: TextStyle(
                                  color: p.text,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _steps[i].$2,
                                style: TextStyle(
                                  color: p.subtleText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            p,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(p, 'Nuestro modelo'),
                Text(
                  'Entradas (0–100): Interés, Calidad_Docente (Mala, Regular, '
                  'Excelente) e Infraestructura (mala, regular, Buena).\n\n'
                  'Salida (0–100): Rendimiento_Académico (Pésimo, Regular, '
                  'Excelente).',
                  style: TextStyle(color: p.subtleText, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MatlabLabScreen()),
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Ir al modelo'),
            ),
          ),
        ],
      ),
    );
  }
}
