import 'package:flutter/material.dart';
import '../providers/story_provider.dart';
import '../utils/peblo_theme.dart';

class BuddyCharacter extends StatefulWidget {
  final AppState state;
  const BuddyCharacter({super.key, required this.state});

  @override
  State<BuddyCharacter> createState() => _BuddyCharacterState();
}

class _BuddyCharacterState extends State<BuddyCharacter>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _expressionController;
  late Animation<double> _floatAnim;
  late Animation<double> _expressionAnim;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _expressionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _expressionAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _expressionController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(BuddyCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _expressionController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _expressionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _expressionController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: Transform.scale(
            scale: _expressionAnim.value,
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _RobotPainter(
                  isHappy: widget.state == AppState.success,
                  isTalking: widget.state == AppState.playing,
                  isThinking: widget.state == AppState.answering ||
                      widget.state == AppState.quizReveal,
                  animValue: _floatController.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RobotPainter extends CustomPainter {
  final bool isHappy;
  final bool isTalking;
  final bool isThinking;
  final double animValue;

  _RobotPainter({
    required this.isHappy,
    required this.isTalking,
    required this.isThinking,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()..color = const Color(0xFF7B68EE);
    final accentPaint = Paint()..color = PebloTheme.skyBlue;
    final facePaint = Paint()..color = const Color(0xFFEEEEFF);
    final eyePaint = Paint()..color = const Color(0xFF2D2D3A);
    final glowPaint = Paint()
      ..color = PebloTheme.skyBlue.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final gearPaint = Paint()..color = PebloTheme.skyBlue;

    canvas.drawCircle(Offset(w * 0.5, h * 0.55), w * 0.42, glowPaint);

    final antennaPaint = Paint()
      ..color = const Color(0xFF9D8DF1)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.5, h * 0.12), Offset(w * 0.5, h * 0.22), antennaPaint);

    final antBallRadius = isTalking ? 5.0 + animValue * 2 : 5.0;
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.10),
      antBallRadius,
      Paint()..color = isHappy ? PebloTheme.sunYellow : PebloTheme.skyBlue,
    );

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.62), width: w * 0.62, height: h * 0.38),
      const Radius.circular(12),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    canvas.drawCircle(Offset(w * 0.5, h * 0.65), w * 0.08, gearPaint);
    canvas.drawCircle(
        Offset(w * 0.5, h * 0.65), w * 0.04, Paint()..color = PebloTheme.midnightBlue);

    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.33), width: w * 0.65, height: h * 0.30),
      const Radius.circular(14),
    );
    canvas.drawRRect(headRect, facePaint);

    canvas.drawCircle(Offset(w * 0.17, h * 0.33), 5, accentPaint);
    canvas.drawCircle(Offset(w * 0.83, h * 0.33), 5, accentPaint);

    final eyeY = h * 0.30;
    if (isHappy) {
      final eyeArcPaint = Paint()
        ..color = eyePaint.color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
          Rect.fromCenter(center: Offset(w * 0.37, eyeY), width: 14, height: 10),
          3.14, 3.14, false, eyeArcPaint);
      canvas.drawArc(
          Rect.fromCenter(center: Offset(w * 0.63, eyeY), width: 14, height: 10),
          3.14, 3.14, false, eyeArcPaint);
    } else {
      final eyeSize = animValue > 0.85 ? 2.0 : 5.0;
      canvas.drawCircle(Offset(w * 0.37, eyeY), eyeSize, eyePaint);
      canvas.drawCircle(Offset(w * 0.63, eyeY), eyeSize, eyePaint);
      canvas.drawCircle(Offset(w * 0.37, eyeY), eyeSize * 1.4,
          Paint()..color = PebloTheme.skyBlue.withOpacity(0.2));
      canvas.drawCircle(Offset(w * 0.63, eyeY), eyeSize * 1.4,
          Paint()..color = PebloTheme.skyBlue.withOpacity(0.2));
    }

    final mouthPaint = Paint()
      ..color = eyePaint.color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isHappy) {
      canvas.drawArc(
          Rect.fromCenter(center: Offset(w * 0.5, h * 0.38), width: 22, height: 14),
          0, 3.14, false, mouthPaint);
    } else if (isTalking) {
      final mouthH = 6 + animValue * 5;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(w * 0.5, h * 0.40), width: 14, height: mouthH),
          Paint()..color = eyePaint.color);
    } else {
      canvas.drawArc(
          Rect.fromCenter(center: Offset(w * 0.5, h * 0.39), width: 16, height: 8),
          0, 3.14, false, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(_RobotPainter old) =>
      old.isHappy != isHappy ||
      old.isTalking != isTalking ||
      old.isThinking != isThinking ||
      old.animValue != animValue;
}
