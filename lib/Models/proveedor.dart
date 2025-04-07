class Proveedor {
  final String nombre;
  final String telefono;
  final String correo;
  final String direccion;
  final String rfc;

  Proveedor({
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.direccion,
    required this.rfc,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      nombre: json['nombre'],
      telefono: json['telefono'],
      correo: json['correo'],
      direccion: json['direccion'],
      rfc: json['rfc'],
    );
  }
}
