// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:todo_flutter_pwa/servies/api_service.dart';
import '../models/todo.dart';

class TodoItem extends StatefulWidget {
  final Todo todo;
  final VoidCallback onDelete;
  final Function(bool value) onUpdate;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  late bool isCompleted;
  bool isUpdating = false; // Para manejar el estado de actualización

  @override
  void initState() {
    super.initState();
    // Inicializamos isCompleted con el estado actual del todo
    isCompleted = widget.todo.completed;
  }

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isUpdating
                ? const CircularProgressIndicator() // Mostrar un indicador de carga mientras actualiza
                : IconButton(
                    icon: Icon(
                      isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isCompleted ? Colors.blue : null,
                    ),
                    onPressed: () async {
                      setState(() {
                        isUpdating = true; // Comienza el proceso de actualización
                      });

                      // Intentar actualizar el servidor
                      bool success = await apiService.updateTodo(widget.todo);

                      if (success) {
                        setState(() {
                          // Solo si el servidor responde exitosamente, actualizamos el estado local
                          isCompleted = !isCompleted;
                          widget.onUpdate(isCompleted);
                          isUpdating = false; // Fin del proceso de actualización
                        });
                      } else {
                        setState(() {
                          // Si falla, no cambiamos el estado
                          isUpdating = false; // Fin del proceso de actualización
                        });
                        // Mostrar un mensaje de error si falla
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to update Todo')),
                        );
                      }
                    },
                  ),
            Flexible(
              child: RichText(
                overflow: TextOverflow.ellipsis, // Añadir el desbordamiento de texto
                maxLines: 2, // Limitar a dos líneas si deseas mostrar el título y la descripción
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.todo.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, // Estilo del título
                        color: Colors.white, // Color del texto del título
                      ),
                    ),
                    TextSpan(
                      text: '\n${widget.todo.description}', // Añadir descripción con salto de línea
                      style: const TextStyle(
                        color: Colors.grey, // Color del texto de la descripción
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isCompleted ? 'Completed' : 'Not Completed',
                    style: TextStyle(
                        color: widget.todo.completed
                            ? const Color.fromARGB(255, 91, 241, 96)
                            : Colors.white)),
                const SizedBox(height: 5),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
