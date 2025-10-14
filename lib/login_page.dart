import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'colors.dart';
import 'register_page.dart';
import 'user_model.dart';
import 'user_page.dart';
import 'reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  int _failedAttempts = 0;
  bool _isLoading = false;

  Future<void> _login() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa los campos requeridos')),
      );
      return;
    }

    final correo = _usernameController.text.trim();
    final pass = _passwordController.text;

    // Quick feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Iniciando sesión...')),
    );

    final bytes = utf8.encode(pass);
    final digest = sha256.convert(bytes).toString();

    final url = Uri.parse('https://apitaller.onrender.com/api/login');
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo,
          'hash_contrasena': digest,
          'rol_id': 2,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
          if (data['success'] == true && data['usuario'] != null) {
          var user = User.fromJson(data['usuario']);
          if (!mounted) return;
          setState(() {
            _failedAttempts = 0;
          });

          // Intentar obtener datos de residente y departamento usando el id del usuario
          try {
            final id = user.id;
            final residenteUrl = Uri.parse('https://apitaller.onrender.com/api/residente-por-usuario/$id');
            final residenteResp = await http.get(residenteUrl, headers: {'Content-Type': 'application/json'});
            if (residenteResp.statusCode == 200) {
              final rdata = jsonDecode(residenteResp.body);
              if (rdata['success'] == true) {
                final residenteJson = rdata['residente'] as Map<String, dynamic>?;
                final departamentoJson = rdata['departamento'] as Map<String, dynamic>?;
                if (residenteJson != null) {
                  final residente = Residente.fromJson(residenteJson);
                  final departamento = departamentoJson != null ? Departamento.fromJson(departamentoJson) : null;
                  user = user.copyWith(residente: residente, departamento: departamento);
                }
              }
            }
          } catch (e) {
            // No bloquear el login por fallo en obtener residente; mostrar un mensaje breve
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo cargar datos adicionales: $e')));
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => UserPage(user: user)),
          );
          return;
        } else {
          if (!mounted) return;
          setState(() {
            _failedAttempts++;
          });
          final message = data['message'] ?? 'Credenciales inválidas';
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } else {
        if (!mounted) return;
        setState(() {
          _failedAttempts++;
        });
        String msg = 'Error en el servidor (${response.statusCode})';
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) msg = data['message'];
        } catch (_) {}
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _failedAttempts++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              child: Form(
                key: _formKey,
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
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        hintText: 'Ingresa tu correo',
                        prefixIcon: Icon(Icons.email, color: HabitechColors.azulOscuro),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => (value == null || value.isEmpty) ? 'Ingresa tu correo' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        hintText: 'Ingresa tu contraseña',
                        prefixIcon: Icon(Icons.lock, color: HabitechColors.azulOscuro),
                      ),
                      obscureText: true,
                      validator: (value) => (value == null || value.isEmpty) ? 'Ingresa tu contraseña' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Iniciar sesión'),
                    ),
                    const SizedBox(height: 16),
                    if (_failedAttempts > 0)
                      Text('Intentos fallidos: $_failedAttempts', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: const Text('Crear cuenta de usuario', style: TextStyle(color: HabitechColors.azulElectrico)),
                    ),
                    if (_failedAttempts >= 3)
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const _RequestResetDialog(),
                          );
                        },
                        child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: HabitechColors.azulElectrico)),
                      ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Diálogo para solicitar restablecimiento de contraseña
class _RequestResetDialog extends StatefulWidget {
  const _RequestResetDialog();

  @override
  State<_RequestResetDialog> createState() => _RequestResetDialogState();
}

class _RequestResetDialogState extends State<_RequestResetDialog> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Restablecer contraseña"),
      content: TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: "Ingrese su correo",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () async {
            String email = _emailController.text.trim();
            if (email.isNotEmpty) {
              // Llamar al endpoint de solicitar restablecimiento
              final url = Uri.parse('https://apitaller.onrender.com/api/solicitar-restablecimiento');
              try {
                final resp = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'correo': email}),
                );
                final data = jsonDecode(resp.body);
                if (resp.statusCode == 200 && data['success'] == true) {
                  final token = data['token'] as String?;
                  Navigator.pop(context);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token enviado a tu correo')),
                  );
                  // Abrir la página de restablecimiento con el token (si viene)
                  if (token != null && token.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ResetPasswordPage(initialToken: token)),
                    );
                  } else {
                    // Si el backend no devuelve token, abrir la página sin token y dejar que el usuario lo pegue
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ResetPasswordPage()),
                    );
                  }
                } else {
                  final msg = data['message'] ?? 'No se pudo generar el token';
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
              }
            }
          },
          child: const Text("Enviar"),
        ),
      ],
    );
  }
}
