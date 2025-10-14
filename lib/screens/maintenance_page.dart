import 'package:flutter/material.dart';
import '../colors.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mantenimiento')),
      body: Center(child: Text('Solicitudes de mantenimiento (placeholder)', style: TextStyle(color: HabitechColors.azulOscuro))),
    );
  }
}
