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

  final List<Map<String, dynamic>> algorithms = [
    {
      'title': 'Simple graph',
      'subtitle': 'Lienzo abierto con un solo tipo de nodo estándar',
      'icon': Icons.hub_rounded,
      'algorithmType': 'free',
      'isBipartite': false,
      'theory': 'Permite crear grafos generales sin restricciones. Utiliza un único tipo de nodo estándar para modelado libre de redes y adyacencia.',
    },
    {
      'title': 'Allocation algorithm',
      'subtitle': 'Optimización con enfoque húngaro y dos tipos de nodo',
      'icon': Icons.psychology_rounded,
      'algorithmType': 'assignment',
      'isBipartite': true,
      'theory': 'El algoritmo de asignación (Método Húngaro) resuelve la distribución óptima de recursos utilizando matrices de costos. Requiere dos tipos de nodos (Conjunto A y Conjunto B).',
    },
    {
      'title': 'CPM (critical path)',
      'subtitle': 'Planificación de proyectos con un solo tipo de nodo',
      'icon': Icons.memory_rounded,
      'algorithmType': 'cpm',
      'isBipartite': false,
      'theory': 'El Método del Camino Crítico (CPM) analiza las dependencias de tareas en un proyecto utilizando un solo tipo de nodo para calcular la ruta más larga y tiempos críticos.',
    },
    {
      'title': 'Northwest Corner',
      'subtitle': 'Heurística de transporte con dos tipos de nodos',
      'icon': Icons.smart_toy_rounded,
      'algorithmType': 'northwest',
      'isBipartite': true,
      'theory': 'El método de la Esquina Noroeste genera una solución factible inicial para problemas de transporte asignando recursos de manera sistemática entre dos tipos de nodos.',
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
              'ST-GR / AI Graph Suite',
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
                          'Ariana Beltran Soliz ',
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

            // --- CARRUSEL HORIZONTAL ---
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: algorithms.length,
                itemBuilder: (context, index) {
                  final algo = algorithms[index];
                  return Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                      ),
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
                                ),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    algo['icon'],
                                    color: accentColor,
                                    size: 28,
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: accentColor.withValues(alpha: 0.6),
                                    size: 16,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                algo['title'],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
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
