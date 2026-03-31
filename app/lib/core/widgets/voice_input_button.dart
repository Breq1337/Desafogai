import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../theme/app_colors.dart';

/// A mic button that records speech and returns the transcribed text.
///
/// Uses the device's native speech recognition (free, no API costs).
/// Supports pt-BR on Android, iOS, and Chrome/Edge (Web Speech API).
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.onListeningChanged,
    this.size = 44,
    this.enabled = true,
  });

  final ValueChanged<String> onResult;
  final ValueChanged<bool>? onListeningChanged;
  final double size;
  final bool enabled;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  bool _initialized = false;
  String _lastWords = '';

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (error) {
          if (kDebugMode) print('Speech error: ${error.errorMsg}');
          _stopListening();
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _stopListening();
          }
        },
      );
      _initialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      if (kDebugMode) print('Speech init error: $e');
      _isAvailable = false;
      _initialized = true;
      if (mounted) setState(() {});
    }
  }

  Future<void> _startListening() async {
    if (!_isAvailable || !_initialized) {
      _showUnavailableMessage();
      return;
    }

    _lastWords = '';
    setState(() => _isListening = true);
    widget.onListeningChanged?.call(true);
    _pulseController.repeat(reverse: true);

    await _speech.listen(
      onResult: _onSpeechResult,
      localeId: 'pt_BR',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: true,
      ),
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    if (result.finalResult && _lastWords.isNotEmpty) {
      widget.onResult(_lastWords);
      _stopListening();
    }
  }

  void _stopListening() {
    if (!_isListening) return;
    _speech.stop();
    _pulseController.stop();
    _pulseController.reset();
    if (mounted) {
      setState(() => _isListening = false);
      widget.onListeningChanged?.call(false);
    }
  }

  void _showUnavailableMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Reconhecimento de voz indisponível neste dispositivo',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.enabled && _initialized;

    return GestureDetector(
      onTap: isActive
          ? () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            }
          : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = _isListening ? _pulseAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening
                    ? AppColors.danger
                    : isActive
                        ? AppColors.primaryContainer.withValues(alpha: 0.15)
                        : AppColors.divider.withValues(alpha: 0.5),
                border: _isListening
                    ? null
                    : Border.all(
                        color: isActive
                            ? AppColors.primaryContainer.withValues(alpha: 0.3)
                            : AppColors.divider,
                      ),
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: AppColors.danger.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: _isListening
                      ? Colors.white
                      : isActive
                          ? AppColors.primaryContainer
                          : AppColors.textSecondary,
                  size: widget.size * 0.45,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
