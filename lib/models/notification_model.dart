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
  final String? urlAccion;
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
    this.urlAccion,
    required this.leido,
    this.leidoEn,
    required this.creadoEn,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      titulo: json['titulo'] as String? ?? 'Sin título',
      mensaje: json['mensaje'] as String? ?? 'Sin mensaje',
      tipo: json['tipo'] as String? ?? 'anuncio',
      idRelacionado: json['id_relacionado'],
      icono: json['icono'] as String? ?? 'info',
      urlAccion: json['url_accion'] as String?,
      leido: json['leido'] as bool? ?? false,
      leidoEn: json['leido_en'] != null ? DateTime.parse(json['leido_en'] as String) : null,
      creadoEn: json['creado_en'] != null 
          ? DateTime.parse(json['creado_en'] as String)
          : DateTime.now(),
    );
  }
}

Future<NotificationResponse> getUserNotifications(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('https://apitaller.onrender.com/api/notificaciones/usuario/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return NotificationResponse.fromJson(jsonData);
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al obtener notificaciones: $e');
    throw Exception('Error al obtener las notificaciones: $e');
  }
}