import 'package:flutter/material.dart';
import '../colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Center(child: Text('Inicio (placeholder)', style: TextStyle(color: HabitechColors.azulOscuro))),
    );
  }
}
