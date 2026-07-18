class AppUser {
  final String id;
  final String nombre;
  final String correo;

  AppUser({
    required this.id,
    required this.nombre,
    required this.correo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      correo: map['correo'] ?? '',
    );
  }
}
