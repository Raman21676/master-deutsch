class QuizLevel {
  final String id;
  final String name;
  final String description;
  final String color;
  final List<QuizSetInfo> sets;

  QuizLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.sets,
  });
}

class QuizSetInfo {
  final String id;
  final String name;
  final String subtitle;

  QuizSetInfo({
    required this.id,
    required this.name,
    required this.subtitle,
  });
}

final List<QuizLevel> quizLevels = [
  QuizLevel(
    id: 'A1',
    name: 'A1 - Beginner',
    description: 'Basic everyday phrases and simple questions',
    color: '#4CAF50',
    sets: [
      QuizSetInfo(
        id: 'A1.1',
        name: 'A1.1',
        subtitle: 'Greetings, introductions, numbers',
      ),
      QuizSetInfo(
        id: 'A1.2',
        name: 'A1.2',
        subtitle: 'Family, food, daily routines',
      ),
    ],
  ),
  QuizLevel(
    id: 'A2',
    name: 'A2 - Elementary',
    description: 'Familiar topics and simple conversations',
    color: '#8BC34A',
    sets: [
      QuizSetInfo(
        id: 'A2.1',
        name: 'A2.1',
        subtitle: 'Shopping, work, travel basics',
      ),
      QuizSetInfo(
        id: 'A2.2',
        name: 'A2.2',
        subtitle: 'Past events, future plans, directions',
      ),
    ],
  ),
  QuizLevel(
    id: 'B1',
    name: 'B1 - Intermediate',
    description: 'Clear standard input on familiar matters',
    color: '#FFC107',
    sets: [
      QuizSetInfo(
        id: 'B1.1',
        name: 'B1.1',
        subtitle: 'School, work, leisure discussions',
      ),
      QuizSetInfo(
        id: 'B1.2',
        name: 'B1.2',
        subtitle: 'Dreams, hopes, ambitions, opinions',
      ),
    ],
  ),
  QuizLevel(
    id: 'B2',
    name: 'B2 - Upper Intermediate',
    description: 'Complex texts and technical discussions',
    color: '#FF9800',
    sets: [
      QuizSetInfo(
        id: 'B2.1',
        name: 'B2.1',
        subtitle: 'Abstract topics, pros and cons',
      ),
      QuizSetInfo(
        id: 'B2.2',
        name: 'B2.2',
        subtitle: 'Specialized topics, fluency practice',
      ),
    ],
  ),
  QuizLevel(
    id: 'C1',
    name: 'C1 - Advanced',
    description: 'Implicit meaning and fluent expression',
    color: '#FF5722',
    sets: [
      QuizSetInfo(
        id: 'C1.1',
        name: 'C1.1',
        subtitle: 'Complex arguments, academic language',
      ),
      QuizSetInfo(
        id: 'C1.2',
        name: 'C1.2',
        subtitle: 'Nuanced expressions, professional contexts',
      ),
    ],
  ),
  QuizLevel(
    id: 'C2',
    name: 'C2 - Mastery',
    description: 'Precise expression in complex situations',
    color: '#E91E63',
    sets: [
      QuizSetInfo(
        id: 'C2.1',
        name: 'C2.1',
        subtitle: 'Academic, professional, literary German',
      ),
      QuizSetInfo(
        id: 'C2.2',
        name: 'C2.2',
        subtitle: 'Idioms, subtle distinctions, native-level',
      ),
    ],
  ),
];
