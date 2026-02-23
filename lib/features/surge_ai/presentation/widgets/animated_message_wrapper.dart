import 'package:flutter/material.dart';

class AnimatedMessageWrapper extends StatefulWidget {
  final Widget child;
  final int index;
  final bool isReversed;
  
  const AnimatedMessageWrapper({
    super.key,
    required this.child,
    required this.index,
    this.isReversed = true,
  });
  
  @override
  State<AnimatedMessageWrapper> createState() => _AnimatedMessageWrapperState();
}

class _AnimatedMessageWrapperState extends State<AnimatedMessageWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Stagger animations based on index
    final delay = widget.index * 50.0; // 50ms delay per message
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          1.0,
          curve: Curves.easeOutBack,
        ),
      ),
    );
    
    // Start animation with delay
    Future.delayed(Duration(milliseconds: delay.toInt()), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
