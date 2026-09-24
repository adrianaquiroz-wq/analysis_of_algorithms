import 'package:flutter/material.dart';

// Si ya tienes un modelo CPMActivity en lib/models/, elimina esta clase de aquí e impórtala
class CPMActivity {
  final String id;
  final String name;
  final int duration;
  final int es;
  final int ef;
  final int ls;
  final int lf;
  final int slack;
  final bool isCritical;

  CPMActivity({
    required this.id,
    required this.name,
    required this.duration,
    required this.es,
    required this.ef,
    required this.ls,
    required this.lf,
    required this.slack,
    required this.isCritical,
  });
}

class CPMActivityTableWidget extends StatelessWidget {
  final List<CPMActivity> activities;

  const CPMActivityTableWidget({Key? key, required this.activities})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tabla de Tiempos y Holguras (CPM)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Las actividades marcadas en rojo forman la Ruta Crítica (Holgura = 0).',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Actividad',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Duración',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ES',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'EF',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'LS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'LF',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Holgura',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Ruta Crítica',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: activities.map((act) {
                  final rowColor = act.isCritical
                      ? Colors.red.shade50
                      : Colors.transparent;
                  final textStyle = TextStyle(
                    fontWeight: act.isCritical
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: act.isCritical
                        ? Colors.red.shade900
                        : Colors.black87,
                  );

                  return DataRow(
                    color: WidgetStateProperty.all(rowColor),
                    cells: [
                      DataCell(
                        Text('${act.id} (${act.name})', style: textStyle),
                      ),
                      DataCell(Text('${act.duration}', style: textStyle)),
                      DataCell(Text('${act.es}', style: textStyle)),
                      DataCell(Text('${act.ef}', style: textStyle)),
                      DataCell(Text('${act.ls}', style: textStyle)),
                      DataCell(Text('${act.lf}', style: textStyle)),
                      DataCell(Text('${act.slack}', style: textStyle)),
                      DataCell(
                        Chip(
                          label: Text(
                            act.isCritical ? 'SÍ' : 'NO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          backgroundColor: act.isCritical
                              ? Colors.red
                              : Colors.grey,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
