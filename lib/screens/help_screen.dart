import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  final bool isDarkMode;

  const HelpScreen({super.key, this.isDarkMode = true});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final appBarColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDarkMode ? Colors.white12 : Colors.black12;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Manual de Usuario y Ayuda',
          style: TextStyle(color: titleColor, fontSize: 18),
        ),
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.cyanAccent : Colors.blueAccent,
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const _HelpSectionTitle(title: '1. Introducción'),
          _HelpCard(
            content: 'Bienvenido a la aplicación de Grafos. Esta herramienta te permite crear, editar y visualizar grafos de manera interactiva, soportando nodos, aristas dirigidas/no dirigidas, bucles automáticos y pesos personalizados.',
            cardColor: cardColor,
            borderColor: cardBorderColor,
            textColor: subTextColor,
          ),
          const SizedBox(height: 16),

          const _HelpSectionTitle(title: '2. Herramientas Principales'),
          _HelpCard(
            cardColor: cardColor,
            borderColor: cardBorderColor,
            children: [
              _HelpRowItem(
                icon: Icons.near_me,
                title: 'Seleccionar / Mover:',
                description: 'Permite arrastrar nodos libremente por el lienzo. Toca cualquier nodo o arista para ver sus propiedades, editarlo o eliminarlo.',
                titleColor: textColor,
                descColor: subTextColor,
                isDarkMode: isDarkMode,
              ),
              Divider(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                height: 20,
              ),
              _HelpRowItem(
                icon: Icons.radio_button_checked,
                title: 'Agregar Nodo (Conjunto 1):',
                description: 'Permite crear nodos circulares (ej. A, B, C, D) correspondientes al primer conjunto del grafo bipartito.',
                titleColor: textColor,
                descColor: subTextColor,
                isDarkMode: isDarkMode,
              ),
              Divider(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                height: 20,
              ),
              _HelpRowItem(
                icon: Icons.hub, // o el icono que use tu botón
                title: 'Agregar Nodo Bipartito (Conjunto 2):',
                description: 'Permite crear nodos rectangulares/diferentes (ej. N.1, N.2, N.3, N.4) correspondientes al segundo conjunto para estructurar correctamente las asignaciones.',
                titleColor: textColor,
                descColor: subTextColor,
                isDarkMode: isDarkMode,
              ),
              Divider(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                height: 20,
              ),
              _HelpRowItem(
                icon: Icons.crop_free,
                title: 'Selección de Área:',
                description: 'Activa esta herramienta para arrastrar un rectángulo sobre el lienzo y seleccionar múltiples nodos a la vez mediante un gesto de arrastre.',
                titleColor: textColor,
                descColor: subTextColor,
                isDarkMode: isDarkMode,
              ),
              Divider(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                height: 20,
              ),
              _HelpRowItem(
                icon: Icons.show_chart,
                title: 'Agregar Arista:',
                description: 'Toca un nodo de origen y luego un nodo de destino para conectarlos y asignarles un peso o costo.',
                titleColor: textColor,
                descColor: subTextColor,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 16),

          const _HelpSectionTitle(
            title: '3. Análisis y Matrices de Optimización',
          ),
          _HelpCard(
            cardColor: cardColor,
            borderColor: cardBorderColor,
            children: [
              _HelpRowItem(
                icon: Icons.grid_on,
                title: 'Matriz de Adyacencia y Bipartita:',
                description: 'Permite visualizar la representación matricial del grafo actual, facilitando la auditoría de pesos y conexiones entre los nodos.',
                titleColor: textColor,
                descColor: subTextColor,
                isDarkMode: isDarkMode,
              ),
              Divider(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                height: 20,
              ),
              _HelpRowItem(
                icon: Icons.calculate,
                title: 'Modo Maximización y Minimización:',
                description: 'Calcula de forma automática los valores óptimos basados en los costos o pesos de las aristas, estructurando los resultados paso a paso para mejor comprensión.',
                titleColor: textColor,
                descColor: subTextColor,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 16),

          const _HelpSectionTitle(title: '4. Casos Especiales y Trucos'),
          _HelpCard(
            cardColor: cardColor,
            borderColor: cardBorderColor,
            children: [
              _HelpRowItem(
                icon: Icons.loop,
                title: 'Bucles Inteligentes (Self-Loops):',
                description: 'Los bucles que conectan un nodo consigo mismo calculan automáticamente su orientación para evitar solaparse con otras aristas vecinas.',
                titleColor: textColor,
                descColor: subTextColor,
                isDarkMode: isDarkMode,
              ),
              Divider(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                height: 20,
              ),
              _HelpRowItem(
                icon: Icons.compare_arrows,
                title: 'Aristas Bidireccionales:',
                description: 'Si creas una conexión de A hacia B y otra de B hacia A, la aplicación curvará automáticamente ambas trayectorias para que no se superpongan.',
                titleColor: textColor,
                descColor: subTextColor,
                isDarkMode: isDarkMode,
              ),
              Divider(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                height: 20,
              ),
              _HelpRowItem(
                icon: Icons.delete_outline,
                title: 'Eliminación Rápida de Aristas:',
                description: 'Al tocar cualquier arista (incluyendo bucles), aparecerá un botón flotante con el ícono de basura exactamente en su punto medio para que puedas eliminarla con un toque.',
                titleColor: textColor,
                descColor: subTextColor,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 16),

          const _HelpSectionTitle(title: '5. Interfaz y Controles'),
          _HelpCard(
            content:
                '• Usa los botones de Zoom (+, -, Restablecer) o pellizca la pantalla para acercar o alejar el lienzo gigante del grafo.\n\n'
                '• Puedes alternar entre el modo oscuro y claro desde la barra superior según tu preferencia visual.',
            cardColor: cardColor,
            borderColor: cardBorderColor,
            textColor: subTextColor,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _HelpSectionTitle extends StatelessWidget {
  final String title;
  const _HelpSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final String? content;
  final List<Widget>? children;
  final Color cardColor;
  final Color borderColor;
  final Color? textColor;

  const _HelpCard({
    this.content,
    this.children,
    required this.cardColor,
    required this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: content != null
          ? Text(
              content!,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children ?? [],
            ),
    );
  }
}

class _HelpRowItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color titleColor;
  final Color descColor;
  final bool isDarkMode;

  const _HelpRowItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.titleColor,
    required this.descColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isDarkMode ? Colors.cyanAccent : Colors.blueAccent,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: descColor, fontSize: 13, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
