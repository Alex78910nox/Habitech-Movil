import 'package:flutter/material.dart';
import 'login_page.dart';
import 'colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HABITECH',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: HabitechColors.azulOscuro,
          primary: HabitechColors.azulOscuro,
          secondary: HabitechColors.azulElectrico,
          background: HabitechColors.grisClaro,
        ),
        scaffoldBackgroundColor: HabitechColors.azulOscuro,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: HabitechColors.azulOscuro,
          foregroundColor: HabitechColors.blancoPuro,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: HabitechColors.grisClaro,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: HabitechColors.grisMedio),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: HabitechColors.azulElectrico),
          ),
          labelStyle: const TextStyle(color: HabitechColors.azulOscuro),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: HabitechColors.azulElectrico,
            foregroundColor: HabitechColors.blancoPuro,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
