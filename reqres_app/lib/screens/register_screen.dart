import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';
import '../widgets/animated_button.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'dart:ui';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    return password.length >= 8 && // At least 8 characters
           RegExp(r'[A-Z]').hasMatch(password) && // At least one uppercase letter
           RegExp(r'[a-z]').hasMatch(password) && // At least one lowercase letter
           RegExp(r'[0-9]').hasMatch(password) && // At least one number
           RegExp(r'[!@#\$&*~]').hasMatch(password); // At least one special character
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception("Passwords do not match");
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // Check if email already exists
        final existingEmail = prefs.getString('savedEmail');
        if (existingEmail == _emailController.text) {
          throw Exception("Email already registered");
        }

        // Save user data
        await prefs.setString('savedEmail', _emailController.text);
        await prefs.setString('savedPassword', _passwordController.text);
        await prefs.setBool('isLoggedIn', true);

        if (!mounted) return;

        // Add user to provider
        await Provider.of<UserProvider>(context, listen: false)
            .addLocalUser(_emailController.text, _passwordController.text);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Registration successful!"),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to user list screen after delay
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/userList');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(e.toString().replaceAll("Exception: ", "")),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            ...List.generate(20, (index) {
              final size = 10.0 + (index % 3) * 15.0;
              return Positioned(
                top: 50.0 + (index * 35),
                left: 20.0 + (index * 20),
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 2000 + (index * 300)),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, -20 * value),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15 - (index * 0.005)),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2 - (index * 0.008)),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.8),
                                    Colors.white.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.person_add,
                                        size: 80,
                                        color: Colors.deepPurple,
                                      ).animate()
                                        .fadeIn(duration: const Duration(milliseconds: 600))
                                        .scale(delay: const Duration(milliseconds: 200))
                                        .then()
                                        .shimmer(duration: const Duration(milliseconds: 1200), color: Colors.white.withOpacity(0.5)),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ).animate()
                                        .fadeIn(delay: const Duration(milliseconds: 400))
                                        .slideY(begin: 0.3, end: 0)
                                        .then()
                                        .shimmer(duration: const Duration(milliseconds: 1200), color: Colors.white.withOpacity(0.5)),
                                      const SizedBox(height: 24),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.indigo.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelText: 'Email',
                                            prefixIcon: const Icon(Icons.email),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.deepPurple.shade200,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.deepPurple,
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(0.9),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your email';
                                            }
                                            if (!_isValidEmail(value)) {
                                              return 'Please enter a valid email';
                                            }
                                            return null;
                                          },
                                        ),
                                      ).animate()
                                        .fadeIn(delay: const Duration(milliseconds: 600))
                                        .slideX(begin: -0.2, end: 0),
                                      const SizedBox(height: 16),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.indigo.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          controller: _passwordController,
                                          obscureText: !_isPasswordVisible,
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            prefixIcon: const Icon(Icons.lock),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isPasswordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordVisible = !_isPasswordVisible;
                                                });
                                              },
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.deepPurple.shade200,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.deepPurple,
                                                width: 2,
                                              ),
                                            ),
                                            helperText: 'Password must contain at least 8 characters, including uppercase, lowercase, number, and special character',
                                            helperMaxLines: 2,
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(0.9),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter a password';
                                            }
                                            if (!_isStrongPassword(value)) {
                                              return 'Password is not strong enough';
                                            }
                                            return null;
                                          },
                                        ),
                                      ).animate()
                                        .fadeIn(delay: const Duration(milliseconds: 800))
                                        .slideX(begin: 0.2, end: 0),
                                      const SizedBox(height: 16),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.indigo.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          controller: _confirmPasswordController,
                                          obscureText: !_isConfirmPasswordVisible,
                                          decoration: InputDecoration(
                                            labelText: 'Confirm Password',
                                            prefixIcon: const Icon(Icons.lock_outline),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isConfirmPasswordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                                });
                                              },
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.deepPurple.shade200,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.deepPurple,
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(0.9),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please confirm your password';
                                            }
                                            if (value != _passwordController.text) {
                                              return 'Passwords do not match';
                                            }
                                            return null;
                                          },
                                        ),
                                      ).animate()
                                        .fadeIn(delay: const Duration(milliseconds: 1000))
                                        .slideX(begin: 0.2, end: 0),
                                      const SizedBox(height: 24),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.indigo.shade700,
                                              Colors.indigo.shade500,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.indigo.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: AnimatedButton(
                                          onPressed: _isLoading ? null : () async {
                                            await _register();
                                          },
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text(
                                                  'Register',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ).animate()
                                        .fadeIn(delay: const Duration(milliseconds: 1200))
                                        .scale(delay: const Duration(milliseconds: 1200)),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => const LoginScreen(),
                                                  ),
                                                );
                                              },
                                        child: const Text(
                                          "Already have an account? Login",
                                          style: TextStyle(
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ).animate()
                                        .fadeIn(delay: const Duration(milliseconds: 1400))
                                        .then()
                                        .shimmer(duration: const Duration(milliseconds: 1200), color: Colors.white.withOpacity(0.5)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
