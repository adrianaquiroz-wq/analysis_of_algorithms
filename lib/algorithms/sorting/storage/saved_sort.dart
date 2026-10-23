/// Un conjunto de números guardado para un método de ordenamiento.
class SavedSort {
  final String id;
  final String name;

  /// Método al que pertenece (por ejemplo 'shell_sort').
  final String sortId;
  final DateTime updatedAt;
  final List<int> values;
  final bool descending;

  /// Nombre legible del método: 'merge_sort' -> 'Merge Sort'.
  String get methodLabel => sortId
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  const SavedSort({
    required this.id,
    required this.name,
    required this.sortId,
    required this.updatedAt,
    required this.values,
    required this.descending,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sortId': sortId,
    'updatedAt': updatedAt.toIso8601String(),
    'values': values,
    'descending': descending,
  };

  factory SavedSort.fromJson(Map<String, dynamic> json) {
    return SavedSort(
      id: json['id'] as String,
      name: json['name'] as String,
      sortId: json['sortId'] as String? ?? 'shell_sort',
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      values: (json['values'] as List).map((e) => (e as num).toInt()).toList(),
      descending: json['descending'] as bool? ?? false,
    );
  }
}
