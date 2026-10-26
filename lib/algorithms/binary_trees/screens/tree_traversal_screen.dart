import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_model.dart';
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

/// Árboles binarios: construcción + In-order / Pre-order / Post-order con un mono.
class TreeTraversalScreen extends StatefulWidget {
  const TreeTraversalScreen({super.key});

  @override
  State<TreeTraversalScreen> createState() => _TreeTraversalScreenState();
}

class _TreeTraversalScreenState extends State<TreeTraversalScreen> {
  final TreeTraversalController _c = TreeTraversalController();
  final TextEditingController _input = TextEditingController();
  final TreeStorageService _storage = TreeStorageService();

  String? _currentId;
  String? _currentName;

  @override
  void dispose() {
    _c.dispose();
    _input.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // ------------------------------------------------------------- Acciones

  Future<void> _add() async {
    final nums = RegExp(r'\d+')
        .allMatches(_input.text)
        .map((m) => int.tryParse(m.group(0)!) ?? -1)
        .toList();
    if (nums.isEmpty) {
      _snack('Escribe uno o más números enteros.');
      return;
    }
    _input.clear();
    for (final v in nums) {
      final err = await _c.addValue(v);
      if (!mounted) return;
      if (err != null) _snack(err);
    }
  }

  void _random() {
    final rnd = Random();
    final set = <int>{};
    while (set.length < 7) {
      set.add(rnd.nextInt(99) + 1);
    }
    _currentId = null;
    _currentName = null;
    _c.setValues(set.toList());
  }

  void _newTree() {
    setState(() {
      _currentId = null;
      _currentName = null;
    });
    _c.clear();
    _snack('Árbol nuevo.');
  }

  Future<void> _save() async {
    if (_c.values.isEmpty) {
      _snack('Planta al menos un número antes de guardar.');
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
        values: _c.values,
        type: _c.type,
        cursor: _c.cursor,
        results: _c.allResults(),
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
                          '${s.values.length} nodos · ${s.type.label} · paso ${s.cursor}/$total',
                          style: TextStyle(color: p.subtleText, fontSize: 12),
                        ),
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
    setState(() {
      _currentId = picked.id;
      _currentName = picked.name;
    });
    _c.loadSaved(picked);
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

  Widget _buildDrawer(AppPalette p) => GraphDrawer(
    isDarkMode: p.isDark,
    algorithmTitle: 'Árboles Binarios',
    headerIcon: Icons.account_tree_rounded,
    newLabel: 'Árbol Nuevo',
    saveLabel: 'Guardar Árbol',
    savedLabel: 'Árboles Guardados',
    onThemeChanged: ThemeController.instance.set,
    onNewCanvas: _newTree,
    onSaveGraph: _save,
    onOpenSavedGraphs: _openSaved,
    onOpenHelp: _openHelp,
    onBackHome: () => Navigator.popUntil(context, (route) => route.isFirst),
  );

  Widget _buildScreen(AppPalette p) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        final busy = _c.isPlaying || _c.inserting;
        return Scaffold(
          backgroundColor: p.background,
          drawer: _buildDrawer(p),
          appBar: AppBar(
            backgroundColor: p.card,
            title: Text('Árboles Binarios', style: TextStyle(color: p.text)),
            iconTheme: IconThemeData(color: p.text),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _inputCard(p, busy),
                const SizedBox(height: 12),
                _typeCard(p, busy),
                const SizedBox(height: 12),
                _noteBanner(p),
                const SizedBox(height: 12),
                TreeStage(palette: p, controller: _c),
                const SizedBox(height: 12),
                _controls(p),
                const SizedBox(height: 12),
                _resultCard(p),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _inputCard(AppPalette p, bool busy) {
    return _card(
      p,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Construir el árbol',
            style: TextStyle(color: p.text, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  enabled: !busy,
                  style: TextStyle(color: p.text),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,\s]')),
                  ],
                  onSubmitted: (_) => _add(),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Ej: 50, 30, 70',
                    hintStyle: TextStyle(color: p.mutedText),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: busy ? null : _add,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Plantar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : _random,
                icon: const Icon(Icons.casino_rounded, size: 18),
                label: const Text('Aleatorio'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: busy ? null : _newTree,
                icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                label: const Text('Limpiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeCard(AppPalette p, bool busy) {
    return _card(
      p,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              onSelectionChanged: busy ? null : (s) => _c.setType(s.first),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _c.type.rule,
            style: TextStyle(color: p.subtleText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _noteBanner(AppPalette p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.pets_rounded, color: p.accent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_c.note, style: TextStyle(color: p.text, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _controls(AppPalette p) {
    final (String label, IconData icon, VoidCallback action) = switch (_c.state) {
      PlayState.idle => ('Soltar al mono', Icons.play_arrow_rounded, _c.start),
      PlayState.playing => ('Pausar', Icons.pause_rounded, _c.pause),
      PlayState.paused => ('Continuar', Icons.play_arrow_rounded, _c.resume),
      PlayState.done => ('Repetir', Icons.replay_rounded, _c.start),
    };
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _c.inserting ? null : action,
            icon: Icon(icon),
            label: Text(label),
          ),
        ),
        IconButton(
          tooltip: 'Paso a paso',
          icon: Icon(Icons.skip_next_rounded, color: p.text),
          onPressed: (_c.isPlaying || _c.inserting) ? null : _c.stepForward,
        ),
        IconButton(
          tooltip: 'Reiniciar',
          icon: Icon(Icons.restart_alt_rounded, color: p.text),
          onPressed: _c.inserting ? null : _c.reset,
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
    );
  }

  Widget _resultCard(AppPalette p) {
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
          Text(
            'Camino del mono',
            style: TextStyle(color: p.text, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _c.trail.isEmpty ? '—' : _c.trail.join(' → '),
            style: TextStyle(color: p.subtleText, fontSize: 13),
          ),
          Divider(color: p.divider, height: 24),
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
}