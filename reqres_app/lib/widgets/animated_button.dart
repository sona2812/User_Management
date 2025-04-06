import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedButton extends StatefulWidget {
  final Function()? onPressed;
  final Widget child;
  final Color color;
  final double width;
  final double height;
  final bool isLoading;

  const AnimatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.color = Colors.deepPurple,
    this.width = 200,
    this.height = 50,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color.withOpacity(0.8),
                    widget.color,
                    widget.color.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading || widget.onPressed == null ? null : () {
                    widget.onPressed?.call();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : DefaultTextStyle(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              child: widget.child,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 1000))
      .scale(delay: const Duration(milliseconds: 1000));
  }
} 