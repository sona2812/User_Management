import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String heroTag;

  const EditUserScreen({
    super.key,
    required this.user,
    required this.heroTag,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController avatarController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user['first_name']);
    lastNameController = TextEditingController(text: widget.user['last_name']);
    emailController = TextEditingController(text: widget.user['email']);
    avatarController = TextEditingController(text: widget.user['avatar']);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    avatarController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final updatedData = {
      'first_name': firstNameController.text.trim(),
      'last_name': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'avatar': avatarController.text.trim(),
    };

    try {
      final updatedUser = await userProvider.updateUser(widget.user, updatedData);

      if (userProvider.errorMessage != null) {
        Fluttertoast.showToast(msg: "❌ ${userProvider.errorMessage}");
      } else if (updatedUser != null) {
        Fluttertoast.showToast(msg: "✅ User updated successfully!");
        Navigator.pop(context, true);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Something went wrong: $e");
    }
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasAbsolutePath && uri.scheme.startsWith('http');
  }

  InputDecoration _inputDecoration(String label, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(
        color: Colors.indigo.shade700,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      errorText: errorText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.indigo.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.indigo.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.indigo.shade400, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final heroTag = widget.heroTag;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit User',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo.shade800,
        elevation: 0,
      ),
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
            // Dreamy background elements
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.shade100.withOpacity(0.5),
                      Colors.blue.shade100.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.indigo.shade200.withOpacity(0.5),
                      Colors.indigo.shade200.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Floating circles effect
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
            // Additional floating circles
            ...List.generate(15, (index) {
              final size = 8.0 + (index % 4) * 12.0;
              return Positioned(
                top: 80.0 + (index * 45),
                right: 30.0 + (index * 15),
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 1800 + (index * 400)),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, -25 * value),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.2 - (index * 0.01)),
                              Colors.white.withOpacity(0.05 - (index * 0.002)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Hero(
                          tag: heroTag,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _isValidUrl(avatarController.text)
                                  ? NetworkImage(avatarController.text)
                                  : null,
                              backgroundColor: Colors.white,
                              child: !_isValidUrl(avatarController.text)
                                  ? const Icon(Icons.error, size: 40, color: Colors.red)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white24,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Avatar URL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: avatarController,
                              decoration: _inputDecoration(''),
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Please enter avatar URL';
                                if (!_isValidUrl(value.trim())) return 'Enter a valid URL';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'First Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: firstNameController,
                              decoration: _inputDecoration(''),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty ? 'First name required' : null,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Last Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: lastNameController,
                              decoration: _inputDecoration(''),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty ? 'Last name required' : null,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: emailController,
                              decoration: _inputDecoration(''),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Email required';
                                final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value.trim())) return 'Invalid email format';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Container(
                          width: 200,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.indigo.shade300,
                                Colors.indigo.shade500,
                                Colors.blue.shade500,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.shade300.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.blue.shade300.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: -2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: userProvider.isLoading ? null : () => _saveChanges(context),
                              borderRadius: BorderRadius.circular(25),
                              splashColor: Colors.white.withOpacity(0.2),
                              highlightColor: Colors.white.withOpacity(0.1),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.save_rounded,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Save Changes',
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
                         .fadeIn(duration: 600.ms)
                         .slideY(begin: 0.2, duration: 400.ms)
                         .then()
                         .shimmer(duration: 1200.ms, delay: 600.ms)
                         .then(delay: 400.ms)
                         .elevation(
                           begin: 0,
                           end: 12,
                           curve: Curves.easeInOut,
                           duration: 600.ms,
                         ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (userProvider.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
