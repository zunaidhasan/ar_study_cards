import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../flashcard_creator/flashcard_provider.dart';

class ProfileStatsScreen extends StatelessWidget {
  const ProfileStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = Provider.of<FlashcardProvider>(context);
    final categoryStats = flashcardProvider.getCategoryStats();
    final completionRate = flashcardProvider.getCompletionRate();
    final reviewFrequency = flashcardProvider.getReviewFrequency();
    final timeSpent = flashcardProvider.getTotalTimeSpent();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 16),
              Text(
                'Completion Rate: ${completionRate.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Total Time Spent: ${timeSpent.inMinutes} minutes',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Flashcards by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200,
                child: categoryStats.isEmpty
                    ? const Center(child: Text('No flashcards available'))
                    : PieChart(
                        PieChartData(
                          sections: categoryStats.entries
                              .asMap()
                              .entries
                              .map(
                                (entry) => PieChartSectionData(
                                  value: entry.value.value.toDouble(),
                                  title: '${entry.value.key}\n${entry.value.value}',
                                  color: Colors.primaries[entry.key % Colors.primaries.length],
                                  radius: 100,
                                ),
                              )
                              .toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Review Frequency by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200,
                child: reviewFrequency.isEmpty
                    ? const Center(child: Text('No reviews yet'))
                    : PieChart(
                        PieChartData(
                          sections: reviewFrequency.entries
                              .asMap()
                              .entries
                              .map(
                                (entry) => PieChartSectionData(
                                  value: entry.value.value.toDouble(),
                                  title: '${entry.value.key}\n${entry.value.value}',
                                  color: Colors.primaries[entry.key % Colors.primaries.length],
                                  radius: 100,
                                ),
                              )
                              .toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}