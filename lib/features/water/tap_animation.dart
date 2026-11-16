import 'dart:async';
import 'package:flutter/material.dart';

class TapAnimation extends StatefulWidget {
  final bool isOpen;
  final bool isLocked;

  const TapAnimation({
    super.key,
    required this.isOpen,
    required this.isLocked,
  });

  @override
  State<TapAnimation> createState() => _TapAnimationState();
}

class _TapAnimationState extends State<TapAnimation>
    with AutomaticKeepAliveClientMixin {
  Timer? _loopTimer;

  // --- FRAME RANGES (UPDATED FOR YOUR 414 FRAMES) ---
  final int openStart = 1;
  final int openEnd = 107;     // adjust if your opening sequence is longer

  final int loopStart = 108;
  final int loopEnd = 414;     // <-- YOU SAID FRAMES GO TO 414

  int currentFrame = 1;
  bool _isAnimating = false;
  bool _lastOpenState = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _lastOpenState = widget.isOpen;

    // If valve is already open when page loads
    if (widget.isOpen) {
      currentFrame = loopStart;
      _startLoop();
    }
  }

  @override
  void didUpdateWidget(TapAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Valve state changed
    if (widget.isOpen != _lastOpenState) {
      _lastOpenState = widget.isOpen;

      if (widget.isOpen) {
        _playOpening();
      } else {
        _playClosing();
      }
    }
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    super.dispose();
  }

  // --- LOOP ANIMATION ---
  void _startLoop() {
    if (_loopTimer != null) return;

    _loopTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (!mounted || !_lastOpenState) return;

      setState(() {
        currentFrame++;
        if (currentFrame > loopEnd) {
          currentFrame = loopStart;
        }
      });
    });
  }

  void _stopLoop() {
    _loopTimer?.cancel();
    _loopTimer = null;
  }

  // --- OPENING ANIMATION ---
  Future<void> _playOpening() async {
    _isAnimating = true;
    _stopLoop();

    for (int f = openStart; f <= openEnd; f++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() => currentFrame = f);
    }

    setState(() => currentFrame = loopStart);

    _isAnimating = false;
    _startLoop();
  }

  // --- CLOSING ANIMATION ---
  Future<void> _playClosing() async {
    _isAnimating = true;
    _stopLoop();

    for (int f = loopEnd; f >= openStart; f--) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() => currentFrame = f);
    }

    setState(() => currentFrame = openStart);

    _isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: widget.isLocked || _isAnimating ? null : () {},
      child: Image.asset(
        "assets/water/tap_frames/tap_${currentFrame.toString().padLeft(3, '0')}.png",
        gaplessPlayback: true,
      ),
    );
  }
}
