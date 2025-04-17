import 'package:flutter/material.dart';
import '../../models/flashcard.dart';
import '../../utils/database_helper.dart';

class FlashcardProvider with ChangeNotifier {
  List<Flashcard> _flashcards = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Flashcard> get flashcards => _flashcards;

  FlashcardProvider() {
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    _flashcards = await _dbHelper.getFlashcards();
    notifyListeners();
  }

  List<Flashcard> getFlashcardsByCategory(String? category) =>
      category == null || category == 'All'
          ? _flashcards
          : _flashcards.where((f) => f.category == category).toList();

  Future<void> addFlashcard(Flashcard flashcard) async {
    _flashcards.add(flashcard);
    await _dbHelper.insertFlashcard(flashcard);
    notifyListeners();
  }

  Future<void> addFlashcards(List<Flashcard> flashcards) async {
    _flashcards.addAll(flashcards);
    await _dbHelper.insertFlashcards(flashcards);
    notifyListeners();
  }

  Future<void> markFlashcardCompleted(String id, bool completed) async {
    final index = _flashcards.indexWhere((f) => f.id == id);
    if (index != -1) {
      final updated = _flashcards[index].copyWith(
        completed: completed,
        reviewCount: _flashcards[index].reviewCount + 1,
        lastReviewed: DateTime.now(),
      );
      _flashcards[index] = updated;
      await _dbHelper.updateFlashcard(updated);
      notifyListeners();
    }
  }

  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (var flashcard in _flashcards) {
      stats[flashcard.category] = (stats[flashcard.category] ?? 0) + 1;
    }
    return stats;
  }

  double getCompletionRate() {
    if (_flashcards.isEmpty) return 0.0;
    final completed = _flashcards.where((f) => f.completed).length;
    return (completed / _flashcards.length) * 100;
  }

  Map<String, int> getReviewFrequency() {
    final frequency = <String, int>{};
    for (var flashcard in _flashcards) {
      frequency[flashcard.category] =
          (frequency[flashcard.category] ?? 0) + flashcard.reviewCount;
    }
    return frequency;
  }

  Duration getTotalTimeSpent() {
    final now = DateTime.now();
    final total = _flashcards.fold(Duration.zero, (sum, f) {
      if (f.lastReviewed != null) {
        return sum + now.difference(f.lastReviewed!);
      }
      return sum;
    });
    return total;
  }
}