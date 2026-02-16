import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/todo_provider.dart';
import '../../model/todo_model.dart';
import 'add_todo_screen.dart';
import '../../../../core/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showStats = false;

  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return AppColors.highPriority;
      case Priority.medium:
        return AppColors.mediumPriority;
      case Priority.low:
        return AppColors.lowPriority;
    }
  }

  Widget _statCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 🔹 APP BAR
      appBar: AppBar(
        title: const Text("My Tasks"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _showStats = !_showStats;
            });
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: TodoSearchDelegate());
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),

      /// 🔹 PREMIUM FAB
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTodoScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7B1FA2),
                  Color(0xFF9C27B0),
                  Color(0xFFBA68C8),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Add Task",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      /// 🔹 BODY
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          final grouped = provider.groupedTodos;

          if (grouped.isEmpty) {
            return const Center(
              child: Text("No Todos Yet", style: TextStyle(fontSize: 18)),
            );
          }

          return Column(
            children: [
              /// 🔹 DASHBOARD
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _showStats ? null : 0,
                padding:
                    _showStats ? const EdgeInsets.all(16) : EdgeInsets.zero,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    _showStats
                        ? Column(
                      mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Dashboard",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _statCard(
                                  "Total",
                                  provider.totalTasks.toString(),
                                ),
                                _statCard(
                                  "Done",
                                  provider.completedTasks.toString(),
                                ),
                                _statCard(
                                  "Pending",
                                  provider.pendingTasks.toString(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            LinearProgressIndicator(
                              value: provider.completionPercent,
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.purple,
                            ),
                          ],
                        )
                        : null,
              ),

              /// 🔹 TODO LIST
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children:
                      grouped.entries.map((entry) {
                        final category = entry.key;
                        final todos = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            ReorderableListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              onReorder: (oldIndex, newIndex) {
                                provider.reorderWithinCategory(
                                  category,
                                  oldIndex,
                                  newIndex,
                                );
                              },
                              children: List.generate(todos.length, (index) {
                                final todo = todos[index];

                                return Card(
                                  key: ValueKey(todo.id),
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(

                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.drag_handle),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 8,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _priorityColor(todo.priority),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ],
                                    ),

                                    title: Text(
                                      todo.title,
                                      style: TextStyle(
                                        decoration:
                                        todo.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    subtitle: Text(
                                      "Priority: ${todo.priority.name.toUpperCase()}",
                                    ),

                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        Checkbox(
                                          value: todo.isCompleted,
                                          onChanged: (_) {
                                            provider.toggleTodoStatus(todo.id);
                                          },
                                        ),

                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AddTodoScreen(existingTodo: todo),
                                              ),
                                            );
                                          },
                                        ),

                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            provider.deleteTodo(todo.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 🔹 SEARCH DELEGATE
class TodoSearchDelegate extends SearchDelegate {

  @override
  String get searchFieldLabel => "Search tasks...";

  @override
  Widget buildSuggestions(BuildContext context) {

    final provider =
    Provider.of<TodoProvider>(context, listen: false);

    final results = provider.searchTodos(query);

    if (results.isEmpty) {
      return const Center(
        child: Text(
          "No matching tasks found",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {

        final todo = results[index];

        return ListTile(

          leading: Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: _priorityColorStatic(todo.priority),
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          title: Text(todo.title),

          subtitle: Text(
            "${todo.category} • ${todo.priority.name.toUpperCase()}",
          ),

          onTap: () {
            close(context, null);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddTodoScreen(existingTodo: todo),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) =>
      buildSuggestions(context);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        query = '';
      },
    )
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(
      Icons.arrow_back_ios_new_rounded,
    ),
    onPressed: () {
      close(context, null);
    },
  );

  // 🔥 Static helper
  Color _priorityColorStatic(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }
}