class ReservaArea {
  final int id;
  final int areaId;
  final int residenteId;
  final String fechaReserva;
  final String horaInicio;
  final String horaFin;
  final String estado;
  final String montoPago;
  final String nombreArea;
  final String descripcionArea;
  final int capacidad;
  final double pagoPorUso;

  ReservaArea({
    required this.id,
    required this.areaId,
    required this.residenteId,
    required this.fechaReserva,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    required this.montoPago,
    required this.nombreArea,
    required this.descripcionArea,
    required this.capacidad,
    required this.pagoPorUso,
  });

  factory ReservaArea.fromJson(Map<String, dynamic> json) {
    return ReservaArea(
      id: json['id'],
      areaId: json['area_id'],
      residenteId: json['residente_id'],
      fechaReserva: json['fecha_reserva'],
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      estado: json['estado'],
      montoPago: json['monto_pago'],
      nombreArea: json['nombre_area'],
      descripcionArea: json['descripcion_area'],
      capacidad: json['capacidad'],
      pagoPorUso: double.tryParse(json['pago_por_uso'].toString()) ?? 0.0,
    );
  }
}
