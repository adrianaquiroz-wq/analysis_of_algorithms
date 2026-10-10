import 'package:flutter/material.dart';

import 'body_text.dart';

const List<Map<String, String>> _teamMembers = [
  {
    'name': 'Ariana Beltran Soliz',
    'role': 'Se encargó principalmente de la interfaz gráfica y el diseño visual de la aplicación. Trabajó en la organización de las pantallas, botones, menús y elementos visuales, buscando que la aplicación fuera clara y fácil de utilizar. También participó en la integración de las diferentes funcionalidades dentro de la interfaz.',
  },
  {
    'name': 'Camila Perez Cano',
    'role': 'Se encargó de la gestión y representación de los grafos. Trabajó con la creación, modificación y eliminación de nodos y aristas, además de la información asociada a cada nodo. También participó en la representación visual del grafo y en la conexión entre los elementos que conformaban la estructura.',
  },
  {
    'name': 'Andres Pabon Sotomayor',
    'role': 'Se encargó de la construcción y manejo de las matrices utilizadas por la aplicación. Trabajó en la generación de la matriz a partir de los nodos y las aristas del grafo, incluyendo la organización de filas, columnas, sumas y cantidad de nodos o relaciones. También participó en el procesamiento de los datos necesarios para los problemas de asignación.',
  },
  {
    'name': 'Christian Lopez Tejerina',
    'role': 'Se encargó principalmente de la implementación de los algoritmos de asignación, especialmente del algoritmo Húngaro. Trabajó en el procesamiento de las matrices, tanto para problemas de minimización como de maximización, y en la obtención de las asignaciones óptimas. También participó en la representación de los pasos realizados por el algoritmo para poder visualizar el procedimiento.',
  },
  {
    'name': 'Adriana Quiroz Yujra',
    'role': 'Se encargó de la integración y funcionamiento general de la aplicación. Trabajó en conectar las diferentes partes desarrolladas por el equipo, como la interfaz, los grafos, las matrices y los algoritmos, verificando que los datos pudieran pasar correctamente de una función a otra. También participó en las pruebas de funcionamiento y en la corrección de errores para obtener el resultado final del proyecto.',
  },
];

class TeamSection extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color cardColor;
  final Color accentColor;

  const TeamSection({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.cardColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipo de Desarrollo de Grafos',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: sectionCardDecoration(cardColor, accentColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _teamMembers.length; i++) ...[
                if (i > 0) const SizedBox(height: 40),
                Text(
                  _teamMembers[i]['name']!,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                BodyText(_teamMembers[i]['role']!, isDarkMode: isDarkMode),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
