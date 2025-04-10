class Proveedor {
  final String nombre;
  final String correo;
  final String telefono;
  final String direccion;
  final String rfc;

  Proveedor({
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.direccion,
    required this.rfc,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'rfc': rfc,
    };
  }

  static Proveedor fromJson(Map<String, dynamic> json) {
  return Proveedor(
    nombre: json['nombre'],
    correo: json['correo'],
    telefono: json['telefono'],
    direccion: json['direccion'],
    rfc: json['rfc'],
  );
}

}