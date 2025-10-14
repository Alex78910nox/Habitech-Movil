import 'package:flutter/material.dart';
import '../colors.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: Center(child: Text('Mensajes (placeholder)', style: TextStyle(color: HabitechColors.azulOscuro))),
    );
  }
}
