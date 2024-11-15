// ignore_for_file: prefer_const_literals_to_create_immutables, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_flutter_pwa/servies/api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Paquete para verificar la conectividad
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
  bool isInternetAvailable = true;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((connectivityResult) {
      setState(() {
        isInternetAvailable = connectivityResult != ConnectivityResult.none;
      });
      if (isInternetAvailable) {
        _syncOfflineTodos();
      }
      _loadTodos();
    });
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool previousState = isInternetAvailable;

    setState(() {
      isInternetAvailable = connectivityResult != ConnectivityResult.none;
    });

    if (isInternetAvailable && !previousState) {
      // Si la conexión se recupera, sincroniza las tareas offline
      await _syncOfflineTodos();
    }

    _loadTodos(); // Cargar todos (de caché o desde la API)
  }

  Future<void> _loadTodos() async {
    if (!isInternetAvailable) {
      // Si no hay internet, cargamos los todos desde el caché (puedes implementar tu propia lógica de cacheo)
      final cachedTodos = await _getCachedTodos();
      setState(() {
        todos = cachedTodos;
        filteredTodos = todos;
        isLoading = false;
      });
      return;
    }

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
      // Guardamos los todos en caché después de obtenerlos del servidor
      _cacheTodos(fetchedTodos);
    } catch (e) {
      setState(() {
        isLoading = false; // En caso de error, finaliza la carga
      });
    }
  }

  // Guarda los todos en SharedPreferences
  Future<void> _cacheTodos(List<Todo> todosToCache) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> todosJson = todosToCache
        .map((todo) => jsonEncode(todo.toJson()))
        .toList(); // Convierte los todos en cadenas JSON
    await prefs.setStringList(
        'todos', todosJson); // Almacena la lista de todos en SharedPreferences
  }

  // Recupera los todos desde SharedPreferences
  Future<List<Todo>> _getCachedTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? todosJson =
        prefs.getStringList('todos'); // Recupera la lista de cadenas JSON

    if (todosJson == null) {
      return []; // Si no hay datos en caché, retorna una lista vacía
    }

    return todosJson.map((todoString) {
      final Map<String, dynamic> todoMap =
          jsonDecode(todoString); // Convierte la cadena JSON de nuevo a Map
      return Todo.fromJson(todoMap); // Crea el objeto Todo desde el Map
    }).toList();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al eliminar la tarea. Intenta nuevamente.')));
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
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'El título es obligatorio para la tarea';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
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
                        if (titleController.text.isNotEmpty ||
                            descriptionController.text.isNotEmpty) {
                          final newTodo = Todo(
                            id: 0, // ID será asignado por el servidor
                            title: titleController.text,
                            description: descriptionController.text,
                            completed: false,
                          );

                          if (isInternetAvailable) {
                            // Si hay internet, crear la tarea en la API
                            await apiService.addTodo(newTodo.title, newTodo.description);
                          } else {
                            // Si no hay internet, guarda la tarea localmente
                            await _saveTodoTemporarily(newTodo);
                          }

                          _refreshTodos(); // Recargar todos
                          Navigator.of(context).pop(); // Cierra el diálogo
                        } else {
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
// Guarda la tarea localmente cuando no hay internet
  Future<void> _saveTodoTemporarily(Todo todo) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> todosJson = prefs.getStringList('offlineTodos') ?? [];

    todosJson.add(jsonEncode(todo.toJson())); // Agrega la tarea a la lista local
    await prefs.setStringList('offlineTodos', todosJson); // Guarda la lista actualizada
  }

// Crea las tareas guardadas temporalmente cuando se recupera la conexión
  Future<void> _syncOfflineTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> todosJson = prefs.getStringList('offlineTodos') ?? [];

    if (todosJson.isNotEmpty) {
      for (var todoJson in todosJson) {
        final Map<String, dynamic> todoMap = jsonDecode(todoJson);
        final Todo todo = Todo.fromJson(todoMap);

        try {
          // Intenta crear la tarea en la API
          await apiService.addTodo(todo.title, todo.description);
          // Si se crea correctamente, elimina la tarea localmente
          todosJson.remove(todoJson);
          await prefs.setStringList('offlineTodos', todosJson);
        } catch (e) {
          // Si ocurre un error, ignora la tarea
          
        }
      }
    }
  }

  void _filterTodos() {
    setState(() {
      if (filterValue == 'completed') {
        filteredTodos = todos.where((todo) => todo.completed).toList();
      } else if (filterValue == 'incomplete') {
        filteredTodos = todos.where((todo) => !todo.completed).toList();
      } else {
        filteredTodos = todos;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            const SizedBox(width: 30),
            Text(
              'TO DO - PWA v3',
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              isInternetAvailable ? 'Online' : 'Offline',
              style: TextStyle(color: isInternetAvailable ? Colors.green : Colors.red),
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
                              clipBehavior: Clip.hardEdge,
                              onPressed: () => _showAddTodoDialog(null),
                              child: const Text("Crear nueva tarea"),
                            ),
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
