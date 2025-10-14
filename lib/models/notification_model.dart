import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationResponse {
  final bool exito;
  final String mensaje;
  final List<NotificationData> datos;

  NotificationResponse({
    required this.exito,
    required this.mensaje,
    required this.datos,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      exito: json['exito'] as bool,
      mensaje: json['mensaje'] as String,
      datos: (json['datos'] as List<dynamic>)
          .map((e) => NotificationData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NotificationData {
  final int id;
  final int usuarioId;
  final String titulo;
  final String mensaje;
  final String tipo;
  final dynamic idRelacionado;
  final String icono;
  final String urlAccion;
  final bool leido;
  final DateTime? leidoEn;
  final DateTime creadoEn;

  NotificationData({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.idRelacionado,
    required this.icono,
    required this.urlAccion,
    required this.leido,
    this.leidoEn,
    required this.creadoEn,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      titulo: json['titulo'] as String,
      mensaje: json['mensaje'] as String,
      tipo: json['tipo'] as String,
      idRelacionado: json['id_relacionado'],
      icono: json['icono'] as String,
      urlAccion: json['url_accion'] as String,
      leido: json['leido'] as bool,
      leidoEn: json['leido_en'] != null ? DateTime.parse(json['leido_en']) : null,
      creadoEn: DateTime.parse(json['creado_en']),
    );
  }
}

Future<NotificationResponse> getUserNotifications(String userId) async {
  final response = await http.get(
    Uri.parse('https://apitaller.onrender.com/api/notificaciones/usuario/$userId'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return NotificationResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Error al obtener las notificaciones');
  }
}