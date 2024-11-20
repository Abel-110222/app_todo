import 'package:flutter/material.dart';
import 'screens/todo_list_screen.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App v3',
      theme: ThemeData(
        brightness: Brightness.light, // O Brightness.light para modo claro
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
