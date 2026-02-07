import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class RestTimerOverlay extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onFinished;

  const RestTimerOverlay({
    super.key,
    required this.initialSeconds,
    required this.onFinished,
  });

  @override
  State<RestTimerOverlay> createState() => _RestTimerOverlayState();
}

class _RestTimerOverlayState extends State<RestTimerOverlay> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        widget.onFinished();
      }
    });
  }

  void _adjustTime(int seconds) {
    setState(() {
      _remainingSeconds = (_remainingSeconds + seconds).clamp(0, 999);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'RESTING',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAdjustButton('-15s', () => _adjustTime(-15)),
              const SizedBox(width: 20),
              _buildAdjustButton('+15s', () => _adjustTime(15)),
            ],
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              widget.onFinished();
            },
            child: const Text('SKIP REST', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: AppTheme.primary, width: 1),
        minimumSize: const Size(100, 45),
      ),
      child: Text(label, style: const TextStyle(color: AppTheme.primary)),
    );
  }
}
