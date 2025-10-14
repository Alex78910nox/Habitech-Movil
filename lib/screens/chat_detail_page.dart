import 'package:flutter/material.dart';
import '../colors.dart';
import '../models/chat_model.dart';

class ChatDetailPage extends StatefulWidget {
  final int contactoId;
  final String contactoNombre;
  final int usuarioId;

  const ChatDetailPage({
    super.key,
    required this.contactoId,
    required this.contactoNombre,
    required this.usuarioId,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<List<ChatMensaje>> _mensajesFuture;
  bool _enviandoMensaje = false;

  @override
  void initState() {
    super.initState();
    _mensajesFuture = _cargarMensajes();
  }

  Future<List<ChatMensaje>> _cargarMensajes() async {
    try {
      // Primero cargar los mensajes
      final mensajes = await ChatService.getMensajes(
        widget.usuarioId,
        widget.contactoId,
      );

      // Intentar marcar como leídos sin bloquear la carga
      ChatService.marcarComoLeidos(widget.usuarioId, widget.contactoId).catchError((error) {
        print('Error al marcar mensajes como leídos: $error');
        // No lanzamos el error para que no afecte la visualización de mensajes
      });

      return mensajes;
    } catch (error) {
      print('Error al cargar mensajes: $error');
      rethrow;
    }
  }

  Future<void> _enviarMensaje() async {
    final mensaje = _mensajeController.text.trim();
    if (mensaje.isEmpty || _enviandoMensaje) return;

    setState(() {
      _enviandoMensaje = true;
    });

    try {
      await ChatService.enviarMensaje(
        remitenteId: widget.usuarioId,
        destinatarioId: widget.contactoId,
        mensaje: mensaje,
      );

      _mensajeController.clear();
      setState(() {
        _mensajesFuture = _cargarMensajes();
      });

      // Scroll al final
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el mensaje: $e')),
      );
    } finally {
      setState(() {
        _enviandoMensaje = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabitechColors.azulOscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: HabitechColors.azulElectrico,
              child: Text(
                widget.contactoNombre.split(' ').map((e) => e[0]).join('').toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contactoNombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'En línea', // TODO: Implementar estado real
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Implementar menú de opciones
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ChatMensaje>>(
              future: _mensajesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar los mensajes: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay mensajes aún',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final mensaje = snapshot.data![index];
                    final esMiMensaje = mensaje.remitenteId == widget.usuarioId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: esMiMensaje
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: esMiMensaje
                                  ? HabitechColors.azulElectrico
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16).copyWith(
                                bottomRight: esMiMensaje ? const Radius.circular(0) : null,
                                bottomLeft: !esMiMensaje ? const Radius.circular(0) : null,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mensaje.mensaje,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(mensaje.creadoEn),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () {
                    // TODO: Implementar adjuntar archivo
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                IconButton(
                  icon: _enviandoMensaje
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: _enviandoMensaje ? null : _enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}