import 'package:flutter/material.dart';

class HelpItem {
  final IconData icon;
  final String title;
  final String description;

  const HelpItem(this.icon, this.title, this.description);
}

/// Una sección con texto simple (`text`) o con filas (`items`).
class HelpSection {
  final String title;
  final String? text;
  final List<HelpItem> items;

  const HelpSection({required this.title, this.text, this.items = const []});
}

const String aiHelpTopic =
    'Te haré preguntas sobre algoritmos con los siguientes temas: asignación, CPM y la esquina noroeste. Respondeme primero con un: Hola amigo!';

const List<HelpSection> helpSections = [
  HelpSection(
    title: '1. Introducción',
    text: 'Bienvenido a la aplicación de Grafos. Esta herramienta te permite crear, editar y visualizar grafos de manera interactiva, soportando nodos, aristas dirigidas/no dirigidas, bucles automáticos y pesos personalizados.',
  ),
  HelpSection(
    title: '2. Herramientas Principales',
    items: [
      HelpItem(
        Icons.near_me,
        'Seleccionar / Mover:',
        'Permite arrastrar nodos libremente por el lienzo. Toca cualquier nodo o arista para ver sus propiedades, editarlo o eliminarlo.',
      ),
      HelpItem(
        Icons.radio_button_checked,
        'Agregar Nodo (Conjunto 1):',
        'Permite crear nodos circulares (ej. A, B, C, D) correspondientes al primer conjunto del grafo bipartito.',
      ),
      HelpItem(
        Icons.hub,
        'Agregar Nodo Bipartito (Conjunto 2):',
        'Permite crear nodos rectangulares/diferentes (ej. N.1, N.2, N.3, N.4) correspondientes al segundo conjunto para estructurar correctamente las asignaciones.',
      ),
      HelpItem(
        Icons.crop_free,
        'Selección de Área:',
        'Activa esta herramienta para arrastrar un rectángulo sobre el lienzo y seleccionar múltiples nodos a la vez mediante un gesto de arrastre.',
      ),
      HelpItem(
        Icons.show_chart,
        'Agregar Arista:',
        'Toca un nodo de origen y luego un nodo de destino para conectarlos y asignarles un peso o costo.',
      ),
    ],
  ),
  HelpSection(
    title: '3. Análisis y Matrices de Optimización',
    items: [
      HelpItem(
        Icons.grid_on,
        'Matriz de Adyacencia y Bipartita:',
        'Permite visualizar la representación matricial del grafo actual, facilitando la auditoría de pesos y conexiones entre los nodos.',
      ),
      HelpItem(
        Icons.calculate,
        'Modo Maximización y Minimización:',
        'Calcula de forma automática los valores óptimos basados en los costos o pesos de las aristas, estructurando los resultados paso a paso para mejor comprensión.',
      ),
    ],
  ),
  HelpSection(
    title: '4. Casos Especiales y Trucos',
    items: [
      HelpItem(
        Icons.loop,
        'Bucles Inteligentes (Self-Loops):',
        'Los bucles que conectan un nodo consigo mismo calculan automáticamente su orientación para evitar solaparse con otras aristas vecinas.',
      ),
      HelpItem(
        Icons.compare_arrows,
        'Aristas Bidireccionales:',
        'Si creas una conexión de A hacia B y otra de B hacia A, la aplicación curvará automáticamente ambas trayectorias para que no se superpongan.',
      ),
      HelpItem(
        Icons.delete_outline,
        'Eliminación Rápida de Aristas:',
        'Al tocar cualquier arista (incluyendo bucles), aparecerá un botón flotante con el ícono de basura exactamente en su punto medio para que puedas eliminarla con un toque.',
      ),
    ],
  ),
  HelpSection(
    title: '5. Interfaz y Controles',
    text:
        '• Usa los botones de Zoom (+, -, Restablecer) o pellizca la pantalla para acercar o alejar el lienzo gigante del grafo.\n\n'
        '• Puedes alternar entre el modo oscuro y claro desde la barra superior según tu preferencia visual.',
  ),
];
