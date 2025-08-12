import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../core/services/tts_service.dart';

class TtsControlWidget extends StatefulWidget {
  final String noteContent;
  final String? selectedText;
  final VoidCallback? onSettingsPressed;

  const TtsControlWidget({
    super.key,
    required this.noteContent,
    this.selectedText,
    this.onSettingsPressed,
  });

  @override
  State<TtsControlWidget> createState() => _TtsControlWidgetState();
}

class _TtsControlWidgetState extends State<TtsControlWidget> with TickerProviderStateMixin {
  late TtsService _ttsService;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showAdvancedControls = false;

  @override
  void initState() {
    super.initState();
    _ttsService = TtsService();
    _ttsService.initTts();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_ttsService.isPlaying) {
      _ttsService.pause();
      _pulseController.stop();
    } else if (_ttsService.isPaused) {
      // Continue from where paused - TTS doesn't support resume, so we'll stop
      _ttsService.stop();
    } else {
      // Start speaking
      String textToSpeak = widget.selectedText?.isNotEmpty == true 
          ? widget.selectedText!
          : widget.noteContent;
      _ttsService.speakNote(textToSpeak);
      _pulseController.repeat(reverse: true);
    }
  }

  void _stopSpeaking() {
    _ttsService.stop();
    _pulseController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _ttsService,
      child: Consumer<TtsService>(
        builder: (context, ttsService, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Main Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Play/Pause Button
                    _buildControlButton(
                      onPressed: _togglePlayPause,
                      icon: _getPlayPauseIcon(ttsService.ttsState),
                      label: _getPlayPauseLabel(ttsService.ttsState),
                      isPrimary: true,
                      isAnimated: ttsService.isPlaying,
                    ),

                    // Stop Button
                    _buildControlButton(
                      onPressed: ttsService.isPlaying || ttsService.isPaused 
                          ? _stopSpeaking 
                          : null,
                      icon: Icons.stop_rounded,
                      label: 'Stop',
                      color: Colors.red.shade400,
                    ),

                    // Speak Selection (if text is selected)
                    if (widget.selectedText?.isNotEmpty == true)
                      _buildControlButton(
                        onPressed: () => _ttsService.speakSelection(widget.selectedText!),
                        icon: Icons.record_voice_over_rounded,
                        label: 'Selection',
                        color: UnifiedTheme.primaryGreen,
                      ),

                    // Settings Button
                    _buildControlButton(
                      onPressed: () {
                        setState(() {
                          _showAdvancedControls = !_showAdvancedControls;
                        });
                      },
                      icon: Icons.tune_rounded,
                      label: 'Settings',
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),

                // Advanced Controls (expandable)
                if (_showAdvancedControls) ...[
                  const SizedBox(height: 16),
                  _buildAdvancedControls(ttsService),
                ],

                // Status Display
                if (ttsService.isPlaying) ...[
                  const SizedBox(height: 12),
                  _buildStatusDisplay(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    bool isPrimary = false,
    bool isAnimated = false,
    Color? color,
  }) {
    Widget iconWidget = Icon(
      icon,
      size: 20,
      color: onPressed == null
          ? Colors.grey
          : (isPrimary ? Colors.white : color ?? UnifiedTheme.primaryGreen),
    );

    if (isAnimated) {
      iconWidget = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: iconWidget,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: onPressed == null
                ? Colors.grey.shade200
                : (isPrimary ? UnifiedTheme.primaryGreen : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: !isPrimary && onPressed != null
                ? Border.all(color: color ?? UnifiedTheme.primaryGreen, width: 1)
                : null,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: iconWidget,
            splashRadius: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: onPressed == null ? Colors.grey : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAdvancedControls(TtsService ttsService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speech Rate
          _buildSliderControl(
            'Speech Rate',
            ttsService.speechRate,
            0.1,
            1.0,
            (value) => _ttsService.setSpeechRate(value),
            Icons.speed_rounded,
          ),
          const SizedBox(height: 12),

          // Pitch
          _buildSliderControl(
            'Pitch',
            ttsService.pitch,
            0.5,
            2.0,
            (value) => _ttsService.setPitch(value),
            Icons.graphic_eq_rounded,
          ),
          const SizedBox(height: 12),

          // Volume
          _buildSliderControl(
            'Volume',
            ttsService.volume,
            0.0,
            1.0,
            (value) => _ttsService.setVolume(value),
            Icons.volume_up_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderControl(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: 20,
            activeColor: UnifiedTheme.primaryGreen,
            onChanged: onChanged,
          ),
        ),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: UnifiedTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_outline_rounded,
            size: 16,
            color: UnifiedTheme.primaryGreen,
          ),
          const SizedBox(width: 6),
          Text(
            'Reading aloud...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: UnifiedTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlayPauseIcon(TtsState state) {
    switch (state) {
      case TtsState.playing:
        return Icons.pause_rounded;
      case TtsState.paused:
        return Icons.play_arrow_rounded;
      case TtsState.stopped:
        return Icons.play_arrow_rounded;
      case TtsState.continued:
        return Icons.pause_rounded;
    }
  }

  String _getPlayPauseLabel(TtsState state) {
    switch (state) {
      case TtsState.playing:
        return 'Pause';
      case TtsState.paused:
        return 'Play';
      case TtsState.stopped:
        return 'Play';
      case TtsState.continued:
        return 'Pause';
    }
  }
}