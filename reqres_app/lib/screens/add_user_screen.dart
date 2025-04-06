import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    // Validate input
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill in all required fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      Fluttertoast.showToast(
        msg: "Please enter a valid email address",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<UserProvider>(context, listen: false).addNewUser(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        avatarUrl: _avatarUrlController.text.isNotEmpty ? _avatarUrlController.text : null,
      );

      Fluttertoast.showToast(
        msg: "User added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to add user: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User')
            .animate()
            .fadeIn(duration: 600.ms)
            .slideX(begin: -0.2),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade800,
              Colors.indigo.shade400,
              Colors.blue.shade300,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background circles
            ...List.generate(15, (index) {
              final size = 20.0 + (index % 4) * 25.0;
              return Positioned(
                top: -20.0 + (index * 60),
                left: -30.0 + (index * 45),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1 - (index * 0.005)),
                  ),
                ),
              ).animate().fadeIn(
                delay: Duration(milliseconds: index * 100),
                duration: 600.ms,
              );
            }),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Icon(
                                  Icons.person_add_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ).animate()
                                  .fadeIn(duration: 600.ms)
                                  .scale(delay: 200.ms),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  'Create New User',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ).animate()
                                  .fadeIn(delay: 300.ms)
                                  .slideY(begin: 0.2),
                              ),
                              const SizedBox(height: 32),
                              TextField(
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                ),
                                style: TextStyle(color: Colors.white),
                              ).animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.2),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                ),
                                style: TextStyle(color: Colors.white),
                              ).animate()
                                .fadeIn(delay: 450.ms)
                                .slideY(begin: 0.2),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: Colors.white),
                              ).animate()
                                .fadeIn(delay: 500.ms)
                                .slideY(begin: 0.2),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _avatarUrlController,
                                decoration: InputDecoration(
                                  labelText: 'Avatar URL (Optional)',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                ),
                                keyboardType: TextInputType.url,
                                style: TextStyle(color: Colors.white),
                              ).animate()
                                .fadeIn(delay: 550.ms)
                                .slideY(begin: 0.2),
                              const SizedBox(height: 32),
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.indigo.shade400,
                                      Colors.indigo.shade600,
                                      Colors.blue.shade600,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.indigo.shade400.withOpacity(0.5),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: Colors.blue.shade400.withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: -2,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isLoading ? null : _addUser,
                                    borderRadius: BorderRadius.circular(12),
                                    splashColor: Colors.white.withOpacity(0.2),
                                    highlightColor: Colors.white.withOpacity(0.1),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.15),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: _isLoading
                                            ? SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.add_circle_outline_rounded,
                                                    size: 22,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Add User',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ).animate()
                                .fadeIn(delay: 600.ms)
                                .slideY(begin: 0.2)
                                .then()
                                .shimmer(duration: 1200.ms, delay: 600.ms),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
