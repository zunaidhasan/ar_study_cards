import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../flashcard_creator/flashcard_provider.dart';
import '../../models/flashcard.dart';

class VoiceReviewScreen extends StatefulWidget {
  const VoiceReviewScreen({super.key});

  @override
  State<VoiceReviewScreen> createState() => _VoiceReviewScreenState();
}

class _VoiceReviewScreenState extends State<VoiceReviewScreen> with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _lastWords = '';
  int _currentIndex = 0;
  bool _showingAnswer = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initSpeech();
    _initTts();
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  void _initTts() {
    _tts.setCompletionHandler(() {
      if (mounted && _isListening) {
        _startListening();
      }
    });
  }

  void _startListening() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      _animationController.repeat();
      await _speech.listen(
        onResult: (result) {
          setState(() => _lastWords = result.recognizedWords.toLowerCase());
          if (result.finalResult) {
            _processCommand(_lastWords);
          }
        },
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() => _isListening = false);
      _animationController.stop();
      _speech.stop();
    }
  }

  void _processCommand(String command) async {
    final flashcardProvider = Provider.of<FlashcardProvider>(context, listen: false);
    final flashcards = flashcardProvider.flashcards;

    if (flashcards.isEmpty) return;

    if (RegExp(r'\b(next|go to next|next card)\b').hasMatch(command)) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % flashcards.length;
        _showingAnswer = false;
      });
      _speak(flashcards[_currentIndex].question);
    } else if (RegExp(r'\b(show answer|answer|reveal answer)\b').hasMatch(command)) {
      setState(() => _showingAnswer = true);
      _speak(flashcards[_currentIndex].answer);
    } else if (RegExp(r'\b(repeat|say again|read again)\b').hasMatch(command)) {
      _speak(_showingAnswer ? flashcards[_currentIndex].answer : flashcards[_currentIndex].question);
    } else if (RegExp(r'\b(mark complete|done|finished)\b').hasMatch(command)) {
      await flashcardProvider.markFlashcardCompleted(flashcards[_currentIndex].id, true);
      _speak('Flashcard marked as complete');
    }
  }

  void _speak(String text) async {
    _stopListening();
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = Provider.of<FlashcardProvider>(context);
    final flashcards = flashcardProvider.flashcards;

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Review Mode')),
      body: flashcards.isEmpty
          ? const Center(child: Text('No flashcards available'))
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Card(
                        key: ValueKey(_currentIndex.toString() + _showingAnswer.toString()),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _showingAnswer
                                ? flashcards[_currentIndex].answer
                                : flashcards[_currentIndex].question,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: _isListening ? _stopListening : _startListening,
                        child: RotationTransition(
                          turns: _animationController,
                          child: Icon(_isListening ? Icons.mic : Icons.mic_off),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(_isListening ? 'Listening...' : 'Tap to speak'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}