import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoController extends GetxController {
  final _supabase = Supabase.instance.client;

  var todos = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  void fetchTodos() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print("Cannot fetch todos: user not logged in");
      return;
    }
    isLoading.value = true;
    print("Fetching todos for user: ${user.id}");
    try {
      final response = await _supabase
          .from('todos')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      todos.value = List<Map<String, dynamic>>.from(response);
      print("Fetched todos: count=${todos.length}");
    } catch (e) {
      print("Error fetching todos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void addTodo(String title) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    print("Starting to add todo: title='$title', user_id='${user.id}'");
    try {
      await _supabase.from('todos').insert({
        'title': title,
        'is_completed': false,
        'user_id': user.id,
      });
      print("Todo added successfully: '$title'");
      fetchTodos();
    } catch (e) {
      print("Error adding todo: $e");
    }
  }

  void toggleTodo(int id, bool currentValue) async {
    print("Starting to toggle todo: id='$id', current_value=$currentValue");
    try {
      await _supabase
          .from('todos')
          .update({'is_completed': !currentValue})
          .eq('id', id);
      print("Todo toggled successfully: id='$id', new_value=${!currentValue}");
      fetchTodos();
    } catch (e) {
      print("Error toggling todo: $e");
    }
  }

  void deleteTodo(int id) async {
    print("Starting to delete todo: id='$id'");
    try {
      await _supabase.from('todos').delete().eq('id', id);
      print("Todo deleted successfully: id='$id'");
      fetchTodos();
    } catch (e) {
      print("Error deleting todo: $e");
    }
  }

  void signOut() async {
    print("Starting user sign out");
    try {
      await _supabase.auth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Error during sign out: $e");
    }
  }
}
