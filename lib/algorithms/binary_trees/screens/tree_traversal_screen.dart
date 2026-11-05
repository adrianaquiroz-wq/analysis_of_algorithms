import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_model.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_reconstructor.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_traversal_controller.dart';
import 'package:graph_app/algorithms/binary_trees/storage/saved_tree.dart';
import 'package:graph_app/algorithms/binary_trees/tree_traversal_help.dart';
import 'package:graph_app/algorithms/binary_trees/widgets/tree_stage.dart';
import 'package:graph_app/algorithms/sorting/screens/sorting_help_screen.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';
import 'package:graph_app/theme/theme_controller.dart';
import 'package:graph_app/utils/graph_storage_dialogs.dart';
import 'package:graph_app/widgets/drawer.dart';

/// Árboles binarios: crear (teclado / aleatorio / reconstruir), ver los tres
/// recorridos y recorrer el árbol con un mono.
class TreeTraversalScreen extends StatefulWidget {
  const TreeTraversalScreen({super.key});

  @override
  State<TreeTraversalScreen> createState() => _TreeTraversalScreenState();
}

class _TreeTraversalScreenState extends State<TreeTraversalScreen> {
  static const String _example = '8, 3, 10, 1, 6, 14, 4, 7, 13';

  final TreeTraversalController _c = TreeTraversalController();
  final TreeStorageService _storage = TreeStorageService();

  final _keyInput = TextEditingController();
  final _min = TextEditingController(text: '1');
  final _max = TextEditingController(text: '100');
  final _count = TextEditingController(text: '9');
  final _reconA = TextEditingController();
  final _reconB = TextEditingController();
  final ValueNotifier<bool> _lockScroll = ValueNotifier<bool>(false);

  ReconstructPair _pair = ReconstructPair.inPre;
  String? _keyError;
  String? _randError;
  String? _reconError;

  String? _currentId;
  String? _currentName;

  static final _listFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9,;\s\-]'));
  static final _intFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]'));

  @override
  void dispose() {
    _c.dispose();
    for (final t in [_keyInput, _min, _max, _count, _reconA, _reconB]) {
      t.dispose();
    }
    _lockScroll.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _detachFile() {
    _currentId = null;
    _currentName = null;
  }

  // ------------------------------------------------------------- Acciones

  void _create() {
    final err = _c.createFromText(_keyInput.text);
    setState(() {
      _keyError = err;
      _randError = null;
      _reconError = null;
      if (err == null) _detachFile();
    });
  }

  void _useExample() {
    _keyInput.text = _example;
    _create();
  }

  void _random() {
    final err = _c.generateRandom(
      int.tryParse(_min.text.trim()),
      int.tryParse(_max.text.trim()),
      int.tryParse(_count.text.trim()),
    );
    setState(() {
      _randError = err;
      _keyError = null;
      _reconError = null;
      if (err == null) _detachFile();
    });
  }

  void _reconstruct() {
    final err = _c.reconstructFromText(_pair, _reconA.text, _reconB.text);
    setState(() {
      _reconError = err;
      _keyError = null;
      _randError = null;
      if (err == null) _detachFile();
    });
  }

  void _useCurrentTraversals() {
    if (_c.tree.root == null) {
      setState(() => _reconError = 'No hay un árbol del que tomar recorridos.');
      return;
    }
    setState(() {
      _reconError = null;
      _reconA.text = _c.tree.traversal(_pair.first).join(', ');
      _reconB.text = _c.tree.traversal(_pair.second).join(', ');
    });
  }

  void _clear() {
    _c.clear();
    setState(() {
      _detachFile();
      _keyError = null;
      _randError = null;
      _reconError = null;
    });
  }

  Future<void> _save() async {
    if (_c.tree.root == null) {
      _snack('Crea un árbol antes de guardar.');
      return;
    }
    final name = await GraphStorageDialogs.askGraphName(
      context,
      initialValue: _currentName,
      isDarkMode: ThemeController.instance.isDark,
    );
    if (name == null || !mounted) return;

    final id = _currentId ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.save(
      SavedTree(
        id: id,
        name: name,
        updatedAt: DateTime.now(),
        origin: _c.origin,
        tree: _c.tree,
        positions: Map.of(_c.positions),
        type: _c.type,
        cursor: _c.cursor,
        results: _c.allResults(),
        ambiguity: _c.ambiguity,
      ),
    );
    if (!mounted) return;
    setState(() {
      _currentId = id;
      _currentName = name;
    });
    _snack('Árbol "$name" guardado.');
  }

  Future<void> _openSaved() async {
    final p = AppPalette(ThemeController.instance.isDark);
    var items = await _storage.list();
    if (!mounted) return;

    final picked = await showDialog<SavedTree>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: p.card,
          title: Text('Árboles guardados', style: TextStyle(color: p.text)),
          content: SizedBox(
            width: double.maxFinite,
            child: items.isEmpty
                ? Text(
                    'Todavía no hay árboles guardados.',
                    style: TextStyle(color: p.subtleText),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final s = items[i];
                      final total = s.results[s.type]?.steps.length ?? 0;
                      return ListTile(
                        title: Text(s.name, style: TextStyle(color: p.text)),
                        subtitle: Text(
                          '${s.tree.size} nodos · ${s.origin}\n${s.type.label} · paso ${s.cursor}/$total',
                          style: TextStyle(color: p.subtleText, fontSize: 12),
                        ),
                        isThreeLine: true,
                        onTap: () => Navigator.pop(ctx, s),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            await _storage.delete(s.id);
                            setLocal(() => items = List.of(items)..removeAt(i));
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    _c.loadSaved(picked);
    setState(() {
      _currentId = picked.id;
      _currentName = picked.name;
      _keyError = null;
      _randError = null;
      _reconError = null;
    });
  }

  void _openHelp() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SortingHelpScreen(
        title: 'Árboles Binarios',
        sections: treeTraversalHelp,
      ),
    ),
  );

  // ------------------------------------------------------------------ UI

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) => _buildScreen(AppPalette(isDark)),
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

  InputDecoration _dec(AppPalette p, String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: p.subtleText),
    isDense: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );

  Widget _title(AppPalette p, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(color: p.text, fontWeight: FontWeight.bold),
    ),
  );

  Widget _err(String? e) => e == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(e, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
        );

  Widget _buildDrawer(AppPalette p) => GraphDrawer(
    isDarkMode: p.isDark,
    algorithmTitle: 'Árboles Binarios',
    headerIcon: Icons.account_tree_rounded,
    newLabel: 'Árbol Nuevo',
    saveLabel: 'Guardar Árbol',
    savedLabel: 'Árboles Guardados',
    onThemeChanged: ThemeController.instance.set,
    onNewCanvas: _clear,
    onSaveGraph: _save,
    onOpenSavedGraphs: _openSaved,
    onOpenHelp: _openHelp,
    onBackHome: () => Navigator.popUntil(context, (route) => route.isFirst),
  );

  Widget _buildScreen(AppPalette p) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        final panels = _spaced([
          _fileCard(p),
          _keyboardCard(p),
          _randomCard(p),
          _reconstructCard(p),
          _monkeyCard(p),
          for (final t in [
            TraversalType.preOrder,
            TraversalType.inOrder,
            TraversalType.postOrder,
          ])
            _traversalCard(p, t),
        ]);

        return Scaffold(
          backgroundColor: p.background,
          drawer: _buildDrawer(p),
          appBar: AppBar(
            backgroundColor: p.card,
            title: Text('Árboles Binarios', style: TextStyle(color: p.text)),
            iconTheme: IconThemeData(color: p.text),
          ),
          body: LayoutBuilder(
            builder: (context, box) {
              final stage = TreeStage(
                palette: p,
                controller: _c,
                onClear: _clear,
                onInteract: (v) => _lockScroll.value = v,
              );
              if (box.maxWidth >= 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: stage,
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                        children: panels,
                      ),
                    ),
                  ],
                );
              }
              return ValueListenableBuilder<bool>(
                valueListenable: _lockScroll,
                builder: (context, locked, _) => SingleChildScrollView(
                  physics: locked ? const NeverScrollableScrollPhysics() : null,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 430, child: stage),
                      const SizedBox(height: 12),
                      ...panels,
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _spaced(List<Widget> items) => [
    for (var i = 0; i < items.length; i++) ...[
      if (i > 0) const SizedBox(height: 12),
      items[i],
    ],
  ];

  Widget _fileCard(AppPalette p) {
    return _card(
      p,
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_rounded, size: 18),
            label: Text(_currentName == null ? 'Guardar' : 'Guardar "$_currentName"'),
          ),
          OutlinedButton.icon(
            onPressed: _openSaved,
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: const Text('Abrir'),
          ),
        ],
      ),
    );
  }

  Widget _keyboardCard(AppPalette p) {
    return _card(
      p,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(p, 'Crear por teclado'),
          TextField(
            controller: _keyInput,
            style: TextStyle(color: p.text),
            keyboardType: TextInputType.multiline,
            minLines: 2,
            maxLines: 4,
            inputFormatters: [_listFormatter],
            decoration: _dec(p, 'Números de inserción'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.account_tree_rounded),
              label: const Text('Crear árbol'),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _useExample,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Probar ejemplo listo'),
            ),
          ),
          _err(_keyError),
        ],
      ),
    );
  }

  Widget _randomCard(AppPalette p) {
    Widget field(TextEditingController c, String label) => TextField(
      controller: c,
      style: TextStyle(color: p.text),
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      inputFormatters: [_intFormatter],
      decoration: _dec(p, label),
    );
    return _card(
      p,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(p, 'Aleatorios por rango'),
          Row(
            children: [
              Expanded(child: field(_min, 'Mínimo')),
              const SizedBox(width: 8),
              Expanded(child: field(_max, 'Máximo')),
            ],
          ),
          const SizedBox(height: 8),
          field(_count, 'Cantidad de nodos'),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _random,
              icon: const Icon(Icons.shuffle_rounded, size: 18),
              label: const Text('Generar árbol aleatorio'),
            ),
          ),
          _err(_randError),
        ],
      ),
    );
  }

  Widget _reconstructCard(AppPalette p) {
    return _card(
      p,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(p, 'Reconstruir con dos recorridos'),
          Text(
            'Las dos listas deben contener los mismos números, sin repetir.',
            style: TextStyle(color: p.subtleText, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final pair in ReconstructPair.values)
                ChoiceChip(
                  label: Text(pair.label, style: const TextStyle(fontSize: 12)),
                  selected: _pair == pair,
                  onSelected: (_) => setState(() => _pair = pair),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reconA,
            style: TextStyle(color: p.text),
            keyboardType: TextInputType.multiline,
            minLines: 2,
            maxLines: 4,
            inputFormatters: [_listFormatter],
            decoration: _dec(p, 'Recorrido ${_pair.first.label}'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reconB,
            style: TextStyle(color: p.text),
            keyboardType: TextInputType.multiline,
            minLines: 2,
            maxLines: 4,
            inputFormatters: [_listFormatter],
            decoration: _dec(p, 'Recorrido ${_pair.second.label}'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _reconstruct,
              child: const Text('Reconstruir árbol'),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: _useCurrentTraversals,
              child: const Text('Usar recorridos del árbol actual'),
            ),
          ),
          _err(_reconError),
          if (_c.ambiguity != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
              ),
              child: Text(
                _c.ambiguity!,
                style: TextStyle(color: p.text, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _monkeyCard(AppPalette p) {
    final (String label, IconData icon, VoidCallback action) = switch (_c.state) {
      PlayState.idle => ('Soltar al mono', Icons.play_arrow_rounded, _c.start),
      PlayState.playing => ('Pausar', Icons.pause_rounded, _c.pause),
      PlayState.paused => ('Continuar', Icons.play_arrow_rounded, _c.resume),
      PlayState.done => ('Repetir', Icons.replay_rounded, _c.start),
    };
    final mono = TextStyle(
      color: p.text,
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return _card(
      p,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(p, 'Recorrer con el mono'),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<TraversalType>(
              showSelectedIcon: false,
              segments: [
                for (final t in TraversalType.values)
                  ButtonSegment(
                    value: t,
                    label: Text(t.label, style: const TextStyle(fontSize: 12)),
                  ),
              ],
              selected: {_c.type},
              onSelectionChanged: _c.isPlaying ? null : (s) => _c.setType(s.first),
            ),
          ),
          const SizedBox(height: 6),
          Text(_c.type.rule, style: TextStyle(color: p.subtleText, fontSize: 13)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.accent.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.pets_rounded, color: p.accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_c.note, style: TextStyle(color: p.text, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: action,
                  icon: Icon(icon),
                  label: Text(label),
                ),
              ),
              IconButton(
                tooltip: 'Paso a paso',
                icon: Icon(Icons.skip_next_rounded, color: p.text),
                onPressed: _c.isPlaying ? null : _c.stepForward,
              ),
              IconButton(
                tooltip: 'Reiniciar',
                icon: Icon(Icons.restart_alt_rounded, color: p.text),
                onPressed: _c.reset,
              ),
              DropdownButton<double>(
                value: _c.speed,
                dropdownColor: p.card,
                style: TextStyle(color: p.text),
                underline: const SizedBox.shrink(),
                items: const [0.5, 1.0, 2.0, 4.0]
                    .map((s) => DropdownMenuItem(value: s, child: Text('${s}x')))
                    .toList(),
                onChanged: (s) => s == null ? null : _c.setSpeed(s),
              ),
            ],
          ),
          Divider(color: p.divider, height: 24),
          Text(
            'Camino del mono',
            style: TextStyle(color: p.text, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _c.trail.isEmpty ? '—' : _c.trail.join(' → '),
            style: TextStyle(color: p.subtleText, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            'Recorrido ${_c.type.label}',
            style: TextStyle(color: p.text, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          SelectableText('{${_c.output.join(', ')}}', style: mono),
        ],
      ),
    );
  }

  Widget _traversalCard(AppPalette p, TraversalType t) {
    final values = _c.tree.traversal(t);
    return _card(
      p,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${t.label} · ${t.rule}',
            style: TextStyle(color: p.subtleText, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SelectableText(
            values.isEmpty ? '—' : values.join(', '),
            style: TextStyle(color: p.text, fontSize: 15),
          ),
        ],
      ),
    );
  }
}