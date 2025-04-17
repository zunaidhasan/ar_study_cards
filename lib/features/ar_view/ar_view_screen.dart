import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../flashcard_creator/flashcard_provider.dart';

class ARViewScreen extends StatefulWidget {
  const ARViewScreen({super.key});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  ArCoreController? arCoreController;
  int _currentIndex = 0;
  bool _showingAnswer = false;

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController?.onNodeTap = _onNodeTap;
    _addFlashcardNode();
  }

  void _addFlashcardNode() {
    final flashcards = Provider.of<FlashcardProvider>(context, listen: false).flashcards;
    if (flashcards.isEmpty) return;

    final flashcard = flashcards[_currentIndex];
    final text = _showingAnswer ? flashcard.answer : flashcard.question;

    final node = ArCoreNode(
      shape: ArCoreText(
        text: text,
        fontSize: 0.1,
        color: Colors.black,
      ),
      position: vector.Vector3(0, 0, -1.5),
      scale: vector.Vector3(1, 1, 1),
      rotation: vector.Vector4(0, 0, 0, 1),
    );
    arCoreController?.addArCoreNode(node);
  }

  void _onNodeTap(List<String> nodeNames) {
    setState(() {
      _showingAnswer = !_showingAnswer;
      arCoreController?.removeNode(nodeName: nodeNames.first);
      _addFlashcardNode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final flashcards = Provider.of<FlashcardProvider>(context).flashcards;

    return Scaffold(
      appBar: AppBar(title: const Text('AR View Mode')),
      body: flashcards.isEmpty
          ? const Center(child: Text('No flashcards available'))
          : Stack(
              children: [
                ArCoreView(
                  onArCoreViewCreated: _onArCoreViewCreated,
                  enableTapRecognizer: true,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = (_currentIndex - 1) % flashcards.length;
                            if (_currentIndex < 0) _currentIndex += flashcards.length;
                            _showingAnswer = false;
                            arCoreController?.removeNode(nodeName: 'flashcard');
                            _addFlashcardNode();
                          });
                        },
                        child: const Icon(Icons.arrow_back),
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = (_currentIndex + 1) % flashcards.length;
                            _showingAnswer = false;
                            arCoreController?.removeNode(nodeName: 'flashcard');
                            _addFlashcardNode();
                          });
                        },
                        child: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}