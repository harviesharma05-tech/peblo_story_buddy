import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../utils/peblo_theme.dart';
import '../widgets/buddy_character.dart';
import '../widgets/story_card.dart';
import '../widgets/quiz_card.dart';
import '../widgets/success_overlay.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StoryProvider>().state;
    final bool showQuiz = state == AppState.quizReveal ||
        state == AppState.answering ||
        state == AppState.wrong;
    final bool showSuccess = state == AppState.success;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: PebloTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PebloAppBar(),
                const SizedBox(height: 8),
                BuddyCharacter(state: state),
                const SizedBox(height: 4),
                _BuddyLabel(state: state),
                const SizedBox(height: 20),
                const StoryCard(),
                const SizedBox(height: 16),
                AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  child: showSuccess
                      ? const SuccessOverlay()
                      : showQuiz
                          ? const QuizCard()
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PebloAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: PebloTheme.sunYellow,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Text('🎓', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 10),
        const Text(
          'Peblo',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 26,
            color: PebloTheme.cloudWhite,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _BuddyLabel extends StatelessWidget {
  final AppState state;
  const _BuddyLabel({required this.state});

  String get _statusText {
    switch (state) {
      case AppState.idle:       return 'Ready for an adventure! 🚀';
      case AppState.loading:    return 'Warming up my voice...';
      case AppState.playing:    return 'Listening... 🎧';
      case AppState.quizReveal:
      case AppState.answering:
      case AppState.wrong:      return 'Think carefully! 🤔';
      case AppState.success:    return 'Woohoo! You\'re brilliant! 🎉';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Hi, I\'m Pip! 🤖',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: PebloTheme.cloudWhite,
          ),
        ),
        const SizedBox(height: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Text(
            _statusText,
            key: ValueKey(state),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: PebloTheme.softLavender,
            ),
          ),
        ),
      ],
    );
  }
}
