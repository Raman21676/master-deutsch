import '../models/question.dart';
import '../models/quiz_level.dart';
import 'a1_1_data.dart';
import 'a1_2_data.dart';
import 'a2_1_data.dart';
import 'a2_2_data.dart';
import 'b1_1_data.dart';
import 'b1_2_data.dart';
import 'b2_1_data.dart';
import 'b2_2_data.dart';
import 'c1_1_data.dart';
import 'c1_2_data.dart';
import 'c2_1_data.dart';
import 'c2_2_data.dart';
import 'dart:math';

class QuizData {
  static final Map<String, List<Question>> _questionSets = {
    'A1.1': a1_1Questions,
    'A1.2': a1_2Questions,
    'A2.1': a2_1Questions,
    'A2.2': a2_2Questions,
    'B1.1': b1_1Questions,
    'B1.2': b1_2Questions,
    'B2.1': b2_1Questions,
    'B2.2': b2_2Questions,
    'C1.1': c1_1Questions,
    'C1.2': c1_2Questions,
    'C2.1': c2_1Questions,
    'C2.2': c2_2Questions,
  };

  static List<QuizSet> getAllQuizSets() {
    final List<QuizSet> sets = [];
    
    for (final level in quizLevels) {
      for (final setInfo in level.sets) {
        final questions = _questionSets[setInfo.id] ?? [];
        // Shuffle questions for variety
        final shuffledQuestions = List<Question>.from(questions)..shuffle(Random());
        
        sets.add(QuizSet(
          id: setInfo.id,
          name: setInfo.name,
          level: level.id,
          description: setInfo.subtitle,
          questions: shuffledQuestions,
        ));
      }
    }
    return sets;
  }

  static QuizSet? getQuizSet(String setId) {
    final questions = _questionSets[setId];
    if (questions == null) return null;

    // Find level info
    String levelId = setId.substring(0, 2);
    final level = quizLevels.firstWhere((l) => l.id == levelId);
    final setInfo = level.sets.firstWhere((s) => s.id == setId);

    // Shuffle questions
    final shuffledQuestions = List<Question>.from(questions)..shuffle(Random());

    return QuizSet(
      id: setId,
      name: setInfo.name,
      level: levelId,
      description: setInfo.subtitle,
      questions: shuffledQuestions,
    );
  }

  static List<Question> getQuestionsForSet(String setId) {
    final questions = _questionSets[setId] ?? [];
    // Return shuffled copy
    return List<Question>.from(questions)..shuffle(Random());
  }

  static int getTotalQuestions() {
    return _questionSets.values.fold(0, (sum, list) => sum + list.length);
  }

  static int getQuestionCountForSet(String setId) {
    return _questionSets[setId]?.length ?? 0;
  }

  static String getLevelColor(String levelId) {
    switch (levelId) {
      case 'A1':
        return '#4CAF50';
      case 'A2':
        return '#8BC34A';
      case 'B1':
        return '#FFC107';
      case 'B2':
        return '#FF9800';
      case 'C1':
        return '#FF5722';
      case 'C2':
        return '#E91E63';
      default:
        return '#1976D2';
    }
  }
}
