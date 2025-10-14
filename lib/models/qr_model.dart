import 'dart:convert';
import 'package:http/http.dart' as http;

class QrResponse {
  final bool success;
  final QrData qr;

  QrResponse({
    required this.success,
    required this.qr,
  });

  factory QrResponse.fromJson(Map<String, dynamic> json) {
    return QrResponse(
      success: json['success'] as bool,
      qr: QrData.fromJson(json['qr'] as Map<String, dynamic>),
    );
  }
}

class QrData {
  final String token;
  final String image;
  final DateTime generadoEn;

  QrData({
    required this.token,
    required this.image,
    required this.generadoEn,
  });

  factory QrData.fromJson(Map<String, dynamic> json) {
    return QrData(
      token: json['token'] as String,
      image: json['image'] as String,
      generadoEn: DateTime.parse(json['generado_en'] as String),
    );
  }
}

Future<QrResponse> getUserQr(String userId) async {
  final response = await http.get(
    Uri.parse('https://apitaller.onrender.com/api/qr/usuario/$userId'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      // Aquí puedes agregar headers adicionales si son necesarios, como el token de autenticación
    },
  );

  if (response.statusCode == 200) {
    return QrResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Error al obtener el QR del usuario');
  }
}