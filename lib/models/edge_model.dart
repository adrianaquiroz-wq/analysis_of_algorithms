import 'package:flutter/material.dart';

enum EdgeType { simple, directed }

class EdgeModel {
  String id;
  String sourceId;
  String targetId;
  EdgeType type;
  double weight;
  Color color;

  EdgeModel({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.type = EdgeType.simple,
    this.weight = 1.0,
    this.color = Colors.white70,
  });

  EdgeModel copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    EdgeType? type,
    double? weight,
    Color? color,
  }) {
    return EdgeModel(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      type: type ?? this.type,
      weight: weight ?? this.weight,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceId': sourceId,
    'targetId': targetId,
    'type': type.name,
    'weight': weight,
    'color': color.value,
  };

  factory EdgeModel.fromJson(Map<String, dynamic> json) {
    return EdgeModel(
      id: json['id'] as String,
      sourceId: json['sourceId'] as String,
      targetId: json['targetId'] as String,
      type: EdgeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EdgeType.simple,
      ),
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      color: Color(json['color'] as int? ?? Colors.white70.value),
    );
  }
}
