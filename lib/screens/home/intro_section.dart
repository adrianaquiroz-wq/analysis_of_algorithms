import 'package:flutter/material.dart';

import 'body_text.dart';

class IntroSection extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color cardColor;
  final Color accentColor;

  const IntroSection({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.cardColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 13);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: sectionCardDecoration(cardColor, accentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          BodyText(
            'El Análisis de Algoritmos es una rama de la informática y de las ciencias de la computación que se encarga de estudiar los procedimientos utilizados para resolver diferentes tipos de problemas. Un algoritmo consiste en una serie de pasos ordenados y definidos que permiten obtener una solución a partir de determinados datos de entrada. El análisis busca determinar si estos procedimientos son correctos y qué tan eficientes son al momento de ejecutarse.',
            isDarkMode: isDarkMode,
          ),
          gap,
          BodyText(
            'Además, el Análisis de Algoritmos permite evaluar principalmente el tiempo de ejecución, el uso de memoria y la cantidad de recursos necesarios para resolver un problema. De esta manera, es posible comparar diferentes algoritmos y seleccionar el más adecuado según las características del problema. En aplicaciones de optimización, como los algoritmos de asignación, CPM y esquina noroeste, este análisis permite comprender cómo se procesan los datos para obtener soluciones de manera organizada y eficiente.',
            isDarkMode: isDarkMode,
          ),
          gap,
          Center(
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Image.asset(
                'assets/images/imag1.png',
                width: 300,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          gap,
          Text(
            'Grafos',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          BodyText(
            'La teoría de grafos es una rama de las matemáticas y de las ciencias de la computación que estudia estructuras formadas por elementos y las relaciones existentes entre ellos. Estas estructuras permiten representar de manera abstracta situaciones reales en las que diferentes objetos se encuentran conectados entre sí. Los grafos tienen numerosas aplicaciones en áreas como redes informáticas, sistemas de transporte, redes sociales, planificación, logística, inteligencia artificial y resolución de problemas de optimización.',
            isDarkMode: isDarkMode,
          ),
          gap,
          BodyText(
            'Un grafo se representa generalmente mediante el conjunto (G=(V,E)), donde (V) representa el conjunto de vértices o nodos y (E) representa el conjunto de aristas. Los vértices son los elementos que forman parte del grafo, mientras que las aristas representan las relaciones o conexiones existentes entre ellos. Por ejemplo, en una red de transporte, los nodos podrían representar ciudades y las aristas podrían representar las carreteras que las conectan.',
            isDarkMode: isDarkMode,
          ),
          gap,
          BodyText(
            'Los vértices o nodos son los elementos principales de un grafo. Cada nodo puede identificarse mediante un nombre, número o etiqueta y, dependiendo de la aplicación, puede almacenar información adicional. En el proyecto desarrollado, los nodos fueron utilizados para representar los diferentes elementos del problema y podían contener atributos que permitían diferenciarlos y clasificarlos.',
            isDarkMode: isDarkMode,
          ),
          gap,
          BodyText(
            'Las aristas son las conexiones entre dos vértices. Una arista puede representar diferentes tipos de relaciones dependiendo del problema que se esté estudiando. En determinados grafos, las aristas pueden tener asociado un peso, que representa un valor relacionado con esa conexión, como un costo, distancia, tiempo, beneficio o capacidad. En la aplicación desarrollada, los valores de las relaciones fueron utilizados posteriormente para construir las matrices necesarias para los problemas de asignación.',
            isDarkMode: isDarkMode,
          ),
          gap,
          Center(
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Image.asset(
                'assets/images/imag2.png',
                width: 520,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
