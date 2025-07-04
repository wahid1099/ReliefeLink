import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Incident {
  final String id;
  final String type;
  final String description;
  final String location;
  final String reporter;
  final DateTime timestamp;
  final Color color;
  final IconData icon;
  final bool synced;

  Incident({
    String? id,
    required this.type,
    required this.description,
    required this.location,
    required this.reporter,
    required this.timestamp,
    required this.color,
    required this.icon,
    this.synced = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'description': description,
    'location': location,
    'reporter': reporter,
    'timestamp': timestamp.toIso8601String(),
    'color': color.value,
    'icon': icon.codePoint,
    'synced': synced,
  };

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
    id: json['id'],
    type: json['type'],
    description: json['description'],
    location: json['location'],
    reporter: json['reporter'],
    timestamp: DateTime.parse(json['timestamp']),
    color: Color(json['color']),
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    synced: json['synced'] ?? false,
  );

  Incident copyWith({
    String? id,
    String? type,
    String? description,
    String? location,
    String? reporter,
    DateTime? timestamp,
    Color? color,
    IconData? icon,
    bool? synced,
  }) {
    return Incident(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      reporter: reporter ?? this.reporter,
      timestamp: timestamp ?? this.timestamp,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      synced: synced ?? this.synced,
    );
  }
}
