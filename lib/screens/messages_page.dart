import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../colors.dart';
import '../models/chat_model.dart';
import 'chat_detail_page.dart';
import 'new_chat_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late Future<List<Chat>> _conversacionesFuture;
  int? _usuarioId; // Obtener esto del usuario actual

  @override
  void initState() {
    super.initState();
    // TODO: Obtener el ID del usuario actual
    _usuarioId = 22; // Por ahora hardcodeado
    _conversacionesFuture = ChatService.getConversaciones(_usuarioId!);
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabitechColors.azulOscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mensajes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Chatea con otros residentes',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implementar búsqueda
            },
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewChatPage(usuarioId: _usuarioId!),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Chat>>(
        future: _conversacionesFuture,
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar las conversaciones: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _conversacionesFuture = ChatService.getConversaciones(_usuarioId!);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HabitechColors.azulElectrico,
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.message_outlined,
                        color: Colors.white.withOpacity(0.5), size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'No hay conversaciones aún',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inicia una conversación con otro residente',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementar nuevo mensaje
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nuevo mensaje'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HabitechColors.azulElectrico,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final chat = snapshot.data![index];
              final esRemitente = chat.remitenteId == _usuarioId;
              final nombreContacto = esRemitente
                  ? '${chat.destinatarioNombre} ${chat.destinatarioApellido}'
                  : '${chat.remitenteNombre} ${chat.remitenteApellido}';
              final iniciales = nombreContacto.split(' ')
                  .take(2)
                  .map((e) => e[0])
                  .join('')
                  .toUpperCase();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.white.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: chat.leido
                        ? Colors.transparent
                        : HabitechColors.azulElectrico,
                    width: chat.leido ? 0 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    // TODO: Navegar a la conversación
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailPage(
                          contactoId: esRemitente ? chat.destinatarioId : chat.remitenteId,
                          contactoNombre: nombreContacto,
                          usuarioId: _usuarioId!,
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
                          radius: 24,
                          backgroundColor: HabitechColors.azulElectrico,
                          child: Text(
                            iniciales,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    nombreContacto,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    timeago.format(chat.creadoEn, locale: 'es'),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chat.mensaje,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
