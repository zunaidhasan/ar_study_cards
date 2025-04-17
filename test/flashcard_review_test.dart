import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ar_study_cards/features/flashcard_review/flashcard_review_screen.dart';
import 'package:ar_study_cards/features/flashcard_creator/flashcard_provider.dart';
import 'package:ar_study_cards/models/flashcard.dart';

void main() {
  testWidgets('FlashcardReviewScreen flips card and filters by category', (WidgetTester tester) async {
    final flashcardProvider = FlashcardProvider();
    flashcardProvider.addFlashcard(Flashcard(
      question: 'What is 2+2?',
      answer: '4',
      category: 'Math',
    ));
    flashcardProvider.addFlashcard(Flashcard(
      question: 'Capital of France?',
      answer: 'Paris',
      category: 'History',
    ));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => flashcardProvider,
        child: const MaterialApp(
          home: FlashcardReviewScreen(),
        ),
      ),
    );

    expect(find.text('What is 2+2?'), findsOneWidget);
    await tester.tap(find.byType(Card));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    expect(find.text('Capital of France?'), findsOneWidget);
  });
}