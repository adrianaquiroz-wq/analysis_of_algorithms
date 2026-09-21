import 'package:flutter/material.dart';

enum BipartiteGroup { none, groupA, groupB }

class NodeModel {
  String id;
  String label;
  Offset position;
  Color color;
  String attribute1;
  String attribute2;
  BipartiteGroup bipartiteGroup; // Nuevo campo para grafos bipartitos

  NodeModel({
    required this.id,
    required this.label,
    required this.position,
    this.color = Colors.blue,
    this.attribute1 = '',
    this.attribute2 = '',
    this.bipartiteGroup = BipartiteGroup.none,
  });

  NodeModel copyWith({
    String? id,
    String? label,
    Offset? position,
    Color? color,
    String? attribute1,
    String? attribute2,
    BipartiteGroup? bipartiteGroup,
  }) {
    return NodeModel(
      id: id ?? this.id,
      label: label ?? this.label,
      position: position ?? this.position,
      color: color ?? this.color,
      attribute1: attribute1 ?? this.attribute1,
      attribute2: attribute2 ?? this.attribute2,
      bipartiteGroup: bipartiteGroup ?? this.bipartiteGroup,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'dx': position.dx,
    'dy': position.dy,
    'color': color.value,
    'attribute1': attribute1,
    'attribute2': attribute2,
    'bipartiteGroup': bipartiteGroup.index,
  };

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      position: Offset(
        (json['dx'] as num).toDouble(),
        (json['dy'] as num).toDouble(),
      ),
      color: Color(json['color'] as int? ?? Colors.blue.value),
      attribute1: json['attribute1'] as String? ?? '',
      attribute2: json['attribute2'] as String? ?? '',
      bipartiteGroup:
          BipartiteGroup.values[json['bipartiteGroup'] as int? ?? 0],
    );
  }
}
