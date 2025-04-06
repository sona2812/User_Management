import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/animated_button.dart';
import 'dart:ui';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  String? _recoveredPassword;
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
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  Future<void> _recoverPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _recoveredPassword = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final enteredEmail = _emailController.text.trim();
      final storedEmail = prefs.getString('savedEmail');
      final storedPassword = prefs.getString('savedPassword');

      if (!mounted) return;

      if (enteredEmail == storedEmail && storedPassword != null) {
        setState(() {
          _recoveredPassword = storedPassword;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Password recovered successfully!"),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception("No account found with this email address");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _recoveredPassword = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(e.toString().replaceAll("Exception: ", "")),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                                        Icons.lock_reset,
                                        size: 80,
                                        color: Colors.deepPurple,
                                      ).animate()
                                        .fadeIn(duration: const Duration(milliseconds: 600))
                                        .scale(delay: const Duration(milliseconds: 200))
                                        .then()
                                        .shimmer(duration: const Duration(milliseconds: 1200), color: Colors.white.withOpacity(0.5)),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Forgot Password',
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
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Enter your email address to recover your password',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ).animate()
                                        .fadeIn(delay: const Duration(milliseconds: 600))
                                        .then()
                                        .shimmer(duration: const Duration(milliseconds: 1200), color: Colors.white.withOpacity(0.3)),
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
                                        .fadeIn(delay: const Duration(milliseconds: 800))
                                        .slideX(begin: -0.2, end: 0),
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
                                          onPressed: _isLoading ? null : () {
                                            _recoverPassword();
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
                                                  'Recover Password',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ).animate()
                                        .fadeIn(delay: const Duration(milliseconds: 1000))
                                        .scale(delay: const Duration(milliseconds: 1000)),
                                      if (_recoveredPassword != null) ...[
                                        const SizedBox(height: 24),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.green.shade200,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              const Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle_outline,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Your Password',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _recoveredPassword!,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ).animate()
                                          .fadeIn(delay: const Duration(milliseconds: 1200))
                                          .scale(delay: const Duration(milliseconds: 1200))
                                          .then()
                                          .shimmer(duration: const Duration(milliseconds: 1200), color: Colors.white.withOpacity(0.3)),
                                      ],
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'Back to Login',
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
