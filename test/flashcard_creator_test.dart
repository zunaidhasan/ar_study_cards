import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ar_study_cards/features/flashcard_creator/flashcard_creator_screen.dart';
import 'package:ar_study_cards/features/flashcard_creator/flashcard_provider.dart';
import 'package:ar_study_cards/models/flashcard.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class MockFilePicker extends Mock implements FilePicker {}

void main() {
  testWidgets('FlashcardCreatorScreen imports CSV correctly', (WidgetTester tester) async {
    final mockFilePicker = MockFilePicker();
    final flashcardProvider = FlashcardProvider();

    when(mockFilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    )).thenAnswer((_) async => FilePickerResult([
          PlatformFile(
            name: 'test.csv',
            size: 100,
            bytes: Uint8List.fromList(
              'What is 2+2?,4,Math\nWhat is the capital of France?,Paris,History'
                  .codeUnits,
            ),
          ),
        ]));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => flashcardProvider,
        child: const MaterialApp(
          home: FlashcardCreatorScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Import CSV'));
    await tester.pumpAndSettle();

    expect(flashcardProvider.flashcards.length, 2);
    expect(flashcardProvider.flashcards[0].question, 'What is 2+2?');
    expect(flashcardProvider.flashcards[1].category, 'History');
  });
}