import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<User> users = [];
  List<User> localUsers = [];

  Future<void> fetchUsers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Fetch local users first
      final prefs = await SharedPreferences.getInstance();
      final localUsersJson = prefs.getString('localUsers');
      if (localUsersJson != null) {
        final List<dynamic> decoded = json.decode(localUsersJson);
        localUsers = decoded.map((user) => User.fromJson(user)).toList();
      }

      // Fetch API users
      final response = await http.get(Uri.parse('https://reqres.in/api/users?page=1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiUsers = (data['data'] as List).map((user) => User.fromJson({
          'id': user['id'],
          'first_name': user['first_name'],
          'last_name': user['last_name'],
          'email': user['email'],
          'avatar': user['avatar'],
        })).toList();
        
        // Combine both lists
        users = [...localUsers, ...apiUsers];
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      errorMessage = e.toString();
      // If API fails, still show local users
      users = [...localUsers];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLocalUser(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Create a new user with local data
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch,
        firstName: email.split('@')[0],
        lastName: '',
        email: email,
        avatar: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(email.split('@')[0])}&background=random',
      );

      // Load existing local users
      final localUsersJson = prefs.getString('localUsers');
      if (localUsersJson != null) {
        final List<dynamic> decoded = json.decode(localUsersJson);
        localUsers = decoded.map((user) => User.fromJson(user)).toList();
      }

      // Add to local users list
      localUsers.add(newUser);
      
      // Save updated list to SharedPreferences
      await prefs.setString('localUsers', json.encode(localUsers.map((u) => u.toJson()).toList()));
      
      // Update the combined users list
      users = [...localUsers, ...users.where((u) => !localUsers.any((lu) => lu.id == u.id))];
      
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow; // Rethrow to handle in the UI
    }
  }

  Future<void> addNewUser({
    required String firstName,
    required String lastName,
    required String email,
    String? avatarUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Create a new user with provided data
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch,
        firstName: firstName,
        lastName: lastName,
        email: email,
        avatar: avatarUrl ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(firstName)}+${Uri.encodeComponent(lastName)}&background=random',
      );

      // Load existing local users
      final localUsersJson = prefs.getString('localUsers');
      if (localUsersJson != null) {
        final List<dynamic> decoded = json.decode(localUsersJson);
        localUsers = decoded.map((user) => User.fromJson(user)).toList();
      }

      // Add to local users list
      localUsers.add(newUser);
      
      // Save updated list to SharedPreferences
      await prefs.setString('localUsers', json.encode(localUsers.map((u) => u.toJson()).toList()));
      
      // Update the combined users list
      users = [...localUsers, ...users.where((u) => !localUsers.any((lu) => lu.id == u.id))];
      
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> updateUser(
    Map<String, dynamic> user,
    Map<String, dynamic> updatedData,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = user['id'];
      if (userId == null) {
        errorMessage = "Invalid user ID.";
        return null;
      }

      // Check if it's a local user
      final localUserIndex = localUsers.indexWhere((u) => u.id == userId);
      if (localUserIndex != -1) {
        // Update local user
        final updatedUser = localUsers[localUserIndex].copyWith(
          firstName: updatedData['first_name'],
          lastName: updatedData['last_name'],
          email: updatedData['email'],
          avatar: updatedData['avatar'],
        );
        
        localUsers[localUserIndex] = updatedUser;
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('localUsers', json.encode(localUsers.map((u) => u.toJson()).toList()));
        
        // Update the combined users list
        final userIndex = users.indexWhere((u) => u.id == userId);
        if (userIndex != -1) {
          users[userIndex] = updatedUser;
        }
        
        notifyListeners();
        return updatedUser.toJson();
      }

      // If not a local user, update via API
      final url = Uri.parse('https://reqres.in/api/users/$userId');
      final response = await http
          .patch(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updatedData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final updatedUser = User.fromJson({
          'id': userId,
          'first_name': updatedData['first_name'],
          'last_name': updatedData['last_name'],
          'email': updatedData['email'],
          'avatar': updatedData['avatar'],
        });
        
        // Update the users list
        final userIndex = users.indexWhere((u) => u.id == userId);
        if (userIndex != -1) {
          users[userIndex] = updatedUser;
        }
        
        notifyListeners();
        return updatedUser.toJson();
      } else {
        errorMessage = "Failed to update user. Status code: ${response.statusCode}.";
        return null;
      }
    } on TimeoutException {
      errorMessage = "⏳ Request timed out. Please try again.";
      return null;
    } catch (e) {
      errorMessage = "🚨 Unexpected error: $e";
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(int userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      // Check if it's a local user
      final localUserIndex = localUsers.indexWhere((u) => u.id == userId);
      if (localUserIndex != -1) {
        // Remove from local users
        localUsers.removeAt(localUserIndex);
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('localUsers', json.encode(localUsers.map((u) => u.toJson()).toList()));
        
        // Update the combined users list
        users = [...localUsers, ...users.where((u) => !localUsers.any((lu) => lu.id == u.id))];
        
        notifyListeners();
        return true;
      }

      // If not a local user, delete via API
      final url = Uri.parse('https://reqres.in/api/users/$userId');
      final response = await http.delete(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 204 || response.statusCode == 200) {
        // Remove from users list
        users.removeWhere((user) => user.id == userId);
        notifyListeners();
        return true;
      } else {
        errorMessage = "Failed to delete user. Status code: ${response.statusCode}.";
        return false;
      }
    } on TimeoutException {
      errorMessage = "⏳ Request timed out. Please try again.";
      return false;
    } catch (e) {
      errorMessage = "🚨 Unexpected error: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
