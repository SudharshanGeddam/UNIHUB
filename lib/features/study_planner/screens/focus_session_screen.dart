import 'package:flutter/material.dart';
import 'package:unihub/core/theme/app_colors.dart';
import 'dart:async';

class FocusSessionScreen extends StatefulWidget {
  final String subject;
  final String focusType;

  const FocusSessionScreen({
    super.key,
    required this.subject,
    required this.focusType,
  });

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Timer? _timer;
  int _remainingSeconds = 25 * 60; // 25 minutes (Pomodoro)
  bool _isRunning = false;
  bool _isPaused = false;
  int _completedSessions = 0;

  // Session duration options
  final List<int> _durationOptions = [15, 25, 45, 60];
  int _selectedDuration = 25;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeSession();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _selectedDuration * 60;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _completedSessions++;
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _selectedDuration * 60;
    });

    // Show completion dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF9C7CFF)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Great Job! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You completed a $_selectedDuration min focus session on ${widget.subject}!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF7C4DFF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Take Break',
                      style: TextStyle(color: Color(0xFF7C4DFF)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _startTimer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            if (_isRunning) {
              _showExitConfirmation();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Focus Session',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: Color(0xFFFF9800), size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_completedSessions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Subject and focus type
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C4DFF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: Color(0xFF7C4DFF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subject,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.focusType,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Timer display
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isRunning
                        ? [
                            const Color(0xFF7C4DFF),
                            const Color(0xFF9C7CFF),
                          ]
                        : [
                            const Color(0xFF2A2A4E),
                            const Color(0xFF3A3A5E),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: _isRunning
                      ? [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF).withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRunning
                            ? (_isPaused ? 'PAUSED' : 'FOCUSING')
                            : 'READY',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Duration selector (only when not running)
            if (!_isRunning)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'Session Duration',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _durationOptions.map((duration) {
                        final isSelected = _selectedDuration == duration;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDuration = duration;
                              _remainingSeconds = duration * 60;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF7C4DFF)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                            ),
                            child: Text(
                              '${duration}m',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
            // Control buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isRunning) ...[
                    // Reset button
                    _buildControlButton(
                      icon: Icons.refresh,
                      onPressed: _resetTimer,
                      isSecondary: true,
                    ),
                    const SizedBox(width: 24),
                    // Pause/Resume button
                    _buildControlButton(
                      icon: _isPaused ? Icons.play_arrow : Icons.pause,
                      onPressed: _isPaused ? _resumeTimer : _pauseTimer,
                      isSecondary: false,
                    ),
                  ] else ...[
                    // Start button
                    _buildControlButton(
                      icon: Icons.play_arrow,
                      onPressed: _startTimer,
                      isSecondary: false,
                      isLarge: true,
                    ),
                  ],
                ],
              ),
            ),
            // Tips section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFFFFD54F),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isRunning
                          ? 'Stay focused! Avoid checking your phone.'
                          : 'Find a quiet place and eliminate distractions.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isSecondary = false,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isLarge ? 100 : 70,
        height: isLarge ? 100 : 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSecondary
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF9C7CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isSecondary ? Colors.white.withOpacity(0.1) : null,
          border: isSecondary
              ? Border.all(color: Colors.white.withOpacity(0.2))
              : null,
          boxShadow: isSecondary
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isLarge ? 48 : 32,
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'End Session?',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You still have ${_formatTime(_remainingSeconds)} left. Are you sure you want to end this focus session?',
          style: TextStyle(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Going',
              style: TextStyle(color: Color(0xFF7C4DFF)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close focus session
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'End Session',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
