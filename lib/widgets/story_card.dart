import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../utils/peblo_theme.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final state = provider.state;
    final bool showStoryText = state != AppState.idle;
    final bool isLoading = state == AppState.loading;
    final bool isPlaying = state == AppState.playing;
    final bool showButton = state == AppState.idle || state == AppState.loading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: PebloTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📖', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Today\'s Story',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: PebloTheme.deepPurple,
                  letterSpacing: 1.2,
                ),
              ),
              if (isPlaying) ...[const Spacer(), _AudioWave()],
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 400),
            crossFadeState: showStoryText
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              'Tap below to hear a magical story from Pip! 🤖',
              style: PebloTheme.storyText(context).copyWith(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
            secondChild: Text(
              StoryProvider.storyText,
              style: PebloTheme.storyText(context),
            ),
          ),
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: PebloTheme.coralRed.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: PebloTheme.coralRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (showButton) ...[
            const SizedBox(height: 20),
            _ReadMeButton(isLoading: isLoading),
          ],
        ],
      ),
    );
  }
}

class _ReadMeButton extends StatefulWidget {
  final bool isLoading;
  const _ReadMeButton({required this.isLoading});

  @override
  State<_ReadMeButton> createState() => _ReadMeButtonState();
}

class _ReadMeButtonState extends State<_ReadMeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) async {
        await _pressController.reverse();
        if (context.mounted && !widget.isLoading) {
          context.read<StoryProvider>().startStory();
        }
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: widget.isLoading ? null : PebloTheme.ctaGradient,
            color: widget.isLoading ? Colors.grey.shade200 : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: PebloTheme.sunYellow.withOpacity(0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation(PebloTheme.deepPurple),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Getting the story ready...',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: PebloTheme.deepPurple,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🎙️', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      'Read Me a Story!',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: Color(0xFF2D2D3A),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _AudioWave extends StatefulWidget {
  @override
  State<_AudioWave> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<_AudioWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          children: List.generate(4, (i) {
            final height =
                6.0 + (_ctrl.value * 12 * ((i % 2 == 0) ? 1 : -1)).abs();
            return Container(
              width: 3,
              height: height + 6,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: PebloTheme.skyBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
