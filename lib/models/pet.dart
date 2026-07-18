import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id;
  final String nombre;
  final String raza;
  final String color;
  final String descripcion;
  final DateTime fechaPerdida;
  final String lugar;
  final String contacto;
  final String? recompensa;
  final String estado; // "Perdido" | "Encontrado"
  final String fotoUrl;
  final String userId;

  Pet({
    required this.id,
    required this.nombre,
    required this.raza,
    required this.color,
    required this.descripcion,
    required this.fechaPerdida,
    required this.lugar,
    required this.contacto,
    this.recompensa,
    required this.estado,
    required this.fotoUrl,
    required this.userId,
  });

  Pet copyWith({
    String? id,
    String? nombre,
    String? raza,
    String? color,
    String? descripcion,
    DateTime? fechaPerdida,
    String? lugar,
    String? contacto,
    String? recompensa,
    String? estado,
    String? fotoUrl,
    String? userId,
  }) {
    return Pet(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      raza: raza ?? this.raza,
      color: color ?? this.color,
      descripcion: descripcion ?? this.descripcion,
      fechaPerdida: fechaPerdida ?? this.fechaPerdida,
      lugar: lugar ?? this.lugar,
      contacto: contacto ?? this.contacto,
      recompensa: recompensa ?? this.recompensa,
      estado: estado ?? this.estado,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'raza': raza,
      'color': color,
      'descripcion': descripcion,
      'fechaPerdida': Timestamp.fromDate(fechaPerdida),
      'lugar': lugar,
      'contacto': contacto,
      'recompensa': recompensa,
      'estado': estado,
      'fotoUrl': fotoUrl,
      'userId': userId,
    };
  }

  factory Pet.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic dateVal) {
      if (dateVal == null) return DateTime.now();
      if (dateVal is Timestamp) return dateVal.toDate();
      if (dateVal is String) return DateTime.tryParse(dateVal) ?? DateTime.now();
      if (dateVal is int) return DateTime.fromMillisecondsSinceEpoch(dateVal);
      return DateTime.now();
    }

    return Pet(
      id: id,
      nombre: map['nombre'] ?? '',
      raza: map['raza'] ?? '',
      color: map['color'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fechaPerdida: parseDate(map['fechaPerdida']),
      lugar: map['lugar'] ?? '',
      contacto: map['contacto'] ?? '',
      recompensa: map['recompensa'],
      estado: map['estado'] ?? 'Perdido',
      fotoUrl: map['fotoUrl'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}
