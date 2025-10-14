import 'package:flutter/material.dart';
import '../colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Text('Bienvenido', style: TextStyle(fontSize: 24, color: HabitechColors.azulOscuro)),
      ),
    );
  }
}
