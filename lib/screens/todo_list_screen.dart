// ignore_for_file: prefer_const_literals_to_create_immutables, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:todo_flutter_pwa/servies/api_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:elegant_notification/elegant_notification.dart';
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
  late WebSocketChannel channel; // Canal de WebSocket

  int currentPage = 0; // Página actual
  final int itemsPerPage = 5; // Número de elementos por página

  @override
  void initState() {
    super.initState();
    _loadTodos();

    // Inicializa el canal WebSocket
    channel = WebSocketChannel.connect(
      Uri.parse(
          'wss://apitodo-production-4845.up.railway.app/todo_updates'), // URL del servidor WebSocket
    );

    channel.stream.listen(
      (message) {
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        // Handle error and possibly retry connection
        if (kDebugMode) {
          print('WebSocket error: $error');
        }
      },
      onDone: () {
        // Handle when the WebSocket connection is closed
        if (kDebugMode) {
          print('WebSocket connection closed, attempting reconnection...');
        }
        // Optionally, add a reconnection attempt logic here
      },
    );
  }

  @override
  void dispose() {
    // Cierra el canal cuando el widget se destruye
    channel.sink.close(status.goingAway);
    super.dispose();
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

  void _handleWebSocketMessage(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);

      if (data['action'] == 'add') {
        setState(() {
          todos.add(Todo.fromJson(data['todo']));
          _filterTodos(); // Filtra después de añadir
        });
      } else if (data['action'] == 'update') {
        setState(() {
          Todo updatedTodo = Todo.fromJson(data['todo']);
          int index = todos.indexWhere((todo) => todo.id == updatedTodo.id);
          if (index != -1) {
            todos[index] = updatedTodo;
            _filterTodos(); // Filtra después de actualizar
          }
        });
      } else if (data['action'] == 'delete') {
        setState(() {
          todos.removeWhere((todo) => todo.id == data['id']);
          _filterTodos(); // Filtra después de eliminar
        });
      }
    } catch (e) {
      print('Mensaje recibido no es JSON: $message');
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
        _filterTodos();
      });
      ElegantNotification.error(
        title: const Text("Tarea eliminada"),
        description: const Text("La tarea se ha eliminado correctamente."),
      ).show(context);
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
                            // Crear nueva tarea
                            final newTodo = Todo(
                              id: 0, // ID asignado por el servidor
                              title: titleController.text,
                              description: descriptionController.text,
                              completed: false,
                            );
                            await apiService.addTodo(newTodo.title, newTodo.description);
                            ElegantNotification.success(
                              title: const Text("Tarea creada"),
                              description: const Text("La tarea se ha creado exitosamente."),
                            ).show(context);
                          } else {
                            // Editar tarea existente
                            final updatedTodo = Todo(
                              id: todo.id,
                              title: titleController.text,
                              description: descriptionController.text,
                              completed: todo.completed,
                            );
                            await apiService.updateTodoID(updatedTodo);
                            ElegantNotification.info(
                              title: const Text("Tarea actualizada"),
                              description: const Text("La tarea se ha actualizado correctamente."),
                            ).show(context);
                          }
                          _refreshTodos(); // Recargar tareas
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
      filteredTodos = todos.where((todo) => todo.completed).toList();
    } else if (filterValue == 'incomplete') {
      filteredTodos = todos.where((todo) => !todo.completed).toList();
    } else {
      filteredTodos = List.from(todos); // Copia la lista original sin filtrar
    }
    setState(() {
      filteredTodos = filteredTodos; // Refresca la vista con la lista filtrada
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredTodos.length / itemsPerPage).ceil();
    List<Todo> paginatedTodos =
        filteredTodos.skip(currentPage * itemsPerPage).take(itemsPerPage).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          children: [
            SizedBox(width: 30),
            Text(
              'To-Do App',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                filterValue = (filterValue == 'all') ? 'completed' : 'all';
              });
              _filterTodos();
            },
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Filtro y botón de agregar tarea en un solo Row
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween, // Espaciado entre los elementos
                          children: [
                            // DropdownButton en la izquierda
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButton<String>(
                                  value: filterValue,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'all',
                                      child: Text('Todas las tareas'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'completed',
                                      child: Text('Tareas terminadas'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'incomplete',
                                      child: Text('Tareas no terminadas'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      filterValue = value!;
                                    });
                                    _filterTodos(); // Actualiza la lista filtrada
                                  },
                                )),

                            // Botón "Agregar Tarea" en la derecha
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () => _showAddTodoDialog(null),
                                child: const Text("Agregar Tarea"),
                              ),
                            ),
                          ],
                        ),
                        // Lista de tareas
                        ResponsiveGridRow(
                          children: [
                            ...paginatedTodos.map(
                              (todo) => ResponsiveGridCol(
                                xs: 12,
                                sm: 6,
                                md: 6,
                                child: TodoItem(
                                  todo: todo,
                                  onDelete: () => _deleteTodo(todo.id),
                                  onUpdate: (value) {
                                    setState(() {
                                      int originalIndex = todos.indexWhere((t) => t.id == todo.id);
                                      todos[originalIndex] = Todo(
                                        id: todo.id,
                                        title: todo.title,
                                        description: todo.description,
                                        completed: value,
                                      );
                                      _filterTodos();
                                    });
                                  },
                                  onEdit: (todo) {
                                    _showAddTodoDialog(todo);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey),
                      ],
                    ),
                  ),
                ),
          // Paginación en la parte inferior
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: currentPage > 0
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                ),
                Text('Página ${currentPage + 1} de $totalPages'),
                IconButton(
                  onPressed: currentPage < totalPages - 1
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
