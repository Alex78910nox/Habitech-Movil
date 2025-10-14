import 'dart:convert';
import 'package:flutter/material.dart';
import '../colors.dart';
import '../models/chat_model.dart';
import 'chat_detail_page.dart';
import 'package:http/http.dart' as http;

class NewChatPage extends StatefulWidget {
  final int usuarioId;
  
  const NewChatPage({super.key, required this.usuarioId});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('${ChatService.baseUrl}/usuarios'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Respuesta del servidor: $data'); // Para depuración

        if (data['exito'] == true && data['datos'] != null) {
          final List<dynamic> usuariosData = data['datos'];
          setState(() {
            _usuarios = usuariosData
                .where((json) => json != null) // Filtrar elementos nulos
                .map((json) => Usuario.fromJson(json))
                .where((usuario) => 
                    usuario.id != widget.usuarioId && // Excluir al usuario actual
                    usuario.isResidente) // Solo incluir residentes (rol_id: 2)
                .toList();
            _usuariosFiltrados = List.from(_usuarios);
            _isLoading = false;
          });
        } else {
          throw Exception('Formato de respuesta inválido: ${data['mensaje'] ?? 'Sin mensaje de error'}');
        }
      } else {
        throw Exception('Error al cargar usuarios: Código ${response.statusCode}');
      }
    } catch (e) {
      print('Error detallado: $e'); // Para depuración
      setState(() {
        _isLoading = false;
        _usuarios = [];
        _usuariosFiltrados = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar usuarios: $e')),
        );
      }
    }
  }

  void _filtrarUsuarios(String query) {
    setState(() {
      _usuariosFiltrados = _usuarios
          .where((usuario) =>
              usuario.nombreCompleto.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabitechColors.azulOscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Seleccionar Residente',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filtrarUsuarios,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar residente...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : _usuariosFiltrados.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'No hay residentes disponibles'
                              : 'No se encontraron residentes',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _usuariosFiltrados.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final usuario = _usuariosFiltrados[index];
                          return Card(
                            color: Colors.white.withOpacity(0.06),
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatDetailPage(
                                      contactoId: usuario.id,
                                      contactoNombre: usuario.nombreCompleto,
                                      usuarioId: widget.usuarioId,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: HabitechColors.azulElectrico,
                                      child: Text(
                                        usuario.iniciales,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        usuario.nombreCompleto,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final int rolId;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.rolId,
  });

  String get nombreCompleto => '$nombre $apellido';
  String get iniciales => nombre.isNotEmpty && apellido.isNotEmpty
      ? '${nombre[0]}${apellido[0]}'.toUpperCase()
      : '';
  
  bool get isResidente => rolId == 2;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      rolId: json['rol_id'] as int,
    );
  }
}