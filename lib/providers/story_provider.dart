import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz_question.dart';

enum AppState {
  idle,
  loading,
  playing,
  quizReveal,
  answering,
  wrong,
  success,
}

class StoryProvider extends ChangeNotifier {
  static const String storyText =
      'Once upon a time, a clever little robot named Pip lost his '
      'shiny blue gear in the Whispering Woods...';

  static const String _quizJson = '''
  {
    "question": "What colour was Pip the Robot's lost gear?",
    "options": ["Red", "Green", "Blue", "Yellow"],
    "answer": "Blue"
  }
  ''';

  late final QuizQuestion quizQuestion;

  AppState _state = AppState.idle;
  AppState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _selectedOption;
  String? get selectedOption => _selectedOption;

  bool _isShaking = false;
  bool get isShaking => _isShaking;

  int _wrongAttempts = 0;
  int get wrongAttempts => _wrongAttempts;

  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  StoryProvider() {
    quizQuestion = QuizQuestion.fromJson(
      json.decode(_quizJson) as Map<String, dynamic>,
    );
    _initialiseTts();
  }

  Future<void> _initialiseTts() async {
    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.1);

      _tts.setCompletionHandler(_onNarrationComplete);
      _tts.setCancelHandler(() {
        if (_state == AppState.playing) {
          _setState(AppState.idle);
        }
      });
      _tts.setErrorHandler((msg) {
        _handleTtsError('Could not play audio: $msg');
      });

      _ttsReady = true;
    } catch (e) {
      _ttsReady = false;
    }
  }

  Future<void> startStory() async {
    if (_state == AppState.playing) return;

    _setState(AppState.loading);
    _errorMessage = null;

    await Future.delayed(const Duration(milliseconds: 600));

    if (!_ttsReady) {
      _errorMessage =
          "Oops! My voice is resting today 😴\nBut the quiz is ready for you!";
      _setState(AppState.quizReveal);
      await Future.delayed(const Duration(milliseconds: 800));
      _setState(AppState.answering);
      return;
    }

    try {
      _setState(AppState.playing);
      final result = await _tts.speak(storyText);
      if (result != 1) {
        _handleTtsError('TTS speak returned failure.');
      }
    } catch (e) {
      _handleTtsError(e.toString());
    }
  }

  Future<void> selectOption(String option) async {
    if (_state != AppState.answering) return;

    _selectedOption = option;

    if (option == quizQuestion.answer) {
      _setState(AppState.success);
    } else {
      _wrongAttempts++;
      _setState(AppState.wrong);
      await _triggerShake();
      _setState(AppState.answering);
      _selectedOption = null;
    }
  }

  Future<void> restart() async {
    await _tts.stop();
    _selectedOption = null;
    _wrongAttempts = 0;
    _errorMessage = null;
    _isShaking = false;
    _setState(AppState.idle);
  }

  void _onNarrationComplete() {
    _setState(AppState.quizReveal);
    Future.delayed(const Duration(milliseconds: 1200), () {
      _setState(AppState.answering);
    });
  }

  void _handleTtsError(String message) {
    _errorMessage =
        "Hmm, something went wrong with the story 😕\nTap to try again!";
    _setState(AppState.idle);
    debugPrint('[StoryProvider] TTS error: $message');
  }

  Future<void> _triggerShake() async {
    _isShaking = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isShaking = false;
    notifyListeners();
  }

  void _setState(AppState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
