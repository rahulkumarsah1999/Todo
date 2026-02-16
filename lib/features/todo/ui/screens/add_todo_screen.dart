import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/todo_provider.dart';
import '../../model/todo_model.dart';

class AddTodoScreen extends StatefulWidget {
  final Todo? existingTodo;

  const AddTodoScreen({super.key, this.existingTodo});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  String? _selectedCategory;
  Priority _selectedPriority = Priority.medium;

  @override
  void initState() {
    super.initState();

    if (widget.existingTodo != null) {
      _titleController.text = widget.existingTodo!.title;
      _selectedCategory = widget.existingTodo!.category;
      _selectedPriority = widget.existingTodo!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // 🔹 Add New Category Dialog
  // Future<String?> _showAddCategoryDialog(BuildContext context) async {
  //
  //   final controller = TextEditingController();
  //
  //   return showDialog<String>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("New Category"),
  //       content: TextField(
  //         controller: controller,
  //         decoration: const InputDecoration(
  //           hintText: "Enter category name",
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Cancel"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(
  //               context,
  //               controller.text.trim(),
  //             );
  //           },
  //           child: const Text("Add"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {

      if (_selectedCategory == null ||
          _selectedCategory!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a category"),
          ),
        );
        return;
      }

      if (widget.existingTodo == null) {
        // ADD MODE
        final newTodo = Todo(
          id: DateTime.now().toString(),
          title: _titleController.text.trim(),
          category: _selectedCategory!,
          priority: _selectedPriority,
        );

        Provider.of<TodoProvider>(context, listen: false)
            .addTodo(newTodo);

      } else {
        // EDIT MODE
        final updatedTodo = Todo(
          id: widget.existingTodo!.id,
          title: _titleController.text.trim(),
          category: _selectedCategory!,
          priority: _selectedPriority,
          isCompleted: widget.existingTodo!.isCompleted,
          createdAt: widget.existingTodo!.createdAt,
        );

        Provider.of<TodoProvider>(context, listen: false)
            .updateTodo(updatedTodo);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingTodo == null
              ? "Add Task"
              : "Edit Task",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// 🔹 Title
              TextFormField(
                controller: _titleController,
                autofocus: widget.existingTodo == null,
                decoration: const InputDecoration(
                  labelText: 'Todo Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// 🔹 Category Dropdown
              Consumer<TodoProvider>(
                builder: (context, provider, child) {

                  final categories = provider.categories;

                  return DropdownButtonFormField<String>(
                    value: categories.contains(_selectedCategory)
                        ? _selectedCategory
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      ...categories.map(
                            (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: "add_new",
                        child: Text("➕ Add New Category"),
                      ),
                    ],
                    onChanged: (value) async {

                      if (value == "add_new") {

                        final newCategory =
                        await showDialog<String>(
                          context: context,
                          builder: (dialogContext) {
                            final controller =
                            TextEditingController();

                            return AlertDialog(
                              title: const Text("New Category"),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  hintText: "Enter category name",
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      dialogContext,
                                      controller.text.trim(),
                                    );
                                  },
                                  child: const Text("Add"),
                                ),
                              ],
                            );
                          },
                        );

                        if (newCategory != null &&
                            newCategory.isNotEmpty) {

                          if (!context.mounted) return;

                          final trimmed = newCategory.trim();

                          context.read<TodoProvider>()
                              .addCategory(trimmed);

                          setState(() {
                            _selectedCategory = trimmed;
                          });
                        }

                      } else {

                        setState(() {
                          _selectedCategory = value;
                        });

                      }
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              /// 🔹 Priority
              DropdownButtonFormField<Priority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: Priority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(
                      priority.name.toUpperCase(),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              /// 🔹 Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveTodo,
                  child: Text(
                    widget.existingTodo == null
                        ? "Save Task"
                        : "Update Task",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}