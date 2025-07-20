import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';

/// Animated OTP input widget with iOS-style micro interactions
class AnimatedOTPInput extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final bool autoFocus;

  const AnimatedOTPInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.autoFocus = true,
  });

  @override
  State<AnimatedOTPInput> createState() => _AnimatedOTPInputState();
}

class _AnimatedOTPInputState extends State<AnimatedOTPInput>
    with TickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<Color?>> _colorAnimations;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );

    // Add listeners for focus changes
    for (int i = 0; i < widget.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          _animationControllers[i].forward();
          HapticFeedback.selectionClick();
        } else {
          _animationControllers[i].reverse();
        }
      });
    }
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.length,
      (index) => AnimationController(
        duration: AppAnimations.fast,
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.05,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: AppAnimations.iosSpring,
      ));
    }).toList();

    _colorAnimations = _animationControllers.map((controller) {
      return ColorTween(
        begin: Colors.grey.shade300,
        end: AppTheme.primaryOrange,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: AppAnimations.easeInOut,
      ));
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    for (var animationController in _animationControllers) {
      animationController.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      HapticFeedback.lightImpact();
      
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      // Move to previous field on backspace
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    // Check if OTP is complete
    String otp = _controllers.map((controller) => controller.text).join();
    widget.onChanged?.call(otp);
    
    if (otp.length == widget.length) {
      HapticFeedback.mediumImpact();
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimations[index],
            _colorAnimations[index],
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              child: Container(
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: _colorAnimations[index].value ?? Colors.grey.shade300,
                    width: 2,
                  ),
                  color: Colors.white,
                  boxShadow: _focusNodes[index].hasFocus
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryOrange.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) => _onChanged(value, index),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}