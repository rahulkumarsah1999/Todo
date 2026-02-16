import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../model/todo_model.dart';

class TodoProvider with ChangeNotifier {

  final List<Todo> _todos = [];
  final List<String> _categories = [];

  final Box _todoBox = Hive.box('todoBox');

  // ==========================
  // CATEGORIES
  // ==========================

  List<String> get categories =>
      List.unmodifiable(_categories);

  void addCategory(String category) {
    final trimmed = category.trim();

    if (trimmed.isEmpty) return;

    if (!_categories.contains(trimmed)) {
      _categories.add(trimmed);
      notifyListeners();
    }
  }

  // ==========================
  // TODOS
  // ==========================

  List<Todo> get todos => _todos;

  void addTodo(Todo todo) {

    // Ensure category exists
    if (!_categories.contains(todo.category)) {
      _categories.add(todo.category);
    }

    _todoBox.put(todo.id, todo.toMap());
    _todos.add(todo);

    notifyListeners();
  }

  void updateTodo(Todo updatedTodo) {
    final index =
    _todos.indexWhere((t) => t.id == updatedTodo.id);

    if (index != -1) {
      _todos[index] = updatedTodo;

      // Ensure category exists
      if (!_categories.contains(updatedTodo.category)) {
        _categories.add(updatedTodo.category);
      }

      _todoBox.put(
          updatedTodo.id,
          updatedTodo.toMap());
    }

    notifyListeners();
  }

  void deleteTodo(String id) {

    final todoToDelete =
    _todos.firstWhere((t) => t.id == id);

    _todoBox.delete(id);
    _todos.removeWhere((todo) => todo.id == id);

    // 🔥 Check if category is now empty
    final stillExists = _todos.any(
            (t) => t.category == todoToDelete.category);

    if (!stillExists) {
      _categories.remove(todoToDelete.category);
    }

    notifyListeners();
  }

  void toggleTodoStatus(String id) {
    final index =
    _todos.indexWhere((todo) => todo.id == id);

    if (index != -1) {
      _todos[index].isCompleted =
      !_todos[index].isCompleted;

      _todoBox.put(
        id,
        _todos[index].toMap(),
      );

      notifyListeners();
    }
  }

  // ==========================
  // LOAD FROM HIVE
  // ==========================

  TodoProvider() {
    _loadTodos();
  }

  void _loadTodos() {
    final data = _todoBox.values.toList();

    _todos.clear();
    _categories.clear();

    for (var item in data) {
      final todo = Todo.fromMap(
          Map<String, dynamic>.from(item));

      _todos.add(todo);

      if (!_categories.contains(todo.category)) {
        _categories.add(todo.category);
      }
    }

    notifyListeners();
  }

  // ==========================
  // GROUP BY CATEGORY
  // ==========================

  Map<String, List<Todo>> get groupedTodos {
    final Map<String, List<Todo>> grouped = {};

    for (var todo in _todos) {
      if (!grouped.containsKey(todo.category)) {
        grouped[todo.category] = [];
      }
      grouped[todo.category]!.add(todo);
    }

    return grouped;
  }

  // ==========================
  // DASHBOARD STATS
  // ==========================

  int get totalTasks => _todos.length;

  int get completedTasks =>
      _todos.where((t) => t.isCompleted).length;

  int get pendingTasks =>
      _todos.where((t) => !t.isCompleted).length;

  double get completionPercent {
    if (_todos.isEmpty) return 0;
    return completedTasks / totalTasks;
  }

  // ==========================
  // REORDER WITHIN CATEGORY
  // ==========================

  void reorderWithinCategory(
      String category,
      int oldIndex,
      int newIndex) {

    final categoryTodos =
    _todos.where((t) => t.category == category).toList();

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = categoryTodos.removeAt(oldIndex);
    categoryTodos.insert(newIndex, item);

    _todos.removeWhere((t) => t.category == category);
    _todos.addAll(categoryTodos);

    _saveOrderToHive();
    notifyListeners();
  }

  void _saveOrderToHive() {
    _todoBox.clear();

    for (var todo in _todos) {
      _todoBox.put(todo.id, todo.toMap());
    }
  }

  // ==========================
  // SEARCH
  // ==========================

  List<Todo> searchTodos(String query) {

    if (query.isEmpty) return _todos;

    return _todos.where((todo) {
      return todo.title
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          todo.category
              .toLowerCase()
              .contains(query.toLowerCase());
    }).toList();
  }
}