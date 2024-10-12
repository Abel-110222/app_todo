// ignore: file_names
import 'package:flutter/material.dart';

class MyButtonSave extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const MyButtonSave({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.green.withOpacity(0.5);
            } else if (states.contains(WidgetState.disabled)) {
              return Colors.green.withOpacity(0.5);
            }
            return Colors.white; // Color de fondo blanco deseado
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.green.withOpacity(0.5);
            }
            return Colors.green; // Color de primer plano rojo deseado
          },
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.green),
          ),
        ),
      ),
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono del botón si es necesario
            const SizedBox(width: 8),
            Text(text), // Texto del botón
          ],
        ),
      ),
    );
  }
}
