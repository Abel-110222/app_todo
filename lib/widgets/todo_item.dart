// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:todo_flutter_pwa/servies/api_service.dart';
import '../models/todo.dart';

class TodoItem extends StatefulWidget {
  final Todo todo;
  final VoidCallback onDelete;
  final Function(bool value) onUpdate;
  final Function(Todo todo) onEdit; // Agregar un callback para editar

  const TodoItem({
    super.key,
    required this.todo,
    required this.onDelete,
    required this.onUpdate,
    required this.onEdit, // Agregar este parámetro
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  late bool isCompleted;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isCompleted = widget.todo.completed;
    final ApiService apiService = ApiService();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        // Agregar GestureDetector para detectar el toque
        onTap: () {
          widget.onEdit(widget.todo); // Llamar al método de edición cuando se toque
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
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
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: Icon(
                        isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                        color: isCompleted ? Colors.blue : null,
                      ),
                      onPressed: () async {
                        setState(() {
                          isUpdating = true;
                        });

                        bool success = await apiService.updateTodo(widget.todo);

                        if (success) {
                          setState(() {
                            isCompleted = !isCompleted;
                            widget.onUpdate(isCompleted);
                            isUpdating = false;
                          });
                        } else {
                          setState(() {
                            isUpdating = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update Todo')),
                          );
                        }
                      },
                    ),
              Flexible(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.todo.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: '\n${widget.todo.description}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCompleted ? 'Completed' : 'Not Completed',
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.grey, // Cambiar color del texto
                    ),
                  ),
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
      ),
    );
  }
}
