// user_list_screen.dart

import 'add_user_screen.dart';
import 'user_detail_screen.dart';
import 'edit_user_screen.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
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
            color: Colors.red.shade50,
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
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade700,
                  size: 24,
                ),
              ).animate()
                .scale(duration: 300.ms)
                .fadeIn(),
              const SizedBox(width: 12),
              Text(
                'Confirm Logout',
                style: TextStyle(
                  color: Colors.red.shade900,
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
              'Are you sure you want to logout?',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 16,
                height: 1.5,
              ),
            ).animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.2),
            const SizedBox(height: 8),
            Text(
              'You will need to login again to access the app.',
              style: TextStyle(
                color: Colors.red.shade400,
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
                color: Colors.red.shade400,
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
                  Colors.red.shade400,
                  Colors.red.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade200,
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
                    'Logout',
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

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      Fluttertoast.showToast(msg: 'Logged out successfully 👋');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        searchQuery = value;
      });
    });
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return const ListTile(
          leading: ShimmerWidget.circular(width: 40, height: 40),
          title: ShimmerWidget.rectangular(height: 14),
          subtitle: ShimmerWidget.rectangular(height: 12),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final filteredUsers = userProvider.users.where((user) {
          final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
          final email = user.email.toLowerCase();
          final query = searchQuery.toLowerCase();
          return fullName.contains(query) || email.contains(query);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Users',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.indigo.shade800,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => logout(),
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
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            hintStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.search, color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: userProvider.isLoading
                            ? _buildLoadingList()
                            : filteredUsers.isEmpty
                                ? _buildEmptyState()
                                : AnimationLimiter(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: filteredUsers.length,
                                      itemBuilder: (context, index) {
                                        final user = filteredUsers[index];
                                        return AnimationConfiguration.staggeredList(
                                          position: index,
                                          duration: const Duration(milliseconds: 375),
                                          child: SlideAnimation(
                                            verticalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: _buildUserCard(user),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: child,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.shade300.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddUserScreen()),
                  );
                  if (result == true) {
                    Provider.of<UserProvider>(context, listen: false).fetchUsers();
                  }
                },
                backgroundColor: Colors.indigo.shade500,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(User user) {
    final heroTag = 'user-avatar-${user.id}';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: Hero(
          tag: heroTag,
          child: Material(
            elevation: 8,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(user.avatar),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          "${user.firstName} ${user.lastName}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade900,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(
            color: Colors.indigo.shade700,
          ),
        ),
        onTap: () async {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailScreen(
                user: user.toJson(),
                heroTag: heroTag,
              ),
            ),
          );
          if (updated == true) {
            Provider.of<UserProvider>(context, listen: false).fetchUsers();
          }
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.indigo,
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditUserScreen(
                      user: user.toJson(),
                      heroTag: heroTag,
                    ),
                  ),
                );
                if (updated == true) {
                  Provider.of<UserProvider>(context, listen: false).fetchUsers();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.redAccent,
              onPressed: () => confirmDeleteUser(user.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return _buildShimmerList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            color: Colors.indigo.shade700,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              color: Colors.indigo.shade700,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> confirmDeleteUser(int userId) async {
    final shouldDelete = await showDialog<bool>(
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
            color: Colors.red.shade50,
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
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red.shade700,
                  size: 24,
                ),
              ).animate()
                .scale(duration: 300.ms)
                .fadeIn(),
              const SizedBox(width: 12),
              Text(
                'Delete User',
                style: TextStyle(
                  color: Colors.red.shade900,
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
              'Are you sure you want to delete this user?',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 16,
                height: 1.5,
              ),
            ).animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.2),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red.shade400,
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
                color: Colors.red.shade400,
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
                  Colors.red.shade400,
                  Colors.red.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade200,
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
                    'Delete',
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

    if (shouldDelete == true) {
      setState(() {
        // Show loading indicator while deleting
        Provider.of<UserProvider>(context, listen: false).isLoading = true;
      });
      
      final success = await Provider.of<UserProvider>(context, listen: false).deleteUser(userId);
      
      if (success) {
        // Refresh the user list to ensure the deleted user is removed
        await Provider.of<UserProvider>(context, listen: false).fetchUsers();
        
        Fluttertoast.showToast(
          msg: 'User deleted successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to delete user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }
}

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
  }) : shapeBorder = const RoundedRectangleBorder();

  const ShimmerWidget.circular({
    super.key,
    required this.width,
    required this.height,
  }) : shapeBorder = const CircleBorder();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(color: Colors.grey, shape: shapeBorder),
        ),
      );
}
