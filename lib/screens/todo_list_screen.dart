// ignore_for_file: prefer_const_literals_to_create_immutables, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:todo_flutter_pwa/servies/api_service.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final ApiService apiService = ApiService();
  List<Todo> todos = [];
  List<Todo> filteredTodos = [];
  bool isLoading = true; // Para controlar el estado de carga
  String filterValue = 'all'; // Valor por defecto del filtro

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      isLoading = true; // Inicia la carga
    });

    try {
      List<Todo> fetchedTodos = await apiService.getTodos();
      setState(() {
        todos = fetchedTodos;
        filteredTodos = todos; // Inicialmente muestra todos los todos
        isLoading = false; // Finaliza la carga
      });
      _filterTodos();
    } catch (e) {
      setState(() {
        isLoading = false; // En caso de error, finaliza la carga
      });
    }
  }

  void _refreshTodos() {
    _loadTodos(); // Recargar los todos
  }

  void _deleteTodo(int id) async {
    try {
      await apiService.deleteTodo(id);
      setState(() {
        todos.removeWhere((todo) => todo.id == id);
        _filterTodos(); // Refiltra la lista después de eliminar
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting todo: $e');
      }
    }
  }

  void _showAddTodoDialog(Todo? todo) {
    final TextEditingController titleController = TextEditingController(text: todo?.title ?? '');
    final TextEditingController descriptionController =
        TextEditingController(text: todo?.description ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400, // Aumentar el ancho del diálogo
            padding: const EdgeInsets.all(20), // Espaciado interno
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  todo == null ? 'Nueva Tarea' : 'Editar Tarea',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold), // Título más grande
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                ),
                const SizedBox(height: 16), // Espacio entre los campos
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                  maxLines: 3, // Permite más líneas para la descripción
                ),
                const SizedBox(height: 20), // Espacio adicional antes de los botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        // Validar que al menos uno de los campos no esté vacío
                        if (titleController.text.isNotEmpty ||
                            descriptionController.text.isNotEmpty) {
                          if (todo == null) {
                            // Crear nuevo todo
                            final newTodo = Todo(
                              id: 0, // ID será asignado por el servidor
                              title: titleController.text,
                              description: descriptionController.text,
                              completed: false,
                            );
                            await apiService.addTodo(newTodo.title, newTodo.description);
                          } else {
                            // Editar todo existente
                            final updatedTodo = Todo(
                              id: todo.id,
                              title: titleController.text,
                              description: descriptionController.text,
                              completed: todo.completed,
                            );
                            await apiService.updateTodoID(
                                updatedTodo); // Supón que tienes un método para actualizar
                          }
                          _refreshTodos(); // Recargar todos
                          Navigator.of(context).pop(); // Cierra el diálogo
                        } else {
                          // Si ambos campos están vacíos, muestra un mensaje de error
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Debes completar al menos un campo.')),
                          );
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cierra el diálogo
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _filterTodos() {
    if (filterValue == 'completed') {
      filteredTodos = todos.where((todo) => todo.completed).toList(); // Filtra por terminadas
    } else if (filterValue == 'incomplete') {
      filteredTodos = todos.where((todo) => !todo.completed).toList(); // Filtra por no terminadas
    } else {
      filteredTodos = todos.toList() // Muestra todos
        ..sort((a, b) => a.id.compareTo(b.id)); // Ordena por ID de menor a mayor
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          children: [
            SizedBox(width: 30),
            Text(
              'TO DO - PWA',
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Indicador de carga
          : todos.isEmpty
              ? const Center(child: Text('No todos found'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Espacio entre el botón y el dropdown
                            DropdownButton<String>(
                              hint: const Text('Filter Todos'),
                              elevation: 16,
                              style: const TextStyle(color: Colors.blueAccent),
                              underline: Container(
                                height: 2,
                                color: const Color.fromARGB(255, 148, 149, 150),
                              ),
                              value: filterValue,
                              items: [
                                const DropdownMenuItem(
                                  value: 'all',
                                  child: Text('All'),
                                ),
                                const DropdownMenuItem(
                                  value: 'incomplete',
                                  child: Text('Not Completed'),
                                ),
                                const DropdownMenuItem(
                                  value: 'completed',
                                  child: Text('Completed'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  filterValue = value!;
                                  _filterTodos(); // Filtra la lista según el nuevo valor
                                });
                              },
                            ),
                            ElevatedButton(
                              clipBehavior: Clip.antiAlias,
                              style: const ButtonStyle(
                                foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                                // Estilo del botón
                                backgroundColor: WidgetStatePropertyAll<Color>(Colors.blueAccent),
                              ),
                              onPressed: () {
                                _showAddTodoDialog(null);
                              },
                              // Muestra el diaño para agregar una nueva tarea
                              child: const Text('Add New Task'),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      // Asegura que la lista ocupe el espacio disponible
                      child: ListView(
                        children: [
                          ResponsiveGridRow(
                            rowSegments: 12,
                            children: filteredTodos.asMap().entries.map((entry) {
                              final index = entry.key; // Obtiene el índice
                              final todo = entry.value; // Obtiene el elemento de todo

                              return ResponsiveGridCol(
                                xs: 12,
                                xl: 4,
                                md: 6,
                                lg: 6,
                                child: GestureDetector(
                                  onDoubleTap: () => _showAddTodoDialog(
                                      todo), // Muestra los detalles al hacer doble clic
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: TodoItem(
                                      todo: todo,
                                      onDelete: () =>
                                          _deleteTodo(todo.id), // Llama a la función de eliminación
                                      onUpdate: (value) {
                                        // Crea una nueva instancia de Todo con el estado actualizado
                                        setState(() {
                                          todos[index] = Todo(
                                            id: todo.id,
                                            title: todo.title,
                                            description: todo.description,
                                            completed: value, // Cambiar el estado
                                          );
                                          _filterTodos(); // Refiltra después de actualizar
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
