import 'package:flutter/material.dart';
import 'colors.dart';
import 'user_model.dart';

class AdminPanel extends StatelessWidget {
  final User user;
  const AdminPanel({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabitechColors.azulOscuro,
      appBar: AppBar(title: const Text('Panel Administrador')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: HabitechColors.blancoPuro,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: HabitechColors.grisMedio.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: HabitechColors.azulElectrico,
                      child: Text(
                        user.nombre.isNotEmpty ? user.nombre[0] : '',
                        style: const TextStyle(
                          color: HabitechColors.blancoPuro,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.nombre} ${user.apellido}',
                            style: const TextStyle(
                              color: HabitechColors.azulOscuro,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.correo,
                            style: const TextStyle(
                              color: HabitechColors.grisMedio,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: HabitechColors.grisClaro),
                const SizedBox(height: 16),
                Text('Teléfono: ${user.telefono}', style: const TextStyle(fontSize: 16, color: HabitechColors.azulOscuro)),
                Text('Documento: ${user.numeroDocumento}', style: const TextStyle(fontSize: 16, color: HabitechColors.azulOscuro)),
                Text('Activo: ${user.activo ? "Sí" : "No"}', style: const TextStyle(fontSize: 16, color: HabitechColors.azulOscuro)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
