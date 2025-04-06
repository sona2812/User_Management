import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/user_list_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'providers/user_provider.dart'; // Make sure this file is created

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/userList': (context) => const UserListScreen(),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}
