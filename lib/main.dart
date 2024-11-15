import 'package:flutter/material.dart';
import 'screens/todo_list_screen.dart';

void main() {
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(
        brightness: Brightness.dark, // O Brightness.light para modo claro
        primarySwatch: Colors.blue,
        hintColor: Colors.blue, // Color de acento
        visualDensity: VisualDensity.adaptivePlatformDensity,

        // Personalización de Checkbox y otros íconos
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(Colors.blue), // Color de fondo del checkbox
          checkColor: WidgetStateProperty.all(Colors.white), // Color del ícono (marcado)
        ),
      ),
      home: const TodoListScreen(),
    );
  }
}
