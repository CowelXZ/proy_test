class User {
  final int id;
  final String nombreCompleto;
  final String apellidos;
  final String telefono;
  final String usuario;
  final String cumpleanos;
  final String rfc;
  final String departamento;

  User({
    required this.id,
    required this.nombreCompleto,
    required this.apellidos,
    required this.telefono,
    required this.usuario,
    required this.cumpleanos,
    required this.rfc,
    required this.departamento,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombreCompleto,
      'apellidos': apellidos,
      'telefono': telefono,
      'usuario': usuario,
      'cumpleanos': cumpleanos,
      'rfc': rfc,
      'departamento': departamento,
    };
  }
  factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'],
    nombreCompleto: json['nombre_completo'] ?? 'No disponible',
    apellidos: json['apellidos'] ?? 'No disponible', // 🔥 Corregido aquí
    telefono: json['telefono'] ?? 'No disponible',
    usuario: json['usuario'] ?? 'No disponible',
    cumpleanos: json['cumpleanos'] ?? '',
    rfc: json['rfc'] ?? 'No disponible',
    departamento: json['departamento'] ?? 'No disponible',
  );
}

}

