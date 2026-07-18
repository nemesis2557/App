class AppUser {
  final String id;
  final String nombre;
  final String correo;
  final bool emailVerified;

  AppUser({
    required this.id,
    required this.nombre,
    required this.correo,
    this.emailVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'emailVerified': emailVerified,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      correo: map['correo'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
    );
  }
}
