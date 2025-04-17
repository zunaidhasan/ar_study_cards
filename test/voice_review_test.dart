import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ar_study_cards/features/voice_review/voice_review_screen.dart';
import 'package:ar_study_cards/features/flashcard_creator/flashcard_provider.dart';
import 'package:ar_study_cards/models/flashcard.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MockSpeechToText extends Mock implements SpeechToText {}

void main() {
  testWidgets('VoiceReviewScreen processes speech commands', (WidgetTester tester) async {
    final mockSpeech = MockSpeechToText();
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

    when(mockSpeech.initialize()).thenAnswer((_) async => true);
    when(mockSpeech.listen(onResult: anyNamed('onResult')))
        .thenAnswer((invocation) async {
      final callback = invocation.namedArguments[#onResult] as Function(SpeechRecognitionResult);
      callback(SpeechRecognitionResult('next', true));
    });

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => flashcardProvider,
        child: const MaterialApp(
          home: VoiceReviewScreen(),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Capital of France?'), findsOneWidget);
  });
}