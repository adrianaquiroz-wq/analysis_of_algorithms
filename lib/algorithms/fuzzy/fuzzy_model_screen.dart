import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:graph_app/utils/matlab_launcher.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';

class MatlabLabScreen extends StatefulWidget {
  const MatlabLabScreen({super.key});

  @override
  State<MatlabLabScreen> createState() => _MatlabLabScreenState();
}

class _MatlabLabScreenState extends State<MatlabLabScreen> {
  String? _error;
  bool? _serviceOk; // null = comprobando

  @override
  void initState() {
    super.initState();
    _checkService();
  }

  Future<void> _checkService() async {
    if (!kIsWeb) {
      setState(() => _serviceOk = false);
      return;
    }
    setState(() => _serviceOk = null);
    final ok = await MatlabLauncher.isAvailable();
    if (mounted) setState(() => _serviceOk = ok);
  }

  Future<void> _run(Future<String?> Function() action) async {
    final err = await action();
    if (!mounted) return;
    setState(() => _error = err);
    if (err == null) return;
    _checkService();
  }

  Future<void> _pickFis() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['fis'],
      withData: true,
    );
    final bytes = res?.files.single.bytes;
    if (bytes == null) return;
    await _run(() => MatlabLauncher.openFis(bytes));
  }

  Widget _banner(
    AppPalette p,
    String text,
    Color color, {
    VoidCallback? onClose,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.6)),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: p.text, fontSize: 13)),
        ),
        if (onClose != null)
          IconButton(
            icon: Icon(Icons.close, size: 18, color: p.text),
            onPressed: onClose,
          ),
      ],
    ),
  );

  Widget _tool(
    AppPalette p,
    IconData icon,
    String title,
    String desc,
    String button,
    VoidCallback? onTap,
  ) {
    return Card(
      color: p.card,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.cardBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: p.accent, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              style: TextStyle(
                color: p.subtleText,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(
                  button,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) => _screen(AppPalette(isDark)),
    );
  }

  Widget _screen(AppPalette p) {
    final enabled = kIsWeb;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.card,
        title: Text('MATLAB & Fuzzy', style: TextStyle(color: p.text)),
        iconTheme: IconThemeData(color: p.text),
        actions: [
          IconButton(
            tooltip: 'Comprobar servicio',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _checkService,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _banner(
            p,
            enabled
                ? 'Esta integración requiere MATLAB instalado en este equipo y el servicio local activo.'
                : 'Esta función solo está disponible en la versión web, ejecutada en tu computadora.',
            Colors.blue,
          ),
          if (enabled && _serviceOk == false)
            _banner(
              p,
              'El servicio local no está disponible. Inicia el servidor MATLAB '
              '(node matlabServer.js) y pulsa actualizar.',
              Colors.orange,
            ),
          if (_error != null && _error != '')
            _banner(
              p,
              _error!,
              Colors.redAccent,
              onClose: () => setState(() => _error = null),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _tool(
                  p,
                  Icons.functions_rounded,
                  'MATLAB',
                  'Abre el entorno de MATLAB para trabajar con tus modelos y scripts.',
                  'Abrir MATLAB',
                  enabled ? () => _run(MatlabLauncher.openMatlab) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _tool(
                  p,
                  Icons.science_outlined,
                  'Fuzzy Logic Designer',
                  'Abre el diseñador de sistemas difusos. Requiere Fuzzy Logic Toolbox.',
                  'Abrir Fuzzy Designer',
                  enabled ? () => _run(MatlabLauncher.openFuzzyDesigner) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _tool(
                  p,
                  Icons.upload_file_rounded,
                  'Tu sistema difuso',
                  'Carga un archivo .fis de hasta 2 MB para abrirlo en Fuzzy Logic Designer.',
                  'Seleccionar archivo .fis',
                  enabled ? _pickFis : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Antes de empezar',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                for (final t in const [
                  '1. Instala MATLAB y el Fuzzy Logic Toolbox.',
                  '2. En la carpeta del proyecto, ejecuta: node matlabServer.js',
                  r'3. Si MATLAB no abre, define la variable MATLAB_CMD con la ruta de matlab.exe, por ejemplo: C:\Program Files\MATLAB\R2024b\bin\matlab.exe',
                  '4. En Fuzzy Designer, pulsa Export → Export Fuzzy Inference System To Workspace.',
                  r"5. Ejemplo: writeFIS(prubilla, 'C:/APPS/prubilla') crea el archivo prubilla.fis.",
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      t,
                      style: TextStyle(color: p.subtleText, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
