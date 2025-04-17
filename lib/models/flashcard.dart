import 'package:uuid/uuid.dart';

class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String category;
  final bool completed;
  final int reviewCount;
  final DateTime? lastReviewed;

  Flashcard({
    String? id,
    required this.question,
    required this.answer,
    required this.category,
    this.completed = false,
    this.reviewCount = 0,
    this.lastReviewed,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'category': category,
        'completed': completed,
        'reviewCount': reviewCount,
        'lastReviewed': lastReviewed?.toIso8601String(),
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'],
        question: json['question'],
        answer: json['answer'],
        category: json['category'],
        completed: json['completed'] ?? false,
        reviewCount: json['reviewCount'] ?? 0,
        lastReviewed: json['lastReviewed'] != null ? DateTime.parse(json['lastReviewed']) : null,
      );

  Flashcard copyWith({bool? completed, int? reviewCount, DateTime? lastReviewed}) => Flashcard(
        id: id,
        question: question,
        answer: answer,
        category: category,
        completed: completed ?? this.completed,
        reviewCount: reviewCount ?? this.reviewCount,
        lastReviewed: lastReviewed ?? this.lastReviewed,
      );
}