import 'package:flutter/material.dart';

import 'help_screen.dart';
import 'saved_graphs_screen.dart';
import 'graph_screen.dart';
import 'algorithm_theory_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = true;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> algorithmList = [
    {
      'title': 'Simple graph',
      'subtitle': 'Lienzo abierto con un solo tipo de nodo estándar',
      'icon': Icons.hub_rounded,
      'algorithmType': 'free',
      'isBipartite': false,
      'theory':
          'El grafo simple o lienzo libre constituye la estructura fundamental para el modelado de redes y sistemas discretos. '
          'Permite la creación de grafos generales sin restricciones estrictas de conectividad, haciendo uso de un único tipo de nodo estándar. '
          'Es la herramienta ideal para la experimentación abierta, el diseño de topologías de red, el análisis exploratorio de adyacencia '
          'y la representación visual de relaciones generales entre entidades sin la rigurosidad de restricciones matemáticas complejas.',
      'youtubeUrl': 'https://www.youtube.com/watch?v=TU_ENLACE_SIMPLE',
      'imageUrl':
          'assets/images/simple_graph.png', // <-- Imagen para la tarjeta
    },
    {
      'title': 'Allocation algorithm',
      'subtitle': 'Optimización con enfoque húngaro y dos tipos de nodo',
      'icon': Icons.psychology_rounded,
      'algorithmType': 'assignment',
      'isBipartite': true,
      'theory':
          'El algoritmo de asignación, fundamentado en el clásico Método Húngaro, resuelve problemas avanzados de optimización '
          'enfocados en encontrar la distribución más eficiente de recursos (como operarios a tareas, o maquinaria a procesos) minimizando los costos totales '
          'o maximizando los rendimientos. Opera estrictamente bajo una arquitectura bipartita dividida en dos conjuntos de nodos disjuntos (Conjunto A y Conjunto B), '
          'garantizando una correspondencia uno a uno matemáticamente precisa a través de matrices de costos.',
      'youtubeUrl': 'https://www.youtube.com/watch?v=AwCyr6srBEg',
      'imageUrl': 'assets/images/assignment.png', // <-- Imagen para la tarjeta
    },
    {
      'title': 'CPM (critical path)',
      'subtitle': 'Planificación de proyectos con un solo tipo de nodo',
      'icon': Icons.memory_rounded,
      'algorithmType': 'cpm',
      'isBipartite': false,
      'theory':
          'El Método del Camino Crítico (CPM) es una técnica analítica de gestión y control empleada para la planificación de proyectos complejos. '
          'Utiliza un único tipo de nodo estándar para modelar las tareas y sus dependencias secuenciales en el tiempo. '
          'Su función principal es calcular la duración total estimada del proyecto mediante la identificación de la ruta más larga de actividades críticas, '
          'determinando con precisión las holguras y los márgenes de flexibilidad operativos para cada fase.',
      'youtubeUrl': 'https://www.youtube.com/watch?v=NGQzWqFE-RY',
      'imageUrl': 'assets/images/cpm.png', // <-- Imagen para la tarjeta
    },
    {
      'title': 'Northwest Corner',
      'subtitle': 'Heurística de transporte con dos tipos de nodos',
      'icon': Icons.smart_toy_rounded,
      'algorithmType': 'northwest',
      'isBipartite': true,
      'theory':
          'El método de la Esquina Noroeste es una regla heurística fundamental en la investigación de operaciones para resolver problemas de transporte, '
          'generando una solución factible inicial de manera rápida y sistemática. Funciona estructurando una matriz de distribución basada en dos tipos de nodos '
          'que representan la oferta (orígenes) y la demanda (destinos), asignando los flujos de recursos desde la esquina superior izquierda (noroccidental) '
          'hacia las celdas adyacentes hasta agotar las disponibilidades de la red.',
      'youtubeUrl': 'https://www.youtube.com/watch?v=IyogQ4noci0',
      'imageUrl': 'assets/images/northwest.png', // <-- Imagen para la tarjeta
    },
  ];

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final appBarColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final accentColor = isDarkMode ? Colors.cyanAccent : Colors.blueAccent;

    if (_currentIndex == 1) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: SavedGraphsScreen(
          isDarkMode: isDarkMode,
          onToggleTheme: (val) => setState(() => isDarkMode = val),
        ),
        bottomNavigationBar: _buildBottomNav(accentColor, cardColor),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.auto_awesome, color: accentColor, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'ST-GR / Graph Suite',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: accentColor,
            ),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
            tooltip: 'Cambiar tema',
          ),
          IconButton(
            icon: Icon(Icons.help_outline_rounded, color: accentColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HelpScreen(isDarkMode: isDarkMode),
                ),
              );
            },
            tooltip: 'Ayuda',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grafos',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'La teoría de grafos es una rama de las matemáticas y de las ciencias de la computación que estudia estructuras formadas por elementos y las relaciones existentes entre ellos. Estas estructuras permiten representar de manera abstracta situaciones reales en las que diferentes objetos se encuentran conectados entre sí. Los grafos tienen numerosas aplicaciones en áreas como redes informáticas, sistemas de transporte, redes sociales, planificación, logística, inteligencia artificial y resolución de problemas de optimización.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 13),
                        Text(
                          'Un grafo se representa generalmente mediante el conjunto (G=(V,E)), donde (V) representa el conjunto de vértices o nodos y (E) representa el conjunto de aristas. Los vértices son los elementos que forman parte del grafo, mientras que las aristas representan las relaciones o conexiones existentes entre ellos. Por ejemplo, en una red de transporte, los nodos podrían representar ciudades y las aristas podrían representar las carreteras que las conectan.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 13),
                        Text(
                          'Los vértices o nodos son los elementos principales de un grafo. Cada nodo puede identificarse mediante un nombre, número o etiqueta y, dependiendo de la aplicación, puede almacenar información adicional. En el proyecto desarrollado, los nodos fueron utilizados para representar los diferentes elementos del problema y podían contener atributos que permitían diferenciarlos y clasificarlos.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 13),
                        Text(
                          'Las aristas son las conexiones entre dos vértices. Una arista puede representar diferentes tipos de relaciones dependiendo del problema que se esté estudiando. En determinados grafos, las aristas pueden tener asociado un peso, que representa un valor relacionado con esa conexión, como un costo, distancia, tiempo, beneficio o capacidad. En la aplicación desarrollada, los valores de las relaciones fueron utilizados posteriormente para construir las matrices necesarias para los problemas de asignación.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- PRESENTACIÓN DEL EQUIPO CON TEMÁTICA IA ---
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ariana Beltran Soliz',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Se encargó principalmente de la interfaz gráfica y el diseño visual de la aplicación. Trabajó en la organización de las pantallas, botones, menús y elementos visuales, buscando que la aplicación fuera clara y fácil de utilizar. También participó en la integración de las diferentes funcionalidades dentro de la interfaz.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 40),

                        Text(
                          'Camila Perez Cano',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Se encargó de la gestión y representación de los grafos. Trabajó con la creación, modificación y eliminación de nodos y aristas, además de la información asociada a cada nodo. También participó en la representación visual del grafo y en la conexión entre los elementos que conformaban la estructura.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Andres Pabon Sotomayor',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Se encargó de la construcción y manejo de las matrices utilizadas por la aplicación. Trabajó en la generación de la matriz a partir de los nodos y las aristas del grafo, incluyendo la organización de filas, columnas, sumas y cantidad de nodos o relaciones. También participó en el procesamiento de los datos necesarios para los problemas de asignación.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Christian Lopez Tejerina',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Se encargó principalmente de la implementación de los algoritmos de asignación, especialmente del algoritmo Húngaro. Trabajó en el procesamiento de las matrices, tanto para problemas de minimización como de maximización, y en la obtención de las asignaciones óptimas. También participó en la representación de los pasos realizados por el algoritmo para poder visualizar el procedimiento.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Adriana Quiroz Yujra',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Se encargó de la integración y funcionamiento general de la aplicación. Trabajó en conectar las diferentes partes desarrolladas por el equipo, como la interfaz, los grafos, las matrices y los algoritmos, verificando que los datos pudieran pasar correctamente de una función a otra. También participó en las pruebas de funcionamiento y en la corrección de errores para obtener el resultado final del proyecto.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Módulos y Algoritmos',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // --- CARRUSEL HORIZONTAL CON IMÁGENES ---
            SizedBox(
              height:
                  250, // Altura ajustada para dar espacio a la imagen y textos
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: algorithmList.length,
                itemBuilder: (context, index) {
                  final algo = algorithmList[index];
                  return Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          // Si es grafo libre, va directo. Si no, pasa por la pantalla de teoría
                          if (algo['algorithmType'] == 'free') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GraphScreen(
                                  initialBipartiteAssignment: false,
                                  algorithmType: 'free',
                                  algorithmTitle: 'Grafo Simple / Libre',
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlgorithmTheoryScreen(
                                  algorithmName: algo['title'],
                                  theoryDescription: algo['theory'],
                                  icon: algo['icon'],
                                  isDarkMode: isDarkMode,
                                  algorithmType: algo['algorithmType'],
                                  isBipartite: algo['isBipartite'],
                                  youtubeUrl: algo['youtubeUrl'],
                                ),
                              ),
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ---> IMAGEN DE LA TARJETA <---
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                              child: Image.asset(
                                algo['imageUrl'],
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback por si la imagen tarda en cargar o no existe aún
                                  return Container(
                                    height: 110,
                                    color: accentColor.withValues(alpha: 0.1),
                                    child: Center(
                                      child: Icon(
                                        algo['icon'],
                                        color: accentColor,
                                        size: 36,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // ---> CONTENIDO DE TEXTO <---
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      algo['title'],
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      algo['subtitle'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.black54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accentColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.edit_note_rounded, color: accentColor),
                label: Text(
                  'Abrir Lienzo Libre de Grafos',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GraphScreen(
                        initialBipartiteAssignment: false,
                        algorithmType: 'free',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(accentColor, cardColor),
    );
  }

  Widget _buildBottomNav(Color accentColor, Color cardColor) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      backgroundColor: cardColor,
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_shared_rounded),
          label: 'Archivos Guardados',
        ),
      ],
    );
  }
}
