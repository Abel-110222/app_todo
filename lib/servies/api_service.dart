import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class ApiService {
  final String baseUrl = 'https://apitodo-production-4845.up.railway.app/api/todos';

  Future<List<Todo>> getTodos() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((todo) => Todo.fromJson(todo)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<void> addTodo(String title, String description) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'title': title, 'description': description, 'completed': false}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add todo');
    }
  }

  Future<bool> updateTodo(Todo todo) async {
    // Validar que el todo tenga un ID válido y título no vacío
    if (todo.title.isEmpty) {
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${todo.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'title': todo.title,
          'description': todo.description, // Reemplaza esto con la descripción correcta
          'completed': !todo.completed
        }),
      );

      // Manejo de errores basado en el código de estado
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

    Future<bool> updateTodoID(Todo todo) async {
    // Validar que el todo tenga un ID válido y título no vacío
    if (todo.title.isEmpty) {
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${todo.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'title': todo.title,
          'description': todo.description, // Reemplaza esto con la descripción correcta
          'completed': !todo.completed
        }),
      );

      // Manejo de errores basado en el código de estado
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteTodo(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete todo');
    }
  }
}
