import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  String _message = '';

  Future<void> _register() async {
    // Nuevo endpoint para registro con doble factor (local)
    final url = Uri.parse('https://apitaller.onrender.com/api/registro-doble-factor');
    // Encriptar la contraseña usando SHA-256
    String password = _passController.text;
    String hashedPassword = sha256.convert(utf8.encode(password)).toString();

    // Normalizar teléfono para Bolivia: si no tiene prefijo, anteponer +591
    String telefonoRaw = _telefonoController.text.trim();
    // Mantener el + si el usuario lo incluyó, eliminar otros caracteres no numéricos
    String telefonoDigits = telefonoRaw.replaceAll(RegExp(r"[^0-9+]"), '');
    String telefonoFinal;
    if (telefonoDigits.startsWith('00')) {
      // convertir 00xxx a +xxx
      telefonoFinal = '+' + telefonoDigits.substring(2);
    } else if (telefonoDigits.startsWith('+')) {
      telefonoFinal = telefonoDigits;
    } else if (telefonoDigits.isEmpty) {
      telefonoFinal = '';
    } else {
      // Asumir número boliviano sin prefijo
      telefonoFinal = '+591' + telefonoDigits;
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': _userController.text.trim(),
        'hash_contrasena': hashedPassword,
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'telefono': telefonoFinal,
        'numero_documento': _documentoController.text.trim(),
        'rol_id': 2,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && (data['success'] == true || data['exito'] == true)) {
      // Registro inicial aceptado: ahora solicitar códigos al usuario
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TwoFactorDialog(correo: _userController.text.trim()),
      ).then((verified) {
        if (verified == true) {
          // Verificación exitosa: volver al login
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro verificado. Ya puedes iniciar sesión.')),
          );
          Navigator.pop(context); // cerrar la pantalla de registro y volver al login
        }
      });
    } else {
      setState(() {
        _message = 'Error al crear la cuenta: ' + (data['mensaje'] ?? 'Intenta de nuevo');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabitechColors.azulOscuro,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  const Text(
                    'HABITECH',
                    style: TextStyle(
                      color: HabitechColors.blancoPuro,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gestión inteligente, convivencia eficiente',
                    style: TextStyle(
                      color: HabitechColors.grisClaro,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Ingresa tu correo',
                      prefixIcon: Icon(Icons.email, color: HabitechColors.azulOscuro),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Ingresa tu contraseña',
                      prefixIcon: Icon(Icons.lock, color: HabitechColors.azulOscuro),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Ingresa tu nombre',
                      prefixIcon: Icon(Icons.person, color: HabitechColors.azulOscuro),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apellidoController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Ingresa tu apellido',
                      prefixIcon: Icon(Icons.person_outline, color: HabitechColors.azulOscuro),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Ingresa tu teléfono',
                      prefixIcon: Icon(Icons.phone, color: HabitechColors.azulOscuro),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _documentoController,
                    decoration: const InputDecoration(
                      labelText: 'Documento',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Ingresa tu número de documento',
                      prefixIcon: Icon(Icons.badge, color: HabitechColors.azulOscuro),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _register,
                    child: const Text('Crear cuenta de usuario'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Volver al login', style: TextStyle(color: HabitechColors.azulElectrico)),
                  ),
                  const SizedBox(height: 16),
                  if (_message.isNotEmpty)
                    Text(
                      _message,
                      style: const TextStyle(color: HabitechColors.azulElectrico, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Diálogo que pide los códigos recibidos por correo y SMS y los verifica
class TwoFactorDialog extends StatefulWidget {
  final String correo;
  const TwoFactorDialog({super.key, required this.correo});

  @override
  State<TwoFactorDialog> createState() => _TwoFactorDialogState();
}

class _TwoFactorDialogState extends State<TwoFactorDialog> {
  final _codigoCorreoController = TextEditingController();
  final _codigoTelefonoController = TextEditingController();
  bool _isVerifying = false;
  String _error = '';

  Future<void> _verify() async {
    setState(() {
      _isVerifying = true;
      _error = '';
    });

    final url = Uri.parse('https://apitaller.onrender.com/api/verificar-doble-factor');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': widget.correo,
          'codigoCorreo': _codigoCorreoController.text.trim(),
          'codigoTelefono': _codigoTelefonoController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && (data['success'] == true || data['exito'] == true)) {
        if (!mounted) return;
        Navigator.of(context).pop(true); // verificado
        return;
      } else {
        setState(() {
          _error = data['mensaje'] ?? data['message'] ?? 'Códigos incorrectos';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
      });
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verificar doble factor'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Se enviaron códigos a tu correo y teléfono para: ${widget.correo}'),
          const SizedBox(height: 12),
          TextField(
            controller: _codigoCorreoController,
            decoration: const InputDecoration(labelText: 'Código recibido por correo'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _codigoTelefonoController,
            decoration: const InputDecoration(labelText: 'Código recibido por SMS'),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_error, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verify,
          child: _isVerifying ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Verificar'),
        ),
      ],
    );
  }
}
