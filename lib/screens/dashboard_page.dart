import 'package:flutter/material.dart';
import '../colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(child: Text('Dashboard (placeholder)', style: TextStyle(color: HabitechColors.azulOscuro))),
    );
  }
}
