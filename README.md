 # Peblo – AI Story Buddy & Quiz Component
### Mobile App Developer Intern Challenge | Harvi Sharma

---

## 📱 Demo

> Screen recording: `screen_recording_harvi_sharma.mp4`
>
> Flow: Idle → Tap "Read Me a Story" → Loading state → TTS narration → Quiz reveals → Wrong answer shake → Correct answer confetti

---

## 🛠️ Framework Choice: Flutter

I chose **Flutter** over Swift for this challenge for three reasons:

1. **Peblo's target audience is mid-range Android in India** — Flutter compiles to native ARM code and delivers smooth 60fps on ~3GB RAM devices without JVM overhead.
2. **Single codebase** — The same code targets Android and iOS, which matters for a seed-stage startup shipping fast.
3. **`flutter_tts`** — Flutter's TTS plugin wraps Android's native `TextToSpeech` engine, which is already present on every Android device with no extra download, keeping the APK lean.

---

## 🏗️ Architecture
lib/

├── main.dart                 # Entry point, Provider setup

├── models/

│   └── quiz_question.dart    # Data model — parses JSON, no hardcoding

├── providers/

│   └── story_provider.dart   # State machine (ChangeNotifier)

├── screens/

│   └── home_screen.dart      # Single screen assembly

├── utils/

│   └── peblo_theme.dart      # Brand palette, typography tokens

└── widgets/

    ├── buddy_character.dart  # Animated robot, canvas-drawn

├── story_card.dart       # Story text + CTA button

├── quiz_card.dart        # Data-driven quiz renderer

└── success_overlay.dart  # Confetti + success state
**State management: Provider (ChangeNotifier)**

I used Provider rather than BLoC or Riverpod because:
- The state machine is a single linear flow with no branching streams
- Provider adds zero overhead on modest hardware
- `context.watch<T>()` / `context.read<T>()` is clean and readable

The `AppState` enum drives every UI decision:
idle → loading → playing → quizReveal → answering → wrong → success

↑_________↓ (retry loop)
---

## 🎵 Audio → Quiz Transition

When TTS narration ends, `FlutterTts.setCompletionHandler` fires `_onNarrationComplete()` inside `StoryProvider`:

```dart
void _onNarrationComplete() {
  _setState(AppState.quizReveal);          // Triggers slide-in animation
  Future.delayed(const Duration(milliseconds: 1200), () {
    _setState(AppState.answering);         // Enable taps after animation settles
  });
}
```

`HomeScreen` uses `AnimatedSize` to smoothly expand the space as the `QuizCard` slides in via a `SlideTransition` (bottom → centre, `easeOutCubic`, 550ms). The 1200ms gap prevents the child from accidentally tapping before the card finishes animating.

---

## 🔀 Data-Driven Quiz Renderer

The quiz JSON is treated exactly as if it arrived from the Peblo backend:

```json
{
  "question": "What colour was Pip the Robot's lost gear?",
  "options": ["Red", "Green", "Blue", "Yellow"],
  "answer": "Blue"
}
```

`QuizQuestion.fromJson()` parses this into a model with `List<String> options` — no count assumption anywhere. The renderer just maps over the list:

```dart
...question.options.asMap().entries.map((entry) {
  return _OptionTile(option: entry.value, index: entry.key, ...);
}),
```

To handle a 3-option or 5-option question from the backend, you change **zero lines** of rendering code — just pass a different JSON string.

---

## 📦 Caching Approach

**Current (native TTS — no network):**
Android's `TextToSpeech` synthesises locally in under 200ms — there is nothing to cache.

**If integrating ElevenLabs remote audio:**
I would cache the MP3 response keyed by a SHA-256 hash of the story text:

```dart
final cacheKey = sha256(storyText).toString();
final cachedFile = await _localCache.get(cacheKey);
if (cachedFile != null) {
  await _audioPlayer.play(cachedFile);
} else {
  final bytes = await ElevenLabsApi.synthesise(storyText);
  await _localCache.put(cacheKey, bytes);  // 7-day TTL
  await _audioPlayer.playBytes(bytes);
}
```

Cache directory: `getApplicationDocumentsDirectory()` — survives app restart. Content-hash keying means a story text change automatically busts the cache with no manual invalidation needed.

---

## 🔊 Audio Loading & Failure States

Three states are explicitly handled:

| State | UI Behaviour |
|---|---|
| Loading | Spinner + "Getting the story ready..." replaces the CTA button |
| Playing | Audio wave indicator in story card; Pip's mouth animates open/close |
| TTS init failure | Skips to quiz with message: "My voice is resting today 😴" |
| speak() failure | Coral error card with retry; app never hangs or crashes |
| Narration cancelled | `setCancelHandler` returns to `idle` gracefully |

---

## ⚡ Performance Profiling

**Target:** Smooth 60fps on Redmi Note 11 / Samsung Galaxy A14 class devices (~3GB RAM).

**What I measured:** Flutter DevTools → Performance tab → Frame timing during:
- Buddy float animation (runs continuously)
- Quiz card slide-in
- Shake animation on wrong answer
- Confetti burst on success

**Optimisations applied:**

| Issue | Fix Applied |
|---|---|
| `_RobotPainter` repainting on every tick | `shouldRepaint` returns `false` when unrelated fields unchanged |
| `ConfettiWidget` always in the widget tree | Mounted only inside `SuccessOverlay`, which only renders on success |
| `_AudioWave` controller ticking off-screen | `AnimationController` disposed when widget leaves the tree |
| Broad Provider rebuilds | `context.watch` scoped to the smallest widget that needs it |

**APK size:** `flutter build apk --split-per-abi` produces separate ARM32 / ARM64 / x86_64 APKs — reduces install size by ~40% vs a fat APK, important for users on limited storage.

---

## 🤖 AI Usage & Judgment

**Where I used AI assistance:**
I used Claude (Anthropic) to scaffold the initial `StoryProvider` state machine structure and the `_RobotPainter` canvas drawing code.

**One suggestion I rejected and why:**
Claude initially suggested using BLoC for state management. I changed this to Provider because BLoC's Stream/Sink pattern adds significant boilerplate for a single-screen app with a linear state machine. Provider's `ChangeNotifier` achieves the same result with far less code — and less code means fewer bugs on a time-constrained device.

**What didn't work and how I fixed it:**
`flutter_tts`'s `setCompletionHandler` does not fire on all Android versions when the app is backgrounded mid-narration. I fixed this by adding `setCancelHandler` which gracefully returns the app to `AppState.idle` if narration is interrupted, preventing it from hanging in the `playing` state indefinitely.

---

## 📋 Submission Checklist

- [x] Single-screen Flutter app
- [x] Kid-friendly, vibrant UI
- [x] AI Buddy character — Pip the Robot, canvas-drawn with no image assets
- [x] "Read Me a Story" button with loading state
- [x] TTS narration via `flutter_tts` (native Android/iOS engine)
- [x] Graceful error handling — no crash, friendly retry message
- [x] Quiz renders from JSON, not hardcoded
- [x] Handles variable option count (3/4/5) without code changes
- [x] Wrong answer: shake animation + haptic feedback
- [x] Correct answer: confetti + success state + Play Again
- [x] State management via Provider
- [x] Performance-conscious: `shouldRepaint`, controller disposal, `BouncingScrollPhysics`
- [x] Portrait lock + transparent status bar

---

## 📦 Running the Project

```bash
git clone https://github.com/harviesharma05-tech/peblo_story_buddy
cd peblo_story_buddy
flutter pub get
flutter run
```

Release APK split by ABI:
```bash
flutter build apk --split-per-abi --release
```

---

*Built with care for Peblo's mission — joyful learning for every child 🚀*
