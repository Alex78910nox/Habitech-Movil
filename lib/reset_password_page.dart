import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? initialToken;

  const ResetPasswordPage({Key? key, this.initialToken}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showTokenField = true; // show by default so user can paste token

  @override
  void initState() {
    super.initState();
    // Do NOT prefill the token received from the backend. The user must
    // manually paste the token that arrives by email into the form.
    _showTokenField = true;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final token = _tokenController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      final hashedPassword = digest.toString();

      final response = await http.post(
        Uri.parse('https://apitaller.onrender.com/api/restablecer-contrasena'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'nueva_contrasena': hashedPassword}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Contraseña restablecida correctamente')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${body['message'] ?? 'Desconocido'}')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error del servidor: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
      appBar: AppBar(
        title: Text('Restablecer contraseña'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Introduce el token que recibiste por correo y tu nueva contraseña.',
                style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.3),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '¿Tienes el token?',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showTokenField = !_showTokenField;
                      });
                    },
                    child: Text(_showTokenField ? 'Ocultar' : 'Pegar token'),
                  ),
                ],
              ),
              if (_showTokenField) ...[
                TextFormField(
                  controller: _tokenController,
                  style: TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Token',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el token';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
              ],
              TextFormField(
                controller: _passwordController,
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa la nueva contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  final upper = RegExp(r'[A-Z]');
                  final digit = RegExp(r'\d');
                  if (!upper.hasMatch(value) || !digit.hasMatch(value)) {
                    return 'Debe incluir al menos una mayúscula y un número';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _resetPassword,
                      child: Text('Restablecer contraseña'),
                    ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Volver al login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
