import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../utils/peblo_theme.dart';

class SuccessOverlay extends StatefulWidget {
  const SuccessOverlay({super.key});

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _confettiController.play();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 30,
          gravity: 0.08,
          emissionFrequency: 0.08,
          colors: const [
            PebloTheme.sunYellow,
            PebloTheme.skyBlue,
            PebloTheme.leafGreen,
            PebloTheme.coralRed,
            Colors.purple,
            Colors.pink,
          ],
          child: const SizedBox.shrink(),
        ),
        ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: PebloTheme.successGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: PebloTheme.leafGreen.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                const Text(
                  'Amazing!',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pip\'s gear was Blue!\nYou\'re a superstar explorer! 🌟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: Text('⭐', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => context.read<StoryProvider>().restart(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔄', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'Play Again',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: PebloTheme.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
