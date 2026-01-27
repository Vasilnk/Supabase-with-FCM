import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/todo_controller.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoController controller = Get.put(TodoController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.signOut();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.todos.isEmpty) {
          return const Center(child: Text('No tasks yet!'));
        } else {
          return ListView.builder(
            itemCount: controller.todos.length,
            itemBuilder: (context, index) {
              final todo = controller.todos[index];
              print("Todo item $index: $todo");
              final int id = todo['id'] as int;
              final String title = todo['title'] ?? 'Untitled';
              final bool isCompleted = todo['is_completed'] ?? false;

              return ListTile(
                leading: Checkbox(
                  value: isCompleted,
                  onChanged: (val) => controller.toggleTodo(id, isCompleted),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    decoration:
                        isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteTodo(id),
                ),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, TodoController controller) {
    final todoController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Todo'),
            content: TextField(
              controller: todoController,
              decoration: const InputDecoration(hintText: 'Enter task...'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = todoController.text.trim();
                  if (title.isNotEmpty) {
                    controller.addTodo(title);
                    todoController.clear();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
