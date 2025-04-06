import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'edit_user_screen.dart'; // Import the edit screen
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class UserDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String heroTag;

  const UserDetailScreen({
    Key? key,
    required this.user,
    required this.heroTag,
  }) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    user = Map<String, dynamic>.from(widget.user);
  }

  Future<bool?> _showEditConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: Colors.indigo.shade700,
                  size: 24,
                ),
              ).animate()
                .scale(duration: 300.ms)
                .fadeIn(),
              const SizedBox(width: 12),
              Text(
                'Edit User',
                style: TextStyle(
                  color: Colors.indigo.shade900,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ).animate()
                .fadeIn()
                .slideX(begin: 0.2, duration: 300.ms),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to edit this user?',
              style: TextStyle(
                color: Colors.indigo.shade700,
                fontSize: 16,
                height: 1.5,
              ),
            ).animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.2),
            const SizedBox(height: 8),
            Text(
              'This action will take you to the edit screen.',
              style: TextStyle(
                color: Colors.indigo.shade400,
                fontSize: 14,
              ),
            ).animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.2),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.indigo.shade400,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigo.shade400,
                  Colors.indigo.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context, true),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Continue to Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ).animate()
            .fadeIn(delay: 200.ms)
            .slideX(begin: 0.2),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = '${user['first_name']} ${user['last_name']}';
    final String email = user['email'];
    final String avatarUrl = user['avatar'];
    final int id = user['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          fullName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo.shade800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              bool? confirmed = await _showEditConfirmation(context);
              if (confirmed == true) {
                if (!mounted) return;
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditUserScreen(
                      user: user,
                      heroTag: widget.heroTag,
                    ),
                  ),
                );
                if (updated == true) {
                  // Get the latest user data from the provider
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  final updatedUser = userProvider.users.firstWhere(
                    (u) => u.id == user['id'],
                    orElse: () => User.fromJson(user),
                  );
                  
                  setState(() {
                    user = updatedUser.toJson();
                  });
                }
              }
            },
          ),
        ],
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
            Center(
              child: Card(
                margin: const EdgeInsets.all(20),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Hero(
                              tag: widget.heroTag,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.indigo.shade300.withOpacity(0.5),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 75,
                                  backgroundImage: NetworkImage(avatarUrl),
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ).animate()
                              .fadeIn(duration: 600.ms)
                              .scale(delay: 200.ms),
                            const SizedBox(height: 24),
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate()
                              .fadeIn(delay: 300.ms)
                              .slideY(begin: 0.3),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: email));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Email copied to clipboard'),
                                      ],
                                    ),
                                    backgroundColor: Colors.indigo.shade400,
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.email, color: Colors.white70, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      email,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate()
                              .fadeIn(delay: 400.ms)
                              .slideX(begin: -0.2),
                            const SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.indigo.shade300.withOpacity(0.2),
                              ),
                              child: Text(
                                'ID: $id',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ).animate()
                              .fadeIn(delay: 500.ms)
                              .scale(),
                          ],
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
