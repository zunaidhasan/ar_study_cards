import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';
import '../flashcard_creator/flashcard_provider.dart';

class FlashcardReviewScreen extends StatefulWidget {
  const FlashcardReviewScreen({super.key});

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = Provider.of<FlashcardProvider>(context);
    final flashcards = flashcardProvider.getFlashcardsByCategory(_selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Flashcards'),
        actions: [
          DropdownButton<String>(
            value: _selectedCategory ?? 'All',
            items: ['All', 'General', 'Math', 'Science', 'History']
                .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedCategory = value == 'All' ? null : value);
            },
          ),
        ],
      ),
      body: flashcards.isEmpty
          ? const Center(child: Text('No flashcards available'))
          : PageView.builder(
              itemCount: flashcards.length,
              itemBuilder: (context, index) {
                final flashcard = flashcards[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FlipCard(
                    front: Card(
                      elevation: 4,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            flashcard.question,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    back: Card(
                      elevation: 4,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            flashcard.answer,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}