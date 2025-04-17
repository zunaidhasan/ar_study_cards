import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'flashcard_provider.dart';
import '../../models/flashcard.dart';

class FlashcardCreatorScreen extends StatefulWidget {
  const FlashcardCreatorScreen({super.key});

  @override
  State<FlashcardCreatorScreen> createState() => _FlashcardCreatorScreenState();
}

class _FlashcardCreatorScreenState extends State<FlashcardCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  String _category = 'General';

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _importCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result != null && result.files.single.bytes != null) {
        final csvString = String.fromCharCodes(result.files.single.bytes!);
        final csvRows = const CsvToListConverter().convert(csvString);
        final flashcards = <Flashcard>[];
        final errors = <String>[];

        for (var i = 0; i < csvRows.length; i++) {
          final row = csvRows[i];
          if (row.length >= 3 && row[0].toString().isNotEmpty && row[1].toString().isNotEmpty) {
            flashcards.add(Flashcard(
              question: row[0].toString(),
              answer: row[1].toString(),
              category: row[2].toString().isNotEmpty ? row[2].toString() : 'General',
            ));
          } else {
            errors.add('Row ${i + 1}: Invalid format (requires question, answer, category)');
          }
        }

        if (flashcards.isNotEmpty) {
          await Provider.of<FlashcardProvider>(context, listen: false).addFlashcards(flashcards);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported ${flashcards.length} flashcards')),
          );
        }
        if (errors.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errors: ${errors.join('; ')}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing CSV: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Flashcard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (value) => value!.isEmpty ? 'Enter a question' : null,
              ),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
                validator: (value) => value!.isEmpty ? 'Enter an answer' : null,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['General', 'Math', 'Science', 'History']
                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final flashcard = Flashcard(
                          question: _questionController.text,
                          answer: _answerController.text,
                          category: _category,
                        );
                        Provider.of<FlashcardProvider>(context, listen: false).addFlashcard(flashcard);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Flashcard created!')),
                        );
                        _questionController.clear();
                        _answerController.clear();
                      }
                    },
                    child: const Text('Save Flashcard'),
                  ),
                  ElevatedButton(
                    onPressed: _importCsv,
                    child: const Text('Import CSV'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}