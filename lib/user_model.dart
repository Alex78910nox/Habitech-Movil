class Residente {
  final int id;
  final int usuarioId;
  final int departamentoId;
  final String tipoRelacion;
  final String? fechaIngreso;
  final String? fechaSalida;
  final String? nombreContactoEmergencia;
  final String? telefonoContactoEmergencia;
  final bool esPrincipal;
  final bool activo;

  Residente({
    required this.id,
    required this.usuarioId,
    required this.departamentoId,
    required this.tipoRelacion,
    this.fechaIngreso,
    this.fechaSalida,
    this.nombreContactoEmergencia,
    this.telefonoContactoEmergencia,
    required this.esPrincipal,
    required this.activo,
  });

  factory Residente.fromJson(Map<String, dynamic> json) {
    return Residente(
      id: json['id'],
      usuarioId: json['usuario_id'],
      departamentoId: json['departamento_id'],
      tipoRelacion: json['tipo_relacion'] ?? '',
      fechaIngreso: json['fecha_ingreso'],
      fechaSalida: json['fecha_salida'],
      nombreContactoEmergencia: json['nombre_contacto_emergencia'],
      telefonoContactoEmergencia: json['telefono_contacto_emergencia'],
      esPrincipal: json['es_principal'] ?? false,
      activo: json['activo'] ?? false,
    );
  }
}

class Departamento {
  final int id;
  final String numero;
  final int piso;
  final int dormitorios;
  final int banos;
  final String areaM2;
  final String rentaMensual;
  final String mantenimientoMensual;
  final String estado;
  final String descripcion;
  final Map<String, dynamic>? servicios;
  final List<String>? imagenes;
  final bool activo;

  Departamento({
    required this.id,
    required this.numero,
    required this.piso,
    required this.dormitorios,
    required this.banos,
    required this.areaM2,
    required this.rentaMensual,
    required this.mantenimientoMensual,
    required this.estado,
    required this.descripcion,
    this.servicios,
    this.imagenes,
    required this.activo,
  });

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      id: json['id'],
      numero: json['numero'] ?? '',
      piso: json['piso'] ?? 0,
      dormitorios: json['dormitorios'] ?? 0,
      banos: json['banos'] ?? 0,
      areaM2: json['area_m2'] ?? '0',
      rentaMensual: json['renta_mensual'] ?? '0',
      mantenimientoMensual: json['mantenimiento_mensual'] ?? '0',
      estado: json['estado'] ?? '',
      descripcion: json['descripcion'] ?? '',
      servicios: json['servicios'],
      imagenes: (json['imagenes'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      activo: json['activo'] ?? false,
    );
  }
}

class User {
  final int id;
  final String correo;
  final String nombre;
  final String apellido;
  final String telefono;
  final String numeroDocumento;
  final String? imagenPerfil;
  final bool activo;
  final int rolId;
  final Residente? residente;
  final Departamento? departamento;

  User({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.numeroDocumento,
    required this.imagenPerfil,
    required this.activo,
    required this.rolId,
    this.residente,
    this.departamento,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      correo: json['correo'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      telefono: json['telefono'] ?? '',
      numeroDocumento: json['numero_documento'] ?? '',
      imagenPerfil: json['imagen_perfil'],
      activo: json['activo'] ?? false,
      rolId: json['rol_id'] ?? 2,
    );
  }

  User copyWith({Residente? residente, Departamento? departamento}) {
    return User(
      id: id,
      correo: correo,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      numeroDocumento: numeroDocumento,
      imagenPerfil: imagenPerfil,
      activo: activo,
      rolId: rolId,
      residente: residente ?? this.residente,
      departamento: departamento ?? this.departamento,
    );
  }
}
