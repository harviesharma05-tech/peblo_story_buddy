import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../utils/peblo_theme.dart';

class QuizCard extends StatefulWidget {
  const QuizCard({super.key});

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -16), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -16, end: 16), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 16, end: -12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -12, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.linear));

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _slideController.forward();
  }

  @override
  void didUpdateWidget(QuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final provider = context.read<StoryProvider>();
    if (provider.isShaking && !_shakeController.isAnimating) {
      HapticFeedback.mediumImpact();
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final question = provider.quizQuestion;
    final state = provider.state;

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _slideController,
        child: AnimatedBuilder(
          animation: _shakeAnim,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnim.value, 0),
              child: child,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: PebloTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.question,
                        style: PebloTheme.questionText(context),
                      ),
                    ),
                  ],
                ),
                if (provider.wrongAttempts > 0 &&
                    state == AppState.answering) ...[
                  const SizedBox(height: 8),
                  Text(
                    provider.wrongAttempts == 1
                        ? 'Almost! Give it another go 💪'
                        : 'Think about Pip\'s gear colour! 🔵',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                // Data-driven — maps over options, no hardcoded count
                ...question.options.asMap().entries.map((entry) {
                  return _OptionTile(
                    option: entry.value,
                    index: entry.key,
                    isCorrect: entry.value == question.answer,
                    state: state,
                    onTap: state == AppState.answering
                        ? () => provider.selectOption(entry.value)
                        : null,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatefulWidget {
  final String option;
  final int index;
  final bool isCorrect;
  final AppState state;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.option,
    required this.index,
    required this.isCorrect,
    required this.state,
    required this.onTap,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnim;

  static const List<String> _labels = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool revealCorrect =
        widget.state == AppState.success && widget.isCorrect;

    Color bgColor = PebloTheme.cloudWhite;
    Color borderColor = const Color(0xFFE0D9F7);
    Color textColor = const Color(0xFF2D2D3A);

    if (revealCorrect) {
      bgColor = PebloTheme.leafGreen.withOpacity(0.15);
      borderColor = PebloTheme.leafGreen;
      textColor = const Color(0xFF1B5E20);
    }

    final label =
        widget.index < _labels.length ? _labels[widget.index] : '•';

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) _tapController.forward();
      },
      onTapUp: (_) {
        _tapController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _tapController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: revealCorrect
                ? [
                    BoxShadow(
                      color: PebloTheme.leafGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: revealCorrect
                      ? PebloTheme.leafGreen
                      : PebloTheme.deepPurple.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  revealCorrect ? '✓' : label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: revealCorrect
                        ? Colors.white
                        : PebloTheme.deepPurple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.option,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),
              if (revealCorrect)
                const Text('🌟', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
