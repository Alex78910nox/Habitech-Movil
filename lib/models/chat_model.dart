import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Chat {
  final int id;
  final int remitenteId;
  final String remitenteNombre;
  final String remitenteApellido;
  final int destinatarioId;
  final String destinatarioNombre;
  final String destinatarioApellido;
  final String mensaje;
  final String tipoMensaje;
  final bool leido;
  final DateTime creadoEn;
  final String? urlArchivo;

  Chat({
    required this.id,
    required this.remitenteId,
    required this.remitenteNombre,
    required this.remitenteApellido,
    required this.destinatarioId,
    required this.destinatarioNombre,
    required this.destinatarioApellido,
    required this.mensaje,
    required this.tipoMensaje,
    required this.leido,
    required this.creadoEn,
    this.urlArchivo,
  });

  String get nombreCompleto => '$remitenteNombre $remitenteApellido';

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as int,
      remitenteId: json['remitente_id'] as int,
      remitenteNombre: json['remitente_nombre'] as String,
      remitenteApellido: json['remitente_apellido'] as String,
      destinatarioId: json['destinatario_id'] as int,
      destinatarioNombre: json['destinatario_nombre'] as String,
      destinatarioApellido: json['destinatario_apellido'] as String,
      mensaje: json['mensaje'] as String,
      tipoMensaje: json['tipo_mensaje'] as String,
      leido: json['leido'] as bool,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      urlArchivo: json['url_archivo'] as String?,
    );
  }
}

class ChatMensaje {
  final int id;
  final int remitenteId;
  final int destinatarioId;
  final String mensaje;
  final String tipoMensaje;
  final bool leido;
  final DateTime creadoEn;
  final String? urlArchivo;

  ChatMensaje({
    required this.id,
    required this.remitenteId,
    required this.destinatarioId,
    required this.mensaje,
    required this.tipoMensaje,
    required this.leido,
    required this.creadoEn,
    this.urlArchivo,
  });

  factory ChatMensaje.fromJson(Map<String, dynamic> json) {
    return ChatMensaje(
      id: json['id'] as int,
      remitenteId: json['remitente_id'] as int,
      destinatarioId: json['destinatario_id'] as int,
      mensaje: json['mensaje'] as String,
      tipoMensaje: json['tipo_mensaje'] as String,
      leido: json['leido'] as bool,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      urlArchivo: json['url_archivo'] as String?,
    );
  }
}

class ChatService {
  static const String baseUrl = 'https://apitaller.onrender.com/api';

  static Future<List<Chat>> getConversaciones(int usuarioId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mensajes_chat/conversaciones/$usuarioId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['conversaciones'] as List)
          .map((json) => Chat.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al obtener conversaciones');
    }
  }

  static Future<List<ChatMensaje>> getMensajes(int usuarioId, int contactoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mensajes_chat/$usuarioId/$contactoId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('mensajes')) {
          return (data['mensajes'] as List)
              .map((json) => ChatMensaje.fromJson(json))
              .toList();
        } else {
          print('Respuesta sin mensajes: ${response.body}');
          return [];
        }
      } else {
        print('Error en la respuesta: ${response.statusCode} - ${response.body}');
        throw Exception('Error al obtener mensajes. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener mensajes: $e');
      rethrow;
    }
  }

  static Future<ChatMensaje> enviarMensaje({
    required int remitenteId,
    required int destinatarioId,
    required String mensaje,
    String tipoMensaje = 'texto',
    String? urlArchivo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mensajes_chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'remitente_id': remitenteId,
        'destinatario_id': destinatarioId,
        'mensaje': mensaje,
        'tipo_mensaje': tipoMensaje,
        'url_archivo': urlArchivo,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return ChatMensaje.fromJson(data['mensaje']);
    } else {
      throw Exception('Error al enviar mensaje');
    }
  }

  static Future<void> marcarComoLeidos(int usuarioId, int remitenteId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/mensajes_chat/leidos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuario_id': usuarioId,
          'remitente_id': remitenteId,
        }),
      );

      if (response.statusCode != 200) {
        print('Error al marcar como leídos: ${response.statusCode} - ${response.body}');
        throw Exception('Error al marcar mensajes como leídos. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al marcar mensajes como leídos: $e');
      rethrow;
    }
  }
}